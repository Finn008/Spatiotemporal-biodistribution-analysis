function tubeDetection(Mask,Res,Version)
% ex2Imaris_2(WatershedDistance,Application,'Axons_WatershedDistance');
% ex2Imaris_2(LocalMaxima,Application,'Axons_LocalMaxima');
% LocalMaxima(:)=0; LocalMaxima(Seeds.Ind)=1;
global Application;
Pix=size(Mask).';

%% define skeleton
% Skeleton=interpolate3D_3(Mask,[],Res,min(Res));
Skeleton=logical(Mask);
% ResCalc=repmat(min(Res),[3,1]);
% [WatershedDistance]=distanceMat_4(~Skeleton,{'DistInOut'},ResCalc,ResCalc(1),1,0,0,'uint16');
[WatershedDistance]=distanceMat_4(~Skeleton,{'DistInOut'},Res,0.01,1,0,0,'uint16');
WatershedDistance=WatershedDistance/10;
RemoveLength=[2;4;8;12];
for Run=1:4
    disp(['Run: ',num2str(Run)]);
    Skeleton=bwskel(Skeleton);
    %     ex2Imaris_2(Skeleton,Application,['Skeleton_',num2str(Run)]);
    [Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);
    Nodes=struct2table(Nodes);
    % identify Links with an endpoint on one side and a
    
    %     if Run>1
    Links=struct2table(Links);
    Links.NumPix=cellfun(@numel,Links.point);
    for Link=1:size(Links,1)
        Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
    end
    Links.Endpoint=sum(Links.Endpoint,2);
    Links=Links(Links.Endpoint>0 & Links.NumPix<=RemoveLength(Run),:);
    Skeleton(cell2mat(Links.point.'))=0;
    %     end
    Skeleton(cell2mat(Nodes.idx(Nodes.ep==1)))=0;
    
    
    Distances=double(unique(WatershedDistance(Skeleton==1)));
    Distances(Distances<1,:)=[];
    Wave2=false(size(Skeleton));
    for Dist=Distances.'
        %         Window=imdilateWindow_2(repmat(max([Dist,3])*0.1*2,[3,1]),Res,1,'ellipsoid');
        Window=imdilateWindow_2(repmat((Dist+3)*0.1*2,[3,1]),Res,1,'ellipsoid');
        Wave1=Skeleton.*(WatershedDistance==Dist);
        Wave1=imdilate(Wave1,Window);
        Wave2(Wave1==1)=1;
        disp(['Dist: ',num2str(Dist)]);
    end
    %     ex2Imaris_2(uint8(Skeleton)+uint8(Wave2),Application,['Skeleton_',num2str(Run)]);
    Skeleton=Wave2;
    % %     clear Wave2;
end

%% find connected Links
Skeleton=bwskel(Skeleton);
[Links,Nodes,AxonMap,LinkMap]=skeletonize(Skeleton);
ex2Imaris_2(AxonMap,Application,'AxonMap');
ex2Imaris_2(LinkMap,Application,'LinkMap');
Links.Id=(1:size(Links,1)).';
Links(Links.NumPix<5,:)=[]; % after endpoints have been cut off at least 2 points have to remain
% Links=sortrows(Links,'NumPix','descend');

tubeDetection_findConnectedLinks_2(Links,Pix,Res);

ex2Imaris_2(LinkMap2,Application,'LinkMap2');
keyboard;
return;

ResCalc=Res; %[1;1;1];
Data3D=interpolate3D_3(Skeleton,[],Res,ResCalc);
PixCalc=uint16(size(Data3D).');
Distance3D=zeros(PixCalc.'*2+1,'uint8');
Distance3D(PixCalc(1)+1,PixCalc(2)+1,PixCalc(3)+1)=1;
% Distance3D=uint16(bwdist(Distance3D,'euclidean'));
Distance3D=distanceMat_4(Distance3D,'DistInOut',Res,0.1,1,0,0,'uint16');

for Link=1:size(Links,1)
    Table=table;
    Table.LinIdx=Links.Idx{Link,1};
    [Table.XYZpix(:,1),Table.XYZpix(:,2),Table.XYZpix(:,3)]=ind2sub(Pix,Table.LinIdx);
    Table.XYZum=Table.XYZpix.*repmat(Res.',[size(Table,1),1]);
    Wave1=Table.XYZum(7:end,:)-Table.XYZum(1:end-6,:);
    Table.Vector=[repmat(Wave1(1,:),[3,1]);Wave1;repmat(Wave1(end,:),[3,1])];
    
    Table.Angle(:,1)=atan2(sqrt(Table.Vector(:,2).^2+Table.Vector(:,3).^2),Table.Vector(:,1)); % ax=atan2(sqrt(y^2+z^2),x);
    Table.Angle(:,2)=atan2(sqrt(Table.Vector(:,3).^2+Table.Vector(:,1).^2),Table.Vector(:,2)); % ay = atan2(sqrt(z^2+x^2),y);
    Table.Angle(:,3)=atan2(sqrt(Table.Vector(:,1).^2+Table.Vector(:,2).^2),Table.Vector(:,3)); % az = atan2(sqrt(x^2+y^2),z);
    for Direction=1:2
        if Direction==1
            Point=1;
        else
            Point=size(Table,1);
        end
        
        
        
        
        Table2=table;
        Table2.XYZum=Table.XYZum(Point,:).';
        Table2.XYZpix=uint16(Table2.XYZum./ResCalc);
        Table2.Cut=PixCalc-Table2.XYZpix; Table2.Cut(:,2)=Table2.Cut(:,1)+PixCalc-1;
        Distance=Distance3D(Table2.Cut(1,1):Table2.Cut(1,2),Table2.Cut(2,1):Table2.Cut(2,2),Table2.Cut(3,1):Table2.Cut(3,2));
        ex2Imaris_2(interpolate3D_3(Distance,Pix),Application,'Test');
        Data3D=zeros(PixCalc.','double');
    end
    
    
    
end


ex2Imaris_2(AxonMap,Application,'AxonMap');
AxonIds=unique(Links.label);
for Axon=AxonIds.'
    Links2=Links(Links.label==Axon,:);
end




% 3D connected component analysis
BW=bwconncomp(Skeleton,26);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
% Table(Table.Volume<10,:)=[];
BW.PixelIdxList=Table.IdxList.';
BW.NumObjects=size(Table,1);
Wave1=labelmatrix(BW);
ex2Imaris_2(Wave1,Application,'AxonMap');

% interpolate in 3D
interparc





return;
keyboard;
% Skeleton(cell2mat(Links.point))=1;
Skeleton(cell2mat(Nodes.idx(Nodes.ep==1)))=2;
ex2Imaris_2(Skeleton,Application,['Skeleton_',num2str(5)]);
ex2Imaris_2(interpolate3D_3(Wave2,Pix),Application,'Skeleton_2');
keyboard;
% ex2Imaris_2(Data3D,Application,'GFPM');
Links=struct2table(Links);
Links.NumPix=cellfun(@numel,Links.point);

for Link=1:size(Links,1)
    Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
end
Links.Endpoint=sum(Links.Endpoint,2);

Nodes(Nodes.ep>0,:)=[];
Links(Links.Endpoint>0,:)=[];
Skeleton=zeros(size(Skeleton),'uint16');
Skeleton(cell2mat(Links.point.'))=1;
Skeleton(cell2mat(Nodes.idx))=2;

%% Version3
Skeleton=logical(Mask);
BW=bwconncomp(Skeleton,6);
ObjectNumber=BW.NumObjects;
% Table.Size=[10000;1000;100;10;1];

for Shell=1:9999
    OuterShell=imdilate(~Skeleton,strel('sphere',1));
    OuterShell(Skeleton==0)=0;
    Table=table;
    Table.Size=flip(unique(ceil(sum(OuterShell(:))./((1:100).'.^5))));
    Table(find(Table.Size==1,1)+1:end,:)=[];
    Table.Idx(1,1)={find(OuterShell==1)};
    SizeLevel=1;
    for Run=1:9999999
        Indices=Table.Idx{SizeLevel,1};
        if size(Indices,1)>Table.Size(SizeLevel)
            Indices=Indices(1:Table.Size(SizeLevel));
        end
        Table.Idx{SizeLevel}(1:size(Indices,1))=[];
        %         Wave1=round(rand(size(Indices,1),1)*size(Indices,1));
        %         Indices=Indices(Wave1);
        Skeleton(Indices)=0;
        BW=bwconncomp(Skeleton,18);
        if BW.NumObjects>ObjectNumber
            Skeleton(Indices)=1;
            Table.Idx(SizeLevel+1)={[Table.Idx{SizeLevel+1};Indices]};
        else
            %             disp('success');
            ObjectNumber=BW.NumObjects;
            %             keyboard;
        end
        if isempty(Table.Idx{SizeLevel})
            if Table.Size(SizeLevel)==1
                keyboard;
            end
            SizeLevel=SizeLevel+1;
            disp(['SizeLevel: ',num2str(Table.Size(SizeLevel)),' RemainingVoxels: ',num2str(size(Table.Idx{SizeLevel},1))]);
        end
    end
    keyboard;
end
keyboard;
ex2Imaris_2(OuterShell,Application,'Skeleton_3');

%%




if isfield(Version,'DistanceTransformation')
    WatershedDistance=Mask;
else
    keyboard;
end
Pix=size(WatershedDistance).';
Membership=zeros(Pix.','double');

LocalMaxima=uint8(imregionalmax(WatershedDistance,6));
BW=bwconncomp(LocalMaxima,6);
Seeds=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Seeds.Volume=Seeds.NumPix*prod(Res(1:3));
Seeds.Ind=cellfun(@(v)v(1),Seeds.IdxList);
[Seeds.XYZPix(:,1),Seeds.XYZPix(:,2),Seeds.XYZPix(:,3)]=ind2sub(Pix,Seeds.Ind);
Seeds.XYZUm=Seeds.XYZPix.*repmat(Res.',[size(Seeds,1),1]);
Seeds.WatershedDistance=WatershedDistance(Seeds.Ind);

% get max extension
Data3D=zeros(Pix.','uint16');
Data3D(Seeds.Ind)=1:1:size(Seeds,1);
[Wave1,Wave2]=distanceMat_4(Data3D,{'DistInOut';'Membership'},Res,Version.WatershedUmBin,1,0,0,'uint16');
Wave1(WatershedDistance==0)=0;
Wave2(WatershedDistance==0)=0;
Wave1=accumarray_9(Wave2,Wave1,@max);

Wave1(Wave1.Roi1==0,:)=[];
Seeds.MaxExtension(Wave1.Roi1,1)=Wave1.Value1;

%     Seeds.DiameterUm=double(Seeds.WatershedDistance)*Version.WatershedUmBin*2;
[Wave1]=sparseImDilate(Seeds.Ind,double(Seeds.WatershedDistance)*Version.WatershedUmBin*2,Pix,Res);
[Wave2]=sparseImDilate(Seeds.Ind,double(Seeds.MaxExtension)*Version.WatershedUmBin*2,Pix,Res);
Wave3=uint16(Wave1>0)+uint16(Wave2>0);
ex2Imaris_2(Wave3,Application,'Axons_Test');
for Run=1:99999
    Length=linspace(0,20,20).';
    [Xcurve,Xgof,Xoutput]=fit(Table.Z(:,1),Table.Drift(:,1),FitType,Opts);
    keyboard;
    A1=1;
    %     global Application; ex2Imaris_2(Membership,Application,'Axons_Membership');
    %     Seeds.WatershedDistance=double(WatershedDistance(Seeds.Ind))*Version.WatershedUmBin;
    %     Seeds=sortrows(Seeds,'WatershedDistance','descend');
    
end


%% Version2
Skeleton=imdilate(logical(Mask),ones(3,3));
[Distance,Membership]=bwdist(~Skeleton,'chessboard');
% DistInOut=cast(ceil(DistInOut(Xt,Yt,Zt)*ResCalc/UmBin),DistanceBitType); % convert pixel based distance into µm based distance
% Membership(:)=Distance(Membership(:));
% Membership=cast(Membership(Xt,Yt,Zt),DistanceBitType);
% ex2Imaris_2(interpolate3D_3(Distance,Pix),Application,'Skeleton_1');
Membership=Membership(Distance>0);
Distance=Distance(Distance>0);
Wave1=accumarray_10(Membership,Distance,@max);
Distance=zeros(Pix.','uint16');
Distance(Wave1.Roi1)=Wave1.Value1;
% Skeleton=logical(Mask
for Dist=1:max(Distance(:))
    %     Wave2=(m-1)*2+1;
    Window=imdilateWindow_2([5;5;5],Res,[],'ellipsoid'); % previously 4µm cube
    Wave2=Dist*2+1;
    Wave1=imdilate(Distance==Dist,ones(Wave2,Wave2,Wave2));
    Skeleton(Wave1==1)=0;
end
% Skeleton(Mask==0)=0;
ex2Imaris_2(interpolate3D_3(Skeleton,Pix),Application,'Skeleton_3');
%% Version1
for Run=1:3
    Skeleton=interpolate3D_3(logical(Mask),[],Res,Res/3);
    Skeleton=imerode(Skeleton,ones(3,3,3));
    %     Skeleton=interpolate3D_3(Skeleton,Pix,[],[],@max);
    ex2Imaris_2(interpolate3D_3(Skeleton,Pix),Application,['Skeleton_',num2str(Run)]);
end
%% Skeleton
Skeleton=logical(Mask);
for Run=1:3
    Skeleton=bwskel(Skeleton);
    %     [Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);
    %
    %     Nodes=struct2table(Nodes);
    %     Links=struct2table(Links);
    %     Links.NumPix=cellfun(@numel,Links.point);
    %
    %     for Link=1:size(Links,1)
    %         Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
    %     end
    %     Links.Endpoint=sum(Links.Endpoint,2);
    %
    %     Links(Links.Endpoint>0,:)=[];
    %     Nodes(Nodes.ep>0,:)=[];
    %     Skeleton=zeros(size(Skeleton),'uint16');
    %     Skeleton(cell2mat(Links.point.'))=1;
    %     Skeleton(cell2mat(Nodes.idx))=2;
    ex2Imaris_2(interpolate3D_3(Skeleton,Pix,[],[],@max),Application,['Skeleton_',num2str(Run)]);
    if Run==1
        Skeleton=interpolate3D_3(Skeleton,[],Res,Res(1));
    end
    Window=imdilateWindow_2([3;3;3],Res(1),1,'ellipsoid'); % previously 4µm cube
    Skeleton=imdilate(logical(Skeleton),Window);
end


Wave1=struct('Connectivity',6,'ImageSize',Pix.','NumObjects',size(Links,1)); Wave1.PixelIdxList=Links.point.';
LinkMap=labelmatrix(Wave1);






for Link=1:size(Links,1)
    Wave1=Links.point{Link,1}.';
    Links.PointNumber(Link,1)=size(Wave1,1);
    Links.Endpoints(Link,1:2)=[Wave1(1),Wave1(end)];
end

Nodes.LinInd=sub2ind(Pix.',ceil(Nodes.comx),ceil(Nodes.comy),ceil(Nodes.comz));


% % Skeleton=zeros(Pix.','uint16');
% % Skeleton(cell2mat(Links.point.'))=1;
% % Skeleton(Nodes.LinInd)=2;


% Branchpoints
for m=1:size(Nodes,1)
    Skeleton(Nodes.LinInd(m))=m;
end
