function [Skeleton,Links,Table]=tubeDetection(Mask,Res,Version)
Pix=size(Mask).';
global ShowIntermediateSteps; % ShowIntermediateSteps=1; 
if exist('Version')~=1
    Version=struct;
end
if ShowIntermediateSteps==1
    global ChannelTable;
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
    Fileinfo=getFileinfo_2(Application);
    PixInter=Fileinfo.Pix{1};
%     global Application;
end
%% define skeleton
Skeleton=logical(Mask);
[WatershedDistance]=distanceMat_4(~Skeleton,{'DistInOut'},Res,0.1,1,0,0,'uint16');
% WatershedDistance=WatershedDistance/10;
RemoveLength=[2;4;8;12];

for Run=1:4
    disp(['Run: ',num2str(Run)]);
    Skeleton=bwskel(Skeleton);
    [Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);
    Nodes=struct2table(Nodes);
    % identify Links with an endpoint on one side and a
    Links=struct2table(Links);
    Links.NumPix=cellfun(@numel,Links.point);
    for Link=1:size(Links,1)
        Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
    end
    Links.Endpoint=sum(Links.Endpoint,2);
    Links=Links(Links.Endpoint>0 & Links.NumPix<=RemoveLength(Run),:);
    Skeleton(cell2mat(Links.point.'))=0;
    Skeleton(cell2mat(Nodes.idx(Nodes.ep==1)))=0;
    
    Distances=double(unique(WatershedDistance(Skeleton==1)));
    Distances(Distances<1,:)=[];
    Table=table;
    Table.Ind=find(Skeleton>0);
    Table.Diameter=(double(WatershedDistance(Table.Ind))+3)*0.1*2;
    [Wave1]=sparseImDilate(Table.Ind,Table.Diameter,Pix,Res);
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Wave1+uint16(Skeleton),PixInter),Application,['Tube_Run',num2str(Run)]); end;
    Skeleton=logical(Wave1);
end

Skeleton=bwskel(Skeleton);
[Links,Nodes,AxonMap,LinkMap]=skeletonize(Skeleton);
Table=table;
%% find connected Links
if isfield(Version,'FindConnectedLinks')
    Links.Id=(1:size(Links,1)).';
    Links(Links.NumPix<5,:)=[]; % after endpoints have been cut off at least 2 points have to remain
    
    [Links,Table]=tubeDetection_findConnectedLinks_2(Links,Pix,Res);
end