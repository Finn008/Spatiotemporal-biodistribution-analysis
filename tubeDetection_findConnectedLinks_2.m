function [Links3,Table2]=tubeDetection_findConnectedLinks_2(Links,Pix,Res)
% global ShowIntermediateSteps;
% if ShowIntermediateSteps==1
%     global Application;
% end

Endpoints=table;
for Link=1:size(Links,1)
    Table=table;
    Table.LinIdx=Links.Idx{Link,1};
    [Table.XYZpix(:,1),Table.XYZpix(:,2),Table.XYZpix(:,3)]=ind2sub(Pix,Table.LinIdx);
    Table.XYZum=Table.XYZpix.*repmat(Res.',[size(Table,1),1]);
    Table.Distance=distanceAlongPath(Table.XYZum);
    for Point=[1,size(Table,1)]
        % get direction at 2µm, 10µm and total
        Table.Vector=repmat(Table.XYZum(Point,:),[size(Table,1),1])-Table.XYZum;
        Table.Vector=Table.Vector./repmat(sum(Table.Vector.^2,2).^0.5,[1,3]);
        Wave1=find(Table.Distance>=3,1);
        if isempty(Wave1)
            [~,Wave1]=max(Table.Distance);
        end
        Endpoints(end+1,{'Link';'Point';'XYZum';'Vector'})={Links.Id(Link),Point,Table.XYZum(Point,:),Table.Vector(Wave1,:)};
        Table.Distance=Table.Distance(end)-Table.Distance;
    end
    Links.Path(Link,1)={Table};
end
Endpoints.Id=(1:size(Endpoints,1)).';
DistanceWeight=table; DistanceWeight.Distance=(0:1000).';
DistanceWeight.Weight=(1:size(DistanceWeight,1)).'.^-0.5;
DistanceWeight.Weight(DistanceWeight.Distance>10)=0;

AngleWeight=table; AngleWeight.Angle=round(0:0.1:6.3,1).';
AngleWeight.Weight=(1:size(AngleWeight)).'.^-0.5;
AngleWeight.Weight(AngleWeight.Angle>2)=0;

WeightArray=zeros(size(Endpoints,1));
for Point=1:size(Endpoints,1)
    %     Table=Endpoints(:,{'Link';'Point'});
    Endpoints.ConnVector=Endpoints.XYZum-repmat(Endpoints.XYZum(Point,:),[size(Endpoints,1),1]);
    Endpoints.Distance=sum(Endpoints.ConnVector.^2,2).^0.5;
    Endpoints.ConnVector=Endpoints.ConnVector./repmat(sum(Endpoints.ConnVector.^2,2).^0.5,[1,3]);
    Wave1=Endpoints.ConnVector-repmat(Endpoints.Vector(Point,:),[size(Endpoints,1),1]);
    Wave1=sum(Wave1.^2,2).^0.5;
    Endpoints.Angle(:,1)=2*asin(Wave1/2);
    Wave1=-Endpoints.Vector-Endpoints.ConnVector;
    Wave1=sum(Wave1.^2,2).^0.5;
    Endpoints.Angle(:,2)=2*asin(Wave1/2);
    Endpoints(Point,{'Distance';'Angle'})={1000,[pi,pi]};
    
    Endpoints.AngleSum=sum(Endpoints.Angle,2);
    Endpoints.AnglePerDistance=sum(Endpoints.Angle,2)./Endpoints.Distance;
    % Weighting
    [~,Wave1]=ismember(round(Endpoints.Distance),DistanceWeight.Distance);
    Endpoints.Weight=DistanceWeight.Weight(Wave1);
    [~,Wave1]=ismember(round(sum(Endpoints.Angle,2),1),AngleWeight.Angle);
    Endpoints.Weight=Endpoints.Weight.*AngleWeight.Weight(Wave1);
    
    Selection=sortrows(Endpoints(Endpoints.Weight>0,:),'Weight','descend');
    Endpoints.Connections(Point,1)={Selection.Id};
    for m=1:size(Selection,1)
        WeightArray(Point,Selection.Id(m))=Selection.Weight(m);
    end
end
Endpoints = removevars(Endpoints, {'ConnVector','Distance','Angle','AngleSum','AnglePerDistance','Weight'});

%% select matching Links
Links.SuperFamily(:,1)=zeros(size(Links,1),1);
Endpoints.ConnectedPoint=zeros(size(Endpoints,1),1);
for Point=1:size(Endpoints,1)
    if Endpoints.ConnectedPoint(Point)~=0; continue; end;
    [~,SuggestedConnection]=max(WeightArray(:,Point));
    if isempty(SuggestedConnection)==0
        [~,SuggestedConnectionOfConnection]=max(WeightArray(:,SuggestedConnection));
        if SuggestedConnectionOfConnection==Point
            LinkIds=Endpoints.Link([Point;SuggestedConnection]);
            
            SuperFamily=unique([Links.SuperFamily(ismember2(LinkIds,Links.Id),1)]);
            SuperFamily(SuperFamily==0)=[];

            if size(SuperFamily,1)==2 % fuse two separate SuperFamilies
                LinkIds=Links.Id(ismember(Links.SuperFamily,SuperFamily));
            elseif isempty(SuperFamily)
                SuperFamily=max(Links.SuperFamily)+1;
            end
            Links.SuperFamily(ismember2(LinkIds,Links.Id))=SuperFamily(1);
            Endpoints.ConnectedPoint([Point;SuggestedConnection])=[SuggestedConnection;Point];
            WeightArray([Point;SuggestedConnection],:)=0;
        end
    end
end
Wave1=find(Links.SuperFamily==0);
Links.SuperFamily(Wave1)=(max(Links.SuperFamily)+1:max(Links.SuperFamily)+size(Wave1,1)).';
%% generate new Links
Links3=table;
Table2=table;
SuperFamilies=unique(Links.SuperFamily);
for SuperFamily=1:size(SuperFamilies,1) % unique(Links.SuperFamily).'
    Links2=Links(Links.SuperFamily==SuperFamilies(SuperFamily),:);
    Endpoints2=Endpoints(ismember(Endpoints.Link,Links2.Id),:);
    % find startig Link
    CurrentPoint=Endpoints2.Id(find(Endpoints2.ConnectedPoint==0,1));
    Table=table;
    for m=1:size(Links2,1)
        Link=Endpoints2.Link(Endpoints2.Id==CurrentPoint);
        Data2Add=Links2.Path{Links2.Id==Link};
        if Endpoints2.Point(Endpoints2.Link==Link & Endpoints2.ConnectedPoint==CurrentPoint)~=1
            Data2Add=flip(Data2Add);
        end
        Data2Add.Distance=distanceAlongPath(Data2Add.XYZum);
        if isempty(Table)==0
            Data2Add.Distance=Data2Add.Distance+max(Table.Distance);
        end
        Table=[Table;Data2Add(:,{'LinIdx';'XYZpix';'XYZum';'Distance';'Vector'})];
        CurrentPoint=Endpoints2.ConnectedPoint(Endpoints2.Link==Link & Endpoints2.Id~=CurrentPoint);
    end
    Links3(SuperFamily,{'SuperFamily','Path','DistanceMax'})={SuperFamily,Table,max(Table.Distance)};
    Table.SuperFamily(:,1)=SuperFamily;
    Table2=[Table2;Table];
end
