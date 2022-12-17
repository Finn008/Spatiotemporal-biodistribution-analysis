function [Blood]=dystrophyDetection_Blood()

timeTable('Start');
BloodChannelName='XrayPhase';
global ChannelTable; global NameTable;

[Fileinfo,Ind,PathRaw]=getFileinfo_2(ChannelTable.SourceFilename{BloodChannelName});
Res=Fileinfo.Res{1};

[Data3D]=im2Matlab_3(ChannelTable.SourceFilename{BloodChannelName},ChannelTable.SourceChannelName{BloodChannelName});
Pix=size(Data3D).';
%% detect outside
Path2file=getPathRaw([NameTable.Filename{'FilenameImarisLoadTif'},'_Cropped.tif']);
Outside2D=imread(Path2file);
Outside2D=Outside2D(:,:,1)<128;
Ydim=min(Outside2D,[],1).';
Xdim=min(Outside2D,[],2);
Cut=[find(Xdim==0,1),size(Outside2D,1)-find(flip(Xdim)==0,1);find(Ydim==0,1),size(Outside2D,2)-find(flip(Ydim)==0,1)];
Outside2D=Outside2D(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2));
Outside=repmat(Outside2D,[1,1,Pix(3)]);

global ShowIntermediateSteps; ShowIntermediateSteps=1;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    ResInter=[10;10;10];
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
    Wave1=interpolate3D_3(Outside,[],Res,ResInter);
    PixInter=size(Wave1).';
    ex2Imaris_2(Wave1,Application,'Xray_Outside1',1,Res);
    Application=openImaris_4(Application,[],1,1);
else
    ShowIntermediateSteps=0;
end
[~,Data3Dcorr]=percentileFilter3D_4(Data3D,60,Res,[10;10;Res(3)],Outside2D,5000,[50;50;Res(3)],[],[],{'OrigData'});
Min=prctile(Data3Dcorr(Outside==0),2);
Max=prctile(Data3Dcorr(Outside==0),99.9);
Data3Dcorr=(Data3Dcorr-Min)*(65535/(Max-Min));
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(uint16(Data3Dcorr),PixInter),Application,'Xray_Data3Dcorr',1,Res); end;

% Threshold=prctile_2(Data3Dcorr(Outside==0),(0:5:100).');
Threshold=prctile_2(Data3Dcorr(Outside==0),95); % previously 2*90th
% Wave1=Outside(repmat(Outside2D,[1,1,Pix(3)])==0);
% Threshold=prctile(Wave1(:),50)*1.3; 
ResCalc=[10;10;10];
Wave1=interpolate3D_3(Data3Dcorr>Threshold,[],Res,ResCalc);
[~,Distance,BasinMap]=basinDetection(Wave1,[],ResCalc,struct('BasinThreshold',100,'ThresholdDistanceMean',50,'ShowBasinMap','DistanceMean','ResCalc',ResCalc(1),'DistanceRes',1,'Border2void',1));

BasinMap=imdilate(BasinMap>=50,imdilateWindow_2([50;50;50],ResCalc,1));
% imdilateWindow_2([50;50;50],ResCalc,1)
Wave1(BasinMap==1)=0;
[~,Distance,BasinMap]=basinDetection(Wave1,[],ResCalc,struct('BasinThreshold',100,'ThresholdDistanceMean',50,'ShowBasinMap','DistanceMean','ResCalc',ResCalc(1),'DistanceRes',1,'Border2void',1));
% if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(BasinMap,PixInter),Application,'Test2',1,Res); end;
Outside=interpolate3D_3(BasinMap>=50,Pix);
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Outside,PixInter),Application,'Xray_Outside2',1,Res); end;
ex2Imaris_2(Outside,ChannelTable.TargetFilename{'XrayPhase'},'Outside',1,Res,'uint16');

%% detect blood
[Fileinfo,Ind,PathRaw]=getFileinfo_2(ChannelTable.SourceFilename{BloodChannelName});
Res=Fileinfo.Res{1};

% ex2Imaris_2(uint16(Data3D),NameTable.Filename{'FilenameTotal'},'XrayPhase',1,Res);
% [Data3D]=im2Matlab_3(ChannelTable.TargetFilename{BloodChannelName},ChannelTable.SourceChannelName{BloodChannelName});
% Pix=size(Data3D).';
% [Outside]=uint8(im2Matlab_3(ChannelTable.TargetFilename{'Outside'},'Outside'));
% Outside(:)=0;
Threshold=prctile(Data3Dcorr(Outside==0),50)*2;

Exclude=Outside; Exclude(Data3Dcorr>Threshold)=1;

[~,Data3Dcorr]=percentileFilter3D_4(Data3D,60,Res,[10;10;Res(3)],Exclude,5000,[50;50;Res(3)],[],[],{'OrigData'});
Min=prctile(Data3Dcorr(Data3Dcorr~=0),1);
Max=prctile(Data3Dcorr(:),99.99);
Data3Dcorr=(Data3Dcorr-Min)*(65535/(Max-Min));
Data3Dcorr=uint16(Data3Dcorr);
Data3Dcorr(Outside==1)=0;
ex2Imaris_2(Data3Dcorr,NameTable.Filename{'FilenameTotal'},'XrayPhase',1,Res);
Data3D=Data3Dcorr; clear Data3Dcorr;

if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Data3D,PixInter),Application,'Xray_Phase1'); end;
%% detect blood
Threshold=prctile(Data3D(Outside==0),95); % previously 80, 50:38384, 80:42085, 90:44821, 95:49085, Target:55000
Blood=Data3D>Threshold;
Blood(Outside==1)=0;
ex2Imaris_2(Blood,NameTable.Filename{'FilenameTotal'},'Blood_1',1,Res);

% 3D connected component analysis
BW=bwconncomp(Blood,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<10*10*50,:)=[]; % 10*10*100
Blood=zeros(Pix.','uint8');
Blood(cell2mat(Table.IdxList))=1;
ex2Imaris_2(Blood,NameTable.Filename{'FilenameTotal'},'Blood_3',1,Res);
% if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Blood,PixInter),Application,'Blood3'); end;

BasinThreshold=[26]; % [4;6;8;10;12;14]; % previously 20
for m=1:size(BasinThreshold,1)
    [~,Distance,BasinMap,BasinTable,Basins]=basinDetection(Blood,[],Res,struct('BasinThreshold',BasinThreshold(m),'ThresholdDistanceMean',12,'ShowBasinMap','DistanceMean','ResCalc',Res(1),'DistanceRes',1,'Border2void',1));
    ex2Imaris_2(BasinMap,NameTable.Filename{'FilenameTotal'},['BasinMap3_Distance',num2str(BasinThreshold(m))],1,Res);
end
ex2Imaris_2(Distance,NameTable.Filename{'FilenameTotal'},'Distance',1,Res);
% BasinThreshold=[14;16;18;20;22;24]; % previously 20
% for m=1:size(BasinThreshold,1)
%     [~,Distance,BasinMap]=basinDetection(Blood,Outside,Res,struct('BasinThreshold',BasinThreshold(m),'ThresholdDistanceMean',12,'ShowBasinMap','DistanceMean','ResCalc',Res(1),'DistanceRes',1));
%     ex2Imaris_2(BasinMap,NameTable.Filename{'FilenameTotal'},['BasinMap_Distance',num2str(BasinThreshold(m))],1,Res);
% end
% ex2Imaris_2(Distance,NameTable.Filename{'FilenameTotal'},'Distance',1,Res);

% Basins=Basins(12:1259,12:1259,12:777);
% keyboard;
% [OrigLumen]=im2Matlab_3(NameTable.Filename{'FilenameTotal'},'BasinMap3_Distance26');
Border3D=imdilate(~logical(BasinMap),strel('sphere',1));
Wave2=accumarray_10(Basins,Border3D,@sum); Wave2(Wave2.Roi1==0,:)=[];
BasinTable.Border(Wave2.Roi1,1)=Wave2.Value1;



% determine outer layer of each Basin
Uncovered3D=imerode(~logical(BasinMap<15 & BasinMap>0),strel('sphere',1));
Uncovered3D(Blood==1)=0;
Uncovered3D=imdilate(Uncovered3D,strel('sphere',2));
Uncovered3D(Border3D==0)=0;

Wave2=accumarray_10(Basins,Uncovered3D,@sum); Wave2(Wave2.Roi1==0,:)=[];
BasinTable.UnCoveredBorder(Wave2.Roi1,1)=Wave2.Value1;
% BasinTable.Test=BasinTable.Border-BasinTable.UnCoveredBorder;
% min(BasinTable.Test)
BasinTable.BloodCoverage=(BasinTable.Border-BasinTable.UnCoveredBorder)./BasinTable.Border*100;
% min(BasinTable.BloodCoverage)

Wave1=uint16(ceil(BasinTable.BloodCoverage*100));
Wave1=Wave1(Basins(Basins>0));
BloodCoverage3D=Basins;
BloodCoverage3D(Basins>0)=Wave1;
ex2Imaris_2(BloodCoverage3D,NameTable.Filename{'FilenameTotal'},'BloodCoverage3D',1,Res);
ex2Imaris_2(Border3D,NameTable.Filename{'FilenameTotal'},'Border3D',1,Res);
ex2Imaris_2(Uncovered3D,NameTable.Filename{'FilenameTotal'},'Uncovered3D',1,Res);
ex2Imaris_2(Basins,NameTable.Filename{'FilenameTotal'},'Basins',1,Res);
% imarisSaveHDFlock(NameTable.Filename{'FilenameTotal'}); Application=openImaris_4(NameTable.Filename{'FilenameTotal'},[],1,1);

OrigBlood=Blood;
Blood(BloodCoverage3D>4000)=1;
Blood=imclose(Blood,strel('sphere',1));

% fill holes
BW=bwconncomp(~Blood,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume>8^3,:)=[];
Blood(cell2mat(Table.IdxList))=1;
ex2Imaris_2(Blood,NameTable.Filename{'FilenameTotal'},'Blood_4',1,Res);
imarisSaveHDFlock(NameTable.Filename{'FilenameTotal'}); Application2=openImaris_4(NameTable.Filename{'FilenameTotal'},[],1,1);
%% segment individual vessels
[Skeleton,TubeLinks,TubeTable]=tubeDetection_2(logical(Blood),Res);
[~,MembershipIdx]=bwdist(logical(Skeleton),'quasi-euclidean');

[DistanceFromBlood]=distanceMat_4(Blood,{'DistInOut'},Res,1,1,1,100,'uint16');

BloodDiameter=DistanceFromBlood(MembershipIdx);
BloodDiameter=(100-BloodDiameter)*2;
BloodDiameter(Blood==1 & BloodDiameter==0)=1;
BloodDiameter(Blood==0)=0;

% keyboard;
% % ex2Imaris_2(Data3D,NameTable.Filename{'FilenameTotal'},'XrayPhase',1,Res);
% % ex2Imaris_2(Outside,NameTable.Filename{'FilenameTotal'},'Outside',1,Res);
ex2Imaris_2(Blood,NameTable.Filename{'FilenameTotal'},'Blood',1,Res);
ex2Imaris_2(Skeleton,NameTable.Filename{'FilenameTotal'},'Skeleton',1,Res);
ex2Imaris_2(BloodDiameter,NameTable.Filename{'FilenameTotal'},'BloodDiameter',1,Res);
imarisSaveHDFlock(NameTable.Filename{'FilenameTotal'});
Application=openImaris_4(NameTable.Filename{'FilenameTotal'},[],1,1);

keyboard;

AxonTable2.AxonDiameter=double(101-DistanceFromAxons(AxonTable2.LinIdx))/10*2;
Wave1=zeros(Pix.','uint16'); Wave1(AxonTable2.LinIdx)=AxonTable2.AxonDiameter*10;
if ShowIntermediateSteps==1; ex2Imaris_2(Wave1,Application,'Axons_AxonDiameter2'); end;
AxonMap=Membership; AxonMap(DistanceFromAxons>100)=0;
if ShowIntermediateSteps==1; ex2Imaris_2(AxonMap,Application,'Axons_AxonMap'); end;



%% identify boutons and dystrophies
% identify individual boutons and dystrophies and match their position along the axon
Threshold=prctile(Data3D(Outside==0),97);
Blood=Data3D>Threshold;

% 3D connected component analysis
BW=bwconncomp(Blood,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);
Table(Table.Volume<0.1,:)=[];
Blood=zeros(Pix.','uint8');
Blood(cell2mat(Table.IdxList))=1;

[LocalPerc2]=percentileFilter3D_3(Data3D,95,Res,[0.5;0.5;0.5],logical(Outside+Blood),0,[5;5;5]);
Blood(Data3D<LocalPerc2*4)=0;

ResCalc=max([Res,[0.8;0.8;0.8]],[],2);
Data3D_2=double(Data3D);
Window=imdilateWindow_2([1;1;1],Res,1,'ellipsoid'); % previously 4µm cube
for m=1:5
    Data3D_2(Blood==0)=0;
    Data3D_2=imfilter(Data3D_2,double(Window)/sum(Window(:)));
end
% 'Imdilation',1,,'ResCalc',Res(1)
DystrophyMap=imopen(Blood,imdilateWindow_2([0.3;0.3],Res,1));
Version=struct('SeedImpact','Radius','Thresholds','Axons','WatershedUmBin',0.1,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',2,'DistanceDimensionality','XY');
[DystrophyMap,LocalMaxima,Wave1,BoutonTable]=watershedSegmentation_2(DystrophyMap,Version,Res,Data3D_2);
% BoutonTable=sortrows(BoutonTable,'Membership2');
if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyMap,Application,'Axons_Dystrophies'); end;


%% make a quality control image
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
imageGenerator_2(ChannelInfo,Path2file,[],struct('Rotate',-90));% if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Blood,PixInter),Application,'Blood1'); end;

% % BasinThreshold=[10;11;12;13;14]; % [4;6;8;10;12;14]; % previously 20
% % for m=1:size(BasinThreshold,1)
% %     [~,Distance,BasinMap]=basinDetection(Blood,[],Res,struct('BasinThreshold',BasinThreshold(m),'ThresholdDistanceMean',12,'ShowBasinMap','DistanceMean','ResCalc',Res(1),'DistanceRes',1,'Border2void',1));
% %     ex2Imaris_2(BasinMap,NameTable.Filename{'FilenameTotal'},['BasinMap2_Distance',num2str(BasinThreshold(m))],1,Res);
% % end
% % ex2Imaris_2(Distance,NameTable.Filename{'FilenameTotal'},'Distance',1,Res);

% % % [LocalPerc1]=percentileFilter3D_3(Data3D,90,Res,[8;8;8],logical(Outside),0,[50;50;50]); % from 5^3 only 1.8^3 remain
% % % Blood(Data3D<LocalPerc1)=0;
% % % Blood(Outside==1)=0;
% % % ex2Imaris_2(Blood,NameTable.Filename{'FilenameTotal'},'Blood_2',1,Res);
% % % if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Blood,PixInter),Application,'Blood2'); end;