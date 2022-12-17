function [Data3D,AxonDiameter]=dystrophyDetection_Axons(FilenameTotal,Readout,FilenameTotalOrig,ChannelListOrig);
timeTable('Start');
global ShowIntermediateSteps;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    Application=FilenameTotal;
%     global Application; Application=openImaris_4(FilenameTotal,[],1,1);
else
    ShowIntermediateSteps=0;
end

[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};

Settings={  '','SpFiPrctile','SpFiSubtrBackgr';...
    'GFPM',80,2500;...
    };
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,Readout,1));
Pix=size(Data3D).';
if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=im2Matlab_3(FilenameTotal,'Outside');
else
    Outside=zeros(size(Data3D),'uint8');
end

[~,Data3D]=percentileFilter3D_3(Data3D,Settings{Readout,'SpFiPrctile'}{1},Res,[10;10;Res(3)],Outside,Settings{Readout,'SpFiSubtrBackgr'}{1},[200;200;1]);
Data3D(Outside==1)=0;
if ShowIntermediateSteps==1; ex2Imaris_2(Data3D,Application,'Axons_PercentileFilter'); end
timeTable('Data3DAfterpercentileFilter3D');

Threshold=prctile(Data3D(Outside==0),90);
Axons=Data3D>Threshold;

[LocalPerc1]=percentileFilter3D_3(Data3D,90,Res,[0.5;0.5;0.5],Outside,0,[5;5;5]);
Axons(Data3D<LocalPerc1)=0;

% 3D connected component analysis
BW=bwconncomp(Axons,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<1,:)=[];
Axons=zeros(Pix.','uint16');
Axons(cell2mat(Table.IdxList))=1;

% fill holes
BW=bwconncomp(~Axons,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume>5,:)=[];
Axons(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Axons,Application,'Axons_1'); end;

%% calculate diameter of segments
% PlaqueMap2=interpolate3D(PlaqueMap2,Res,ResWatershed);
SeparationMode='Distance';
WatershedUmBin=0.1;
if strcmp(SeparationMode,'Intensity')
    ResWatershed=max([Res,[0.2;0.2;0.2]],[],2); % previously 0.4
    [Window,Wave1]=imdilateWindow_2([3;3;3],ResWatershed,1,'ellipsoid'); % previously 4µm cube
    for m=1:5
        Watershed=imfilter(Data3D,double(Window)/sum(Window(:)));
    end
    timeTable('Watershed');
    Watershed=max(Watershed(:))-Watershed;
    Watershed=uint16(watershed(Watershed,6));
    
elseif strcmp(SeparationMode,'Distance')
    [WatershedDistance]=distanceMat_4(~Axons,{'DistInOut'},Res,WatershedUmBin,1,0,0,'uint16',Res(1));
    if ShowIntermediateSteps==1; ex2Imaris_2(WatershedDistance,Application,'Axons_Distance'); end;
    timeTable('WatershedDistance');
    Watershed=uint16(watershed(4-WatershedDistance,6));
    timeTable('Watershed');
end
timeTable('Watershed');
Watershed(Axons==0)=0;
if ShowIntermediateSteps==1; ex2Imaris_2(Watershed,Application,'Axons_Watershed'); end;

Wave1=accumarray_9(Watershed,WatershedDistance,@max,[],[],[],{1,0});
Wave1=uint16(Wave1.Value1*2);
Wave1=Wave1(Watershed(Watershed>0));

AxonDiameter=Watershed;
AxonDiameter(Watershed>0)=Wave1;
AxonDiameter=uint16(AxonDiameter);
if ShowIntermediateSteps==1; ex2Imaris_2(AxonDiameter,Application,'Axons_AxonDiameter'); end;

%% segment individual axons
Version=struct('DistanceTransformation',1,'WatershedUmBin',WatershedUmBin);
imarisSaveHDFlock(FilenameTotal);
global Application; Application=openImaris_4(FilenameTotal,[],1,1);
tubeDetection(WatershedDistance,Res,Version);

% if ShowIntermediateSteps==1; ex2Imaris_2(Membership,Application,'Axons_Membership'); end;

if ShowIntermediateSteps==1; ex2Imaris_2(LocalMaxima,Application,'Axons_LocalMaxima'); end;

% Thinned=bwmorph(Axons,'thin',inf);


Skeleton=bwskel(logical(Axons));
[Adjacency,Nodes,Links]=Skel2Graph3D(Skeleton,0);

Nodes=struct2table(Nodes);
Links=struct2table(Links);
Links.NumPix=cellfun(@numel,Links.point);

for Link=1:size(Links,1)
    Links.Endpoint(Link,1:2)=Nodes.ep([Links.n1(Link),Links.n2(Link)]).';
end
Links.Endpoint=sum(Links.Endpoint,2);
    
% Links(Links.Endpoint>0 & Links.NumPix<=8,:)=[];
Links(Links.Endpoint==1,:)=[];

Wave1=struct('Connectivity',6,'ImageSize',Pix.','NumObjects',size(Links,1)); Wave1.PixelIdxList=Links.point.';
LinkMap=labelmatrix(Wave1);

if ShowIntermediateSteps==1; ex2Imaris_2(LinkMap,Application,'Axons_2'); end;




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

Graph2Skel3D








% Wave1=bwmorph3(Skeleton,'branchpoints');
if ShowIntermediateSteps==1; ex2Imaris_2(Skeleton,Application,'Skeleton'); end;
[~,Node,Link]=Skel2Graph3D(AxonMask,1);
    Skeleton2=Graph2Skel3D(Node,Link,size(AxonMask,1),size(AxonMask,2),size(AxonMask,3));
    
Discs=Axons==1 & Watershed==0;
% 3D connected component analysis
BW=bwconncomp(Discs,6);
DiscTable=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
DiscTable.Volume=DiscTable.NumPix*prod(Res);
Discs=labelmatrix(BW);
[DiscsDistance,DiscsMembership]=distanceMat_4(Discs,{'DistInOut';'Membership'},Res,0.1,1,0,0,'uint16',Res(1));
Wave1=imdilate(logical(Discs),strel('sphere',1));
Wave1(Discs~=0)=0;
Wave1=uint16(Wave1).*DiscsMembership;
if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Test'); end;
DiscTable.Surround=label2idx(Wave1).';

for Disc=1:size(DiscTable,1)
    Wave1=DiscTable.Surround{Disc};
    Wave1=unique(Watershed(Wave1));
    Wave1(Wave1==0,:)=[];
    DiscTable.Neighbors(Disc,1)={Wave1};
    DiscTable.NeighborCount(Disc,1)=size(Wave1,1);
%     if ismember(Disc,linspace(0,size(DiscTable,1),20))
%         Disc
%     end
end
Wave1=uint16(DiscTable.NeighborCount);
Wave1=Wave1(Discs(Discs>0));
Wave2=Discs;
Wave2(Discs>0)=Wave1; Wave2=uint16(Wave2);
if ShowIntermediateSteps==1; ex2Imaris_2(Wave2,Application,'Test'); end;
if ShowIntermediateSteps==1; ex2Imaris_2(Discs,Application,'Axons_Discs'); end;

% 3D connected component analysis
BW=bwconncomp(Axons,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<10,:)=[];
BW.PixelIdxList=Table.IdxList.';
BW.NumObjects=size(Table,1);
AxonMap=labelmatrix(BW);
if ShowIntermediateSteps==1; ex2Imaris_2(AxonMap,Application,'Axons_2'); end;

%% make a quality control image
[Data2D,Wave1]=max(Data3D.*uint16(~Outside),[],3);
Wave1=(Wave1(:)-1)*prod(size(Data2D))+(1:prod(size(Data2D))).';
AxonDiameter2D=Data2D; AxonDiameter2D(:)=AxonDiameter(Wave1(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',Data2D;'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorData',AxonDiameter2D;'ColorMinMax',[0;20];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_AxonDiameter.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));







return;
Colormap=repmat(linspace(0,1,65535).',[1,3]);
Image=ind2rgb(gray2ind(Iba12D,65535),Colormap);
if isempty(MicrogliaSoma)
    Microglia2D=uint16(max(Microglia,[],3));
else
    Microglia2D=uint16(max(MicrogliaFibers+2*uint8(MicrogliaSoma),[],3));
end
Colormap=[0,1,1;1,0,1];
Image(find(Microglia2D~=0))=Colormap(Microglia2D(Microglia2D~=0),1).*double(Iba12D(Microglia2D~=0))/65535;
Image(find(Microglia2D~=0)+prod(size(Image(:,:,1))))=Colormap(Microglia2D(Microglia2D~=0),2).*double(Iba12D(Microglia2D~=0))/65535;
Image(find(Microglia2D~=0)+2*prod(size(Image(:,:,1))))=Colormap(Microglia2D(Microglia2D~=0),3).*double(Iba12D(Microglia2D~=0))/65535;
[Path,Report]=getPathRaw([FilenameTotal,'_QualityControl_Microglia.tif']);
imwrite(Image,Path);

FctSpec.Microglia=2;
TotalResults.TimeStamp.Microglia=datenum(now);
timeTable('Microglia');
























%% out
% BW=struct;
BW.PixelIdxList=Table.IdxList.';
BW.NumObjects=size(Table,1);
Axons=labelmatrix(BW);






keyboard;

[~,Node,Link]=Skel2Graph3D(AxonMask,1);
Skeleton2=Graph2Skel3D(Node,Link,size(AxonMask,1),size(AxonMask,2),size(AxonMask,3));



return;
% Pix=Fileinfo.Pix{1};
% MaskContainer=zeros(Pix(1),Pix(2),Pix(3),'uint8');
% MaskIds=table;
ObjectTable=table;
ObjectList=Fileinfo.ObjectList{1}(:,1);
for m=1:size(ObjectList,1)
    %     AddMask=0;
    [SubStrings]=extractStringPart(ObjectList{m,1},'InterspersedNumbers');
    
    ObjectType=SubStrings.Content{1,1};
    if strcmp(ObjectType,'Axon') || strcmp(ObjectType,'Dendrite')
        ObjectId=SubStrings.Numeric(2,1);
    else
        continue;
    end
    Id=[ObjectType,num2str(ObjectId)];
    try
        Ind=strfind1(ObjectTable.Id,Id,1);
    catch
        Ind=0;
    end
    if Ind==0
        Ind=size(ObjectTable,1)+1;
        ObjectTable(Ind,{'Type','Num','Id'})={{ObjectType},ObjectId,{Id}};
    end
    
    if size(SubStrings,1)==2
        %         AddMask=1;
        ObjectTable.Data(Ind,1)={im2Matlab_3(Application,Id,1,'Surface')};
    else
        Wave1=SubStrings.Content{3,1};
        if strcmp(Wave1,'_Points')
            Wave1=getImarisMeasurementPoints(Application,[Id,'_Points']);
            ObjectTable.Synapses(Ind,1)={Wave1};
        elseif strcmp(Wave1,'_Dys')
            %             ObjectTable.Dystrophy(Ind,1)=1;
            ObjectTable.Dystrophy(Ind,1)={im2Matlab_3(Application,[Id,'_Dys1'],1,'Surface')};
            %             AddMask=1;
        end
    end
    %     if AddMask==1
    %         MaskContainer
    %     end
end
keyboard;




if FctSpec.Axon==1
    keyboard;
    % Axon reconstruction
    GFP=im2Matlab_3(FilenameTotal,'GFP');
    MetBlue=im2Matlab_3(FilenameTotal,'MetBlue');
    Outside=im2Matlab_3(FilenameTotal,'Outside');
    MetBlue(MetBlue<1000)=1000; % 70th percentile
    GFPcorr=single(GFP)./single(MetBlue)*1000;
    
    
    [GFPBackground,~]=sparseFilter(uint16(GFPcorr),Outside,Res,10000,[100;100;1],[5;5;Res(3)],90);
    
    AxonMask=GFPcorr>GFPBackground;
    
    %     Wave1=GFPcorr(Outside==0);
    %     Perc=prctile(Wave1,70);
    
    %     AxonMask=GFPcorr>Perc;
    
    BW=bwconncomp(AxonMask,6);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    Table.Volume=Table.NumPix*prod(Res(1:3));
    Table(Table.Volume<0.5,:)=[];
    AxonMask=zeros(Pix(1),Pix(2),Pix(3),'uint16');
    for m=1:size(Table,1)
        AxonMask(Table.IdxList{m})=1;
    end
    
    GFPcorr(Outside==1)=0;
    GFPcorr(AxonMask==0)=0;
    
    ex2Imaris_2(GFPcorr,FilenameTotal,'GFPcorr');
    
    Application=openImaris_4(FilenameTotal);
    J = struct;
    J.Application=Application;
    J.SurfaceName='AxonsStart';
    J.Channel='GFPcorr';
    J.Smooth=0.2;
    J.Background=10;
    J.LowerManual=200;
    J.SurfaceFilter=['"Volume" above 100 um^3'];
    generateSurface3(J);
    [AxonMask]=im2Matlab_3(Application,'AxonsStart',1,'Surface');
    
    %     Skeleton=Skeleton3D(AxonMask);
    %     OrigW=W;
    [~,Node,Link]=Skel2Graph3D(AxonMask,1);
    Skeleton2=Graph2Skel3D(Node,Link,size(AxonMask,1),size(AxonMask,2),size(AxonMask,3));
    %     W=OrigW; global W;
    %     evalin('caller','global W;');
    
    ex2Imaris_2(Skeleton2,FilenameTotal,'Skeleton2');
    Application=openImaris_4(FilenameTotal);
    Application.SetVisible(1);
    
    
    
    %     Perc=prctile(GFPcorr(:),99.9); % 90=7, 99=24
    %     GFPcorr=uint16(GFPcorr/Perc*(65535/2));
    %     [~,GFPcorr]=sparseFilter(GFPcorr,Outside,Res,10000,[5;5;1],[1;1;Res(3)],70,'Multiply1000');
    
    
    
    
    
    
    %     GFPcorr=single(GFP).*single(GFP)./single(MetBlue);
    %     GFPcorr(Outside==1)=0;
    %     Perc=prctile(GFPcorr(:),99); % 90=7, 99=24
    %     GFPcorr=uint16(GFPcorr/max(GFPcorr(:))*65535);
    %     imarisSaveHDFlock(Application,FilenameTotal);
    
    
    
    %     Wave1=5000/Perc;
    %     GFP=GFP*Wave1;
    
    
    
    [Fileinfo]=getImarisFileinfo(Application);
    ChannelList=varName2Col(Fileinfo.ChannelList{1});
    %     Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,ChannelList.GFPcorr-1,20);
    
    J = struct;
    J.Application=Application;
    J.SurfaceName='AxonsStart';
    J.Channel='GFPcorr';
    J.Smooth=0.2;
    J.Background=3;
    J.LowerManual=2000;
    J.SurfaceFilter=['"Volume" above 1 um^3'];
    generateSurface3(J);
    
    % save and finish
    Application.FileSave(PathRaw,'writer="Imaris5"');
    quitImaris(Application);
    FctSpec.Axon=1;
    %     Wave1=variableSetter_2(W.G.T.F{W.Task,1}.DystrophyDetection{W.File},{'Do','Fin';'Step','1'});
    %     iFileChanger('W.G.T.F{W.Task,1}.DystrophyDetection{W.File}',Wave1);
    
end