function [LinkMap2]=tubeDetection_findConnectedLinks(Links)

global Application;
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
        %         Table.Test=sum(Table.Vector.^2,2).^0.5;
        %         Table.Angle=vectorAngle(Table.Vector);
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

% figure; plot(DistanceWeight(:,2));
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
    Endpoints.Connections(Point,1)={Selection};
    for m=1:size(Selection,1)
        WeightArray(Point,Selection.Id(m))=Selection.Weight(m);
    end
end
Endpoints = removevars(Endpoints, {'ConnVector','Distance','Angle','AngleSum','AnglePerDistance','Weight'});
% plotVector(Endpoints.Angle(884,:));
% Wave1=[0,0,0;Endpoints.Angle(884,:)];
% figure; plot3(Wave1(:,1),Wave1(:,2),Wave1(:,3),'k*-'); %legend(('first', 'second', 'third'});
% plot3(first(:,1), first(:,2), first(:,3), 'k*-', second(:,1), second(:,2), second(:,3), 'b^-', third(:,1), third(:,2), third(:,3), 'g>-');

% Links.SuperFamily(:,1)=zeros(size(Links,1),1);
% % select matching Links
% for Point=1:size(Endpoints,1)
%     NewSuperFamily=max(Links.SuperFamily)+1;
%     Connections=Endpoints.Connections{Point,1};
%     Points=Point;
%     if size(Connections,1)>0
%         Wave1=Endpoints.Connections{Connections.Id,1};
%         if Wave1.Id(1)==Point
%             Points=[Points;Connections.Id(1)];
%         end
%     end
%     Points=Endpoints.Link(Points);
%     [~,Points]=ismember(Points,Links.Id);
%     Wave2=min(Links.SuperFamily(Points,1));
%     if Wave2==0; Wave2=NewSuperFamily; end;
%     Links.SuperFamily(Points)=Wave2;
% end
% select matching Links
Links.SuperFamily(:,1)=zeros(size(Links,1),1);
Endpoints.SuperFamily=zeros(size(Endpoints,1),1);
for Point=find(Endpoints.SuperFamily==0).' % 1:size(Endpoints,1)
    NewSuperFamily=max(Links.SuperFamily)+1;
    [~,SuggestedConnection]=max(WeightArray(:,Point));
    %     ConnectedEndpoints=find(WeightArray(:,Point)>0);
    %     Connections=Endpoints.Connections{Point,1};
    %     Points=Point;
    if isempty(SuggestedConnection)==0
        %         if size(ConnectedEndpoints,1)>0
        [~,SuggestedConnectionOfConnection]=max(WeightArray(:,SuggestedConnection));
        %         Wave1=Endpoints.Connections{ConnectedEndpoints,1};
        if SuggestedConnectionOfConnection==Point
            %             Points=[Points;Connections.Id(1)];
            %             SuggestedConnection=[SuggestedConnection;SuggestedConnectionOfConnection];
            Wave1=Endpoints.Link([Point;SuggestedConnection]);
            [~,Wave1]=ismember(Wave1,Links.Id);
            Wave2=min(Links.SuperFamily(Wave1,1));
            if Wave2==0; Wave2=NewSuperFamily; end;
            Links.SuperFamily(Wave1)=Wave2;
            Endpoints.SuperFamily([Point;SuggestedConnection])=Wave2;
            WeightArray([Point;SuggestedConnection],:)=0;
        end
    end
    
end
LinkMap2=zeros(Pix.','uint16');
for m=unique(Links.SuperFamily).'
    LinkMap2(cell2mat(Links.Idx(Links.SuperFamily==m)))=m;
end

ex2Imaris_2(LinkMap2,Application,'LinkMap2');