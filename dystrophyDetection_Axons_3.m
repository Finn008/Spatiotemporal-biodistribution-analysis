function [Data3D,DystrophyDiameter,Skeleton,AxonData]=dystrophyDetection_Axons_3()
timeTable('Start');
AxonChannelName='GFPM';
global ChannelTable;
global ShowIntermediateSteps;
ShowIntermediateSteps=1;
[Fileinfo,Ind,PathRaw]=getFileinfo_2(ChannelTable.SourceFilename{'GFPM'});
Res=Fileinfo.Res{1};

Settings={  '','SpFiPrctile','SpFiSubtrBackgr';...
    'GFPM',80,2500;...
    };
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(ChannelTable.SourceFilename{'GFPM'},ChannelTable.SourceChannelName{'GFPM'});
Pix=size(Data3D).';
if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=im2Matlab_3(ChannelTable.TargetFilename{'Outside'},'Outside');
else
    Outside=zeros(size(Data3D),'uint8');
end

% depth correction
[~,Data3D]=percentileFilter3D_3(Data3D,Settings{AxonChannelName,'SpFiPrctile'}{1},Res,[10;10;Res(3)],Outside,Settings{AxonChannelName,'SpFiSubtrBackgr'}{1},[200;200;1]);
Data3D(Outside==1)=0;
if ShowIntermediateSteps==1
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
    ex2Imaris_2(Data3D,Application,'Axons_PercentileFilter',1,Res);
else
    ShowIntermediateSteps=0;
end

timeTable('Data3DAfterpercentileFilter3D');

Threshold=prctile(Data3D(Outside==0),96)*2;
Axons=Data3D>Threshold;
% 3D connected component analysis
BW=bwconncomp(Axons,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<0.1,:)=[];
Axons=zeros(Pix.','uint8');
Axons(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Axons,Application,'Axons_1'); end;
% fill holes
BW=bwconncomp(~Axons,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume>5,:)=[];
Axons(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Axons,Application,'Axons_2'); end;
% [DistanceFromAxons]=distanceMat_4(~Axons,{'DistInOut'},Res,0.1,1,0,0,'uint16',0.2);

% % [LocalPerc1]=percentileFilter3D_3(Data3D,90,Res,[0.5;0.5;0.5],logical(Outside),0,[5;5;5]); % from 5^3 only 1.8^3 remain
% % Axons(Data3D<LocalPerc1*0.5)=0;

% if ShowIntermediateSteps==1; ex2Imaris_2(Axons,Application,'Axons_3'); end;
% Axons(DistanceFromAxons>=5)=1;
% [LocalPerc2]=percentileFilter3D_3(Data3D,95,Res,[0.5;0.5;0.5],logical(Outside+Axons),0,[5;5;5]);

% 3D connected component analysis
BW=bwconncomp(Axons,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<0.02,:)=[];
Axons=zeros(Pix.','uint16');
Axons(cell2mat(Table.IdxList))=1;
% % 
% DistanceFromAxons

if ShowIntermediateSteps==1; ex2Imaris_2(Axons,Application,'Axons_3'); end;
% if ShowIntermediateSteps==1; ex2Imaris_2(LocalPerc1,Application,'Axons_Test'); end;
% if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Axons_Test2'); end;

%% segment individual axons
[~,AxonTable1,AxonTable2]=tubeDetection_2(logical(Axons),Res,struct('FindConnectedLinks',1));
AxonTable2Sel=AxonTable2(ismember(AxonTable2.SuperFamily,AxonTable1.SuperFamily(AxonTable1.DistanceMax>30)),:);
AxonTable3=AxonTable1(AxonTable1.DistanceMax>30,:);
Skeleton=zeros(Pix.','uint16'); Skeleton(AxonTable2Sel.LinIdx)=AxonTable2Sel.SuperFamily;
if ShowIntermediateSteps==1; ex2Imaris_2(Skeleton,Application,'Axons_Skeleton'); end;
imarisSaveHDFlock(Application);
Application=openImaris_4(Application,[],1,1);

[DistanceFromAxons]=distanceMat_4(Axons,{'DistInOut'},Res,0.1,1,1,100,'uint16',Res(1));

for Axon=1:size(AxonTable3,1)
    Wave1=AxonTable3.Path{Axon,1};
    Wave1.Diameter=(101-double(DistanceFromAxons(Wave1.LinIdx)))/10*2;
    AxonTable3.Path{Axon,1}=Wave1;
%     Wave1.Diameter=double(DistanceFromAxons(Wave1.LinIdx));
end

%% unsorted
[~,MembershipIdx]=bwdist(logical(Skeleton),'quasi-euclidean');
[DistanceFromSkeleton,Membership]=distanceMat_4(Skeleton,{'DistInOut';'Membership'},Res,0.1,1,0,0,'uint16');
AxonTable2.AxonDiameter=double(101-DistanceFromAxons(AxonTable2.LinIdx))/10*2;
Wave1=zeros(Pix.','uint16'); Wave1(AxonTable2.LinIdx)=AxonTable2.AxonDiameter*10;
if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Axons_AxonDiameter2'); end;
AxonMap=Membership; AxonMap(DistanceFromAxons>100)=0;
if ShowIntermediateSteps==1; ex2Imaris_2(AxonMap,Application,'Axons_AxonMap'); end;


%% identify boutons and dystrophies
% identify individual boutons and dystrophies and match their position along the axon
% Threshold=prctile(Data3D(Outside==0),97);
% Axons=Data3D>Threshold;
% 
% BW=bwconncomp(Axons,6);
% Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
% Table.Volume=Table.NumPix*prod(Res);
% Table(Table.Volume<0.1,:)=[];
% Axons=zeros(Pix.','uint8');
% Axons(cell2mat(Table.IdxList))=1;
% 
% [LocalPerc2]=percentileFilter3D_3(Data3D,95,Res,[0.5;0.5;0.5],logical(Outside+Axons),0,[5;5;5]);
% Axons(Data3D<LocalPerc2*4)=0;

% ResCalc=max([Res,[0.8;0.8;0.8]],[],2);
Data3D_2=double(Data3D);
Window=imdilateWindow_2([0.8;0.8;0.8],Res,1,'ellipsoid');
for m=1:2
    Data3D_2(Axons==0)=0;
    Data3D_2=imfilter(Data3D_2,double(Window)/sum(Window(:)));
end
% 'Imdilation',1,,'ResCalc',Res(1)
% DystrophyMap=imopen(Axons,imdilateWindow_2([0.3;0.3],Res,1));
% if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyMap,Application,'Test'); end;
Version=struct('SeedImpact','Radius','Thresholds','Axons','WatershedUmBin',0.1,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',2,'DistanceDimensionality','XY');
[DystrophyMap,LocalMaxima,Wave1,BoutonTable]=watershedSegmentation_2(Axons,Version,Res,Data3D_2);
% BoutonTable=sortrows(BoutonTable,'Membership2');
if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyMap,Application,'Axons_Dystrophies'); end;
BoutonTable.Diameter2=uint16(BoutonTable.Diameter*100);
DystrophyDiameter=DystrophyMap;
DystrophyDiameter(DystrophyMap>0)=BoutonTable.Diameter2(DystrophyMap(DystrophyMap>0));
if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyDiameter,Application,'Axons_DystrophyDiameter'); end;

BoutonTable2=BoutonTable(:,{'IdxList';'NumPix';'XYZpix';'XYZum';'Volume';'WatershedDistance';'Diameter'});

for Bouton=1:size(BoutonTable2,1)
    Wave1=unique(Skeleton(BoutonTable2.IdxList{Bouton}));
    BoutonTable2.AxonID(Bouton,1)=max(Wave1);
end
BoutonTable2(BoutonTable2.AxonID==0,:)=[];

[PlaqueDistance]=im2Matlab_3(ChannelTable.TargetFilename{'MetBlue'},'DistInOut');
[PlaqueMap]=im2Matlab_3(ChannelTable.TargetFilename{'MetBlue'},'Membership');
AxonPosition=zeros(Pix.','uint16');
AxonPosition(AxonTable2Sel.LinIdx)=AxonTable2Sel.Distance*10;

for Bouton=1:size(BoutonTable2,1)
    IdxList=BoutonTable2.IdxList{Bouton};
    Wave1=AxonPosition(IdxList); BoutonTable2.AxonPosition(Bouton,1)=mean(Wave1(Wave1>0))/10;
    [Wave1,Wave2]=min(PlaqueDistance(IdxList));
    BoutonTable2.PlaqueID(Bouton,1)=PlaqueMap(IdxList(Wave2));
    BoutonTable2.PlaqueDistance(Bouton,1)=Wave1-50;
end

AxonData=struct; AxonData.AxonTable=AxonTable3; AxonData.BoutonTable=BoutonTable2;

%% make quality control images
global NameTable;
FilenameTotal=NameTable.Filename{'FilenameTotal'};

% SkeletonMap
Wave1=Data3D; Wave1(AxonTable2Sel.LinIdx)=65535;
[Data2D,MaxInd]=max(Wave1.*uint16(~Outside),[],3);
MaxInd=(MaxInd(:)-1)*prod(size(Data2D))+(1:prod(size(Data2D))).';
AxonMap=Membership; AxonMap(DistanceFromSkeleton>0)=0;
AxonMap2D=Data2D; AxonMap2D(:)=AxonMap(MaxInd(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',Data2D;'Colormap','RandomHeatmap';'IntensityMinMax','Norm100';'ColorData',AxonMap2D;'ColorMinMax',[0;65535];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_AxonMap.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));

% % AxonMap
% Wave1=Data3D; Wave1(AxonTable2Sel.LinIdx)=65535;
% [Data2D,MaxInd]=max(Wave1.*uint16(~Outside),[],3);
% MaxInd=(MaxInd(:)-1)*prod(size(Data2D))+(1:prod(size(Data2D))).';
% AxonMap=Membership; AxonMap(DistanceFromAxons>100 & DistanceFromSkeleton>10)=0;
% AxonMap2D=Data2D; AxonMap2D(:)=AxonMap(MaxInd(:));
% 
% ChannelInfo=table;
% Wave1={'Version',7.1;'IntensityData',Data2D;'Colormap','RandomHeatmap';'IntensityMinMax','Norm100';'ColorData',AxonMap2D;'ColorMinMax',[0;65535];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
% ChannelInfo.Res(:,1)={[]};
% Path2file=getPathRaw([FilenameTotal,'_QualityControl_AxonMap.tif']);
% imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));

% BoutonMap
[Data2D,MaxInd]=max(Data3D.*uint16(~Outside),[],3);
MaxInd=(MaxInd(:)-1)*prod(size(Data2D))+(1:prod(size(Data2D))).';
Wave2=DystrophyMap; Wave2(Wave2>0)=BoutonTable.Diameter(Wave2(Wave2>0))*10;
DiameterMap2D=Data2D; DiameterMap2D(:)=Wave2(MaxInd(:));
ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',Data2D;'Colormap','Spectrum2';'IntensityMinMax','Norm100';'ColorData',DiameterMap2D;'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_Dystrophydiameter.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));

% Distance along individual axons
[Data2D,MaxInd]=max(Data3D.*uint16(~Outside),[],3);
MaxInd=(MaxInd(:)-1)*prod(size(Data2D))+(1:prod(size(Data2D))).';

Wave2=zeros(Pix.','uint16');
Wave2(AxonTable2Sel.LinIdx)=AxonTable2Sel.Distance*10;
Wave2=Wave2(MembershipIdx);
Wave2(DistanceFromAxons>100)=0;
DistanceMap2D=Data2D; DistanceMap2D(:)=Wave2(MaxInd(:));

ChannelInfo=table;
Wave1={'Version',7.1;'IntensityData',Data2D;'Colormap','Spectrum2';'IntensityMinMax','Norm100';'ColorData',DistanceMap2D;'ColorMinMax',[0;900];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
ChannelInfo.Res(:,1)={[]};
Path2file=getPathRaw([FilenameTotal,'_QualityControl_AxonDistance.tif']);
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));
% keyboard;