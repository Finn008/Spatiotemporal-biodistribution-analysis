function [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,Plaque,Output]=wholeSliceQuantification_PlaqueDetection_9(Plaque,Outside,Res,Settings)
% global W;
global ShowIntermediateSteps;
ShowIntermediateSteps=0;
timeTable('Start wholeSliceQuantification_PlaqueDetection');
PlaqueChannelName=Settings.Name{1};

% define resolution levels
ResLevels=table;
ResLevels('Orig',{'Res','Pix'})={{Res},{size(Plaque).'}};
ResLevels{'Outside',{'Pix'}}={size(Outside).'};
ThresholdLargeFile=1000*1000*1000; % uint16: 2GB
if prod(ResLevels{'Orig','Pix'}{1})>ThresholdLargeFile
    ResLevels{'ShowIntermediate','Res'}={[5;5;5]};
    ResLevels{'percentileFilter3D','Res'}={[10;10;5]};
    ResLevels{'prctile','Res'}={[5;5;5]};
    TilingVoxelNumber=10^9;
    PlaqueMinimalVolume=7^3;
else
    ResLevels{'ShowIntermediate','Res'}={Res};
    ResLevels{'percentileFilter3D','Res'}={[2;2;Res(3)]};
    ResLevels{'prctile','Res'}={Res};
    TilingVoxelNumber=10^9; %150000000
    PlaqueMinimalVolume=3^3;
end
for m=1:size(ResLevels,1)
    if isempty(ResLevels.Res{m})
        ResLevels.Res{m}=ResLevels{'Orig','Res'}{1}.*ResLevels{'Orig','Pix'}{1}./ResLevels.Pix{m};
    end
    if isempty(ResLevels.Pix{m})
        ResLevels.Pix{m}=uint16(ResLevels{'Orig','Pix'}{1}.*ResLevels{'Orig','Res'}{1}./ResLevels.Res{m});
    end
end
Pix=ResLevels{'Orig','Pix'}{1};

if ShowIntermediateSteps==1 % display low resolution version of selected data
    global ChannelTable;
    FilenameTotalCrude=ChannelTable.TargetFilename{'ShowIntermediate'};
    PixInter=ResLevels{'ShowIntermediate','Pix'}{1};
end

Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Plaque,PixInter),FilenameTotalCrude,Settings.Name{1},1,ResLevels.Res{'ShowIntermediate'}); end;

% load Plaque 1
[~,Plaque]=percentileFilter3D_4(Plaque,70,Res,ResLevels.Res{'percentileFilter3D'},Outside,400,[200;200;1],1,[],{'OrigData'});
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Plaque,PixInter),FilenameTotalCrude,'Plaque_PercentileFilter3D'); end;


%% core plaque quantification
% defined as contiguous structures of more than 2 µm^3 with intensity 2*90th
% load Plaque 2
Plaque2=interpolate3D_3(Plaque,ResLevels.Pix{'prctile'});
Background=prctile(Plaque2(interpolate3D_3(Outside,ResLevels.Pix{'prctile'})==0),90);
clear Plaque2;
Threshold=Background*Settings.Core2BackgroundRatio{1};

PlaqueCore=uint8((Plaque>=Threshold) & interpolate3D_3(Outside,Pix)==0); % previously factor 2
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(uint16(single(Plaque)./single(Background)*1000),PixInter),FilenameTotalCrude,'PlaqueBackgroundRatio'); end;
ShowLarge=0;
if ShowLarge==1
    %     ex2Imaris_2(uint16(divideInt_2(Plaque,Background,1000)),ChannelTable.SourceFilename{'CongoRed'},'PlaqueBackgroundRatio');
    ex2Imaris_2(uint16((single(Plaque)/single(Background)*1000)),ChannelTable.SourceFilename{'CongoRed'},'PlaqueBackgroundRatio');
end
BW=bwconncomp(PlaqueCore,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.Volume>=2,:);
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(PlaqueData,1);
PlaqueCore(:)=0;
PlaqueCore(cell2mat(PlaqueData.PixelIdxList))=1;
% PlaqueCore=labelmatrix(BW);
clear BW;
timeTable('PlaqueCore');
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueCore,PixInter),FilenameTotalCrude,'PlaqueCore'); end;

% calculate distance from core to define regions excluded from BackgroundSubtraction
% DistanceFromCore=distanceMat_4(PlaqueCore,{'DistInOut'},Res,1,1,1,50,'uint16',0.8);

% % if prod(Res)<1
% %     keyboard;
% %     ResCalc=max([2,min(Res)]);
% %     Wave1=interpolate3D_3(PlaqueCore,[],Res,ResCalc,@max,1);
% % else
% %     % Core is set to 2 and around to 1
% %     PlaqueCore=PlaqueCore+imdilate(PlaqueCore,imdilateWindow_2(repmat(Settings.DistanceFromCoreThreshold{1}*2,[3,1]),Res,1,'ellipsoid'));
% %     %     PlaqueCore=PlaqueCore+interpolate3D_3(Wave1,Pix);
% % end
ResCalc=max([1,max(Res)]);
TilingSettings={'Res','VoxelNumber','Overlap';ResCalc,TilingVoxelNumber,10}; TilingSettings=array2table(TilingSettings(2:end,:),'VariableNames',TilingSettings(1,:));
% DistanceFromCore=tiledDistanceTransformation_2(PlaqueCore,Res,Wave1);
PlaqueCore=distanceMat_4(PlaqueCore,{'DistInOut'},Res,1,1,0,0,'uint8',ResCalc,[],TilingSettings);
DistanceFromCore=PlaqueCore;
clear PlaqueCore;
% DistanceFromCore=distanceMat_4(PlaqueCore,{'DistInOut'},Res,1,1,0,0,'uint16',max([min(Res);0.8]));
% [DistInOut,Membership,Dist2Border]=distanceMat_4(Data3D,Output,Res,UmBin,OutCalc,InCalc,ZeroBin,DistanceBitType,ResCalc,Dimensionality)
timeTable('PlaqueCoreDilation');
% if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(DistanceFromCore,PixInter),FilenameTotalCrude,'DistanceFromCore'); end;

%% calculate PlaqueMap
% Exclude=interpolate3D_3(Outside,Pix);
% Exclude=interpolate3D_3(Outside,size(PlaqueCore).').*uint8(PlaqueCore>0);

% Exclude(DistanceFromCore<Settings.DistanceFromCoreThreshold{1}+50)=1;
% Exclude(DistanceFromCore<Settings.DistanceFromCoreThreshold{1})=1;

% DistanceFromCore<Settings.DistanceFromCoreThreshold{1}
ResCalc=[repmat(max([min(Res(1:2));0.8]),[2,1]);Res(3)];

% CalcSettings=struct('Percentile',98,'Window',[35;35;Res(3)],'BackgroundCorrection',[],'ReplaceWithClosest',1);
TilingSettings={'Res','VoxelNumber','Overlap';ResCalc,TilingVoxelNumber,10}; TilingSettings=array2table(TilingSettings(2:end,:),'VariableNames',TilingSettings(1,:));
PlaqueLocalPrc=percentileFilter3D_4(Plaque,98,Res,ResCalc,interpolate3D_3(Outside,size(DistanceFromCore).').*uint8(DistanceFromCore<Settings.DistanceFromCoreThreshold{1}),[],[35;35;Res(3)],1,TilingSettings,{'DataPerc'});
% TilingSettings={'Res','VoxelNumber','Overlap';max([1,min(Res)]),TilingVoxelNumber,10}; TilingSettings=array2table(TilingSettings(2:end,:),'VariableNames',TilingSettings(1,:));
% PlaqueLocalPrc=tiledProcessing_1(Plaque,Exclude,Res,Wave1,'percentileFilter3D',CalcSettings);
% PlaqueLocalPrc=percentileFilter3D_3(Plaque,98,Res,ResCalc,Exclude,[],[35;35;Res(3)],1);

% clear Exclude;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueLocalPrc,PixInter),FilenameTotalCrude,'PlaqueLocalPrc'); end;

timeTable('PlaqueLocalPrc');
% PlaqueMap=(Plaque>PlaqueLocalPrc & interpolate3D_3(Outside,Pix)==0 & DistanceFromCore<=60) | DistanceFromCore<=50;
PlaqueMap=(Plaque>PlaqueLocalPrc & interpolate3D_3(Outside,Pix)==0 & DistanceFromCore>0) | DistanceFromCore==0;
% PlaqueMap=(Plaque>PlaqueLocalPrc & interpolate3D_3(Outside,Pix)==0 & PlaqueCore>0) | PlaqueCore==2;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueMap,PixInter),FilenameTotalCrude,'PlaqueMap_1'); end;
clear PlaqueLocalPrc;

% remove plaques that have no plaque core or are smaller than 3µm diameter
BW=bwconncomp(PlaqueMap,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueMap=labelmatrix(BW);
clear BW;
% Wave1=PlaqueMap(DistanceFromCore<=50);
% Wave1=PlaqueMap(PlaqueCore==2);
Wave1=PlaqueMap(DistanceFromCore==0);

clear DistanceFromCore;
% clear PlaqueCore;
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
PlaqueData=PlaqueData(Wave2,:);
PlaqueData=PlaqueData(PlaqueData.Volume>=PlaqueMinimalVolume,:);
PlaqueData=PlaqueData(PlaqueData.Volume<60^3,:);
% if size(PlaqueData,1)>=65535; keyboard; end;
PlaqueMap=zeros(size(PlaqueMap),'uint16');
PlaqueMap(cell2mat(PlaqueData.PixelIdxList))=1;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueMap,PixInter),FilenameTotalCrude,'PlaqueMap_2'); end;

%% merge frayed plaques
if Settings.MergeFrayedPlaques{1}==1
    [Distance]=distanceMat_4(PlaqueMap,{'DistInOut'},Res,0.1,1,0,0,'uint16',0.2);
    timeTable('DistanceFromPlaque');
    Distance(interpolate3D_3(Outside,Pix)==1)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Distance,PixInter),FilenameTotalCrude,'Plaque_DistanceFromPlaque'); end;
    BasinThreshold=40;
    Basins=uint16(watershed(BasinThreshold-uint8(Distance),6));
    Basins(PlaqueMap==1)=0;
    Basins(interpolate3D_3(Outside,Pix)==1)=0;
    
    BW=bwconncomp(logical(Basins),6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.ID=(1:size(Table,1)).';
    Table.Volume=Table.NumPix*prod(Res(1:3));
    
    Basins=labelmatrix(BW);
    Wave1=accumarray_9(Basins,Distance,@max,[],[],[],{1,0});
    Table.DistanceMax(Wave1.Roi1,1)=Wave1.Value1;
    
    Wave1=accumarray_9(Basins,Distance,@mean,[],[],[],{1,0});
    Table.DistanceMean(Wave1.Roi1,1)=Wave1.Value1;
    
    TableSelection=Table(Table.DistanceMean<=20,:);
    PlaqueMap(cell2mat(TableSelection.IdxList))=1;
    PlaqueMap=imdilate(PlaqueMap,strel('sphere',3));
    PlaqueMap=imerode(PlaqueMap,strel('sphere',3));
    [PlaqueMap]=removeIslands_4(PlaqueMap,6,[0;1],Res);
    if ShowIntermediateSteps==1
        Wave1=uint16(ceil(Table.DistanceMax));
        Wave1=Wave1(Basins(Basins>0));
        Wave2=Basins;
        Wave2(Basins>0)=Wave1;
        ex2Imaris_2(interpolate3D_3(Wave2,PixInter),FilenameTotalCrude,'Nuclei_Basins_DistanceMax');
    end
end
%% remove blood
if Settings.RemoveBlood{1}==1 % blood vessels are 2-3µm in diameter
    Data3D=imdilate(PlaqueMap,imdilateWindow([2;2;2],Res));
    Data3D=imerode(Data3D,imdilateWindow([5;5;5],Res)); % previously 7
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Data3D,PixInter),FilenameTotalCrude,'PlaqueMap_3'); end;
    Data3D=imdilate(Data3D,imdilateWindow([3;3;3],Res)); % previously 6
    PlaqueMap(Data3D==0)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueMap,PixInter),FilenameTotalCrude,'PlaqueMap_4'); end;
    clear Data3D;
end

%% generate heatmap of plaqueload
GenerateHeatMap=0;
if GenerateHeatMap==1
    ResCalc=[10;10;10]; % at a resolution of (10 µm)^3 determine the plaque volume fraction within (200 µm)^3 cube, if set to 100 then red means 1% coverage
    WindowSize=[200;200;200];
    Window=imdilateWindow(WindowSize,ResCalc);
    % PlaqueCoverage
    MeanPlaqueCoverage=interpolate3D_3(PlaqueMap>0,[],Res,ResCalc);
    MeanPlaqueCoverage=imfilter(double(MeanPlaqueCoverage),Window);
    Inside=interpolate3D_3(Outside,size(MeanPlaqueCoverage).')==0;
    Wave1=imfilter(double(Inside),Window);
    Wave2=MeanPlaqueCoverage./Wave1*10000;
    Wave2(Inside==0)=0; Wave2=Wave2+Inside;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Wave2,PixInter),FilenameTotalCrude,'MeanPlaqueCoverage'); end;
    % PlaqueDensity
    MeanPlaqueCoverage(:)=0;
    PlaqueData.FirstIdx=cellfun(@(v)v(1),PlaqueData.PixelIdxList);
    PlaqueData.FirstIdx2=ind2ind_2(PlaqueData.FirstIdx,Pix,size(MeanPlaqueCoverage).');
    Wave1=accumarray_9(PlaqueData.FirstIdx2,ones(size(PlaqueData,1),1),@sum);
    MeanPlaqueCoverage(Wave1.Roi1)=Wave1.Value1;
    MeanPlaqueCoverage=imfilter(double(MeanPlaqueCoverage),Window);
    %     Inside=interpolate3D_3(Outside,size(MeanPlaqueCoverage).')==0;
    Wave1=imfilter(double(Inside),Window)*prod(ResCalc)/1000000000; % integrated brain volume in mm^3
    Wave2=MeanPlaqueCoverage./Wave1;
    Wave2(Inside==0)=0;
    Wave2=Wave2+Inside;
    clear Inside;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(Wave2,PixInter),FilenameTotalCrude,'MeanPlaqueDensity'); end;
    
    
    clear Wave1; clear MeanPlaqueCoverage;
    
    %     TilingSettings={'Res','VoxelNumber','Overlap';ResCalc,TilingVoxelNumber,10}; TilingSettings=array2table(TilingSettings(2:end,:),'VariableNames',TilingSettings(1,:));
    %     PlaqueLocalPrc=percentileFilter3D_3(Plaque,98,Res,ResCalc,Exclude,[],[35;35;Res(3)],1,TilingSettings);
    %     TilingSettings=table(max([1,min(Res)]),TilingVoxelNumber,0,'VariableNames',{'Res','VoxelNumber','Overlap'});
    %     ResCalc=max([2,min(Res)]);
    
    
end

%% prefilter plaques according to their geometry
% keyboard;

if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D_3(PlaqueMap,PixInter),FilenameTotalCrude,'PlaqueMap_5'); end;
% PlaqueGeometryFilter=0;
% if PlaqueGeometryFilter==1
BW=bwconncomp(PlaqueMap,6);
if strfind1(Settings.Properties.VariableNames.','PlaqueGeometryFilter',1) && Settings.PlaqueGeometryFilter{1}==1
    
    PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
    PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
    Wave1=struct2table(regionprops(BW,'BoundingBox'));
    PlaqueData.BB=(Wave1.BoundingBox(:,4:6)).*repmat(Res.',[size(PlaqueData,1),1]);
    PlaqueData.BBMax=max(PlaqueData.BB,[],2);
    PlaqueData.AspectXYvsZ=PlaqueData.BB(:,3)./mean(PlaqueData.BB(:,1:2),2);
    PlaqueData.AspectXvsY=PlaqueData.BB(:,1)./PlaqueData.BB(:,2);
    PlaqueData.AspectXvsY(PlaqueData.AspectXvsY<1)=PlaqueData.BB(PlaqueData.AspectXvsY<1,2)./PlaqueData.BB(PlaqueData.AspectXvsY<1,1);
    PlaqueData.VolPerBB=PlaqueData.Volume./prod(PlaqueData.BB.').'*100;
%     figure; plot(histogram(PlaqueData.AspectXYvsZ,1000));
%     histogram(PlaqueData.AspectXYvsZ,100);
    Selection=find(max(PlaqueData.BB(:,1:2),[],2)<=60 & PlaqueData.BB(:,3) < 120 & PlaqueData.AspectXYvsZ>0.5 & PlaqueData.AspectXvsY<1.5 & PlaqueData.VolPerBB>10);
    BW.PixelIdxList=PlaqueData.PixelIdxList(Selection).';
    BW.NumObjects=size(Selection,1);
    GenerateFileOfSelection=0;
    if GenerateFileOfSelection==1
        Application='Test11.ims';
        PlaqueMap(:)=0;
        PlaqueMap(cell2mat(PlaqueData.PixelIdxList(Selection)))=1;
        [Data3D,Table]=dataNesting_3(PlaqueMap,'SortVolumeInPlane');
        ex2Imaris_2(Data3D,Application,'PlaqueMap',1,Res);
        Wave1=zeros(size(Data3D),class(Data3D));
        Wave1(cell2mat(Table.PixelIdxList2))=Plaque(cell2mat(Table.PixelIdxList));
        ex2Imaris_2(Wave1,Application,'CongoRed',1,Res);
        imarisSaveHDFlock(Application);
        Application=openImaris_4(Application,[],1,1);
    end
    PerformNesting=1;
else
    PerformNesting=0;
end

%% plaque nesting

if PerformNesting==1
    [PlaqueMap,NestingTable]=dataNesting_3(BW,'Compact','BW',Res);
%     ex2Imaris_2(Data3D,'Test3.ims','PlaqueMap',1,Res);
%     ReductionFactor=prod(size(PlaqueMap))/prod(size(Data3D));
    Wave1=zeros(size(PlaqueMap),class(Plaque));
    Wave1(cell2mat(NestingTable.PixelIdxList2))=Plaque(cell2mat(NestingTable.PixelIdxList));
    Plaque=Wave1;
    OrigPlaqueMap=PlaqueMap;
else
    PlaqueMap=labelmatrix(BW);
end

%% separate individual plaques
% SeparatePlaques=Settings.SeparatePlaques{1};
if strfind1(Settings.Properties.VariableNames.','SeparatePlaques',1) && strcmp(Settings.SeparatePlaques{1},'None')==0
    if strcmp(Settings.SeparatePlaques{1},'DistanceFromPlaqueBorder')
        ResCalc=max([max(Res),0.8],[],2); % previously 0.4
        [PlaqueMapWatershed,LocalMaxima,WatershedDistance]=watershedSegmentation_2(PlaqueMap,'Radius',Res,ResCalc,1,3,1);
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D_3(WatershedDistance,PixInter),FilenameTotalCrude,'Plaque_WatershedDistance');
            ex2Imaris_2(interpolate3D_3(LocalMaxima,PixInter),FilenameTotalCrude,'Plaque_LocalMaxima');
        else
            clear WatershedDistance;
            clear LocalMaxima;
        end
    end
    if strcmp(Settings.SeparatePlaques{1},'Morphology')
        %         TilingSettings=table(TilingVoxelNumber,10,'VariableNames',{'VoxelNumber','Overlap'});
        Version=struct('SeedImpact','Radius','Thresholds','Plaque','Imdilation',1,'WatershedUmBin',0.1,'ResCalc',0.8,'WatershedType','Morphology','IdentifyLocalMaximaExtent',8,'DistanceDimensionality','XY');
        [PlaqueMapWatershed,LocalMaxima,~,Seeds]=watershedSegmentation_2(PlaqueMap,Version,Res);
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D_3(PlaqueMapWatershed,PixInter),FilenameTotalCrude,'Plaque_PlaqueMapWatershed');
            ex2Imaris_2(interpolate3D_3(LocalMaxima,PixInter),FilenameTotalCrude,'Plaque_LocalMaxima');
        end
    end
    if strcmp(Settings.SeparatePlaques{1},'Intensity&Morphology')
        % identify seed loci and watershed from intensity
% %         if prod(Res(:))<1
            ResCalc=max([Res,[0.8;0.8;0.8]],[],2);
            WatershedData=double(Plaque);
            [Window,Wave1]=imdilateWindow_2([5;5;5],Res,1,'ellipsoid'); % previously 4µm cube
            for m=1:5
                WatershedData(PlaqueMap==0)=0;
                WatershedData=imfilter(WatershedData,double(Window)/sum(Window(:)));
            end
            Version=struct('SeedImpact','Radius','Thresholds','Plaque','Imdilation',1,'WatershedUmBin',0.1,'ResCalc',0.8,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',8,'DistanceDimensionality','XY');
            [PlaqueMapWatershed,LocalMaxima,~,Seeds]=watershedSegmentation_2(PlaqueMap,Version,Res,WatershedData);
% %         else
% %             Version=struct('SeedImpact','Radius','Thresholds','Plaque','Imdilation',1,'WatershedUmBin',0.1,'ResCalc',0.8,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',8,'DistanceDimensionality','XY');
% %             [PlaqueMap,LocalMaxima,~,~]=watershedSegmentation_2(PlaqueMap,Version,Res,Plaque);
% %         end
       
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D_3(WatershedData,PixInter),FilenameTotalCrude,'Plaque_WatershedData');
            ex2Imaris_2(interpolate3D_3(LocalMaxima,PixInter),FilenameTotalCrude,'Plaque_LocalMaxima');
        else
            clear WatershedDistance;
            clear LocalMaxima;
        end
    end
    % seperate fused plaques according to intensity profile
    if strcmp(Settings.SeparatePlaques{1},'Intensity')
        keyboard;
        ResCalc=max([Res,[0.8;0.8;0.8]],[],2); % previously 0.4
        WatershedDistance=double(interpolate3D(Plaque,Res,ResCalc));
        % prevent that parts of nearby plaques are accounted to close very bright plaques, therefore set everything more distant than 2µm from a plaque to 65535
        
        PlaqueMap2=imdilate(PlaqueMap,imdilateWindow_2([2;2;2],ResCalc,1,'ellipsoid'));
        PlaqueMap2=interpolate3D(PlaqueMap2,Res,ResCalc);
        
        [Window,Wave1]=imdilateWindow_2([8;8;8],ResCalc,1,'ellipsoid'); % previously 4µm cube
        Iterate=str2num(regexprep(Settings.SeparatePlaques{1},'Intensity',''));
        for m=1:Iterate % 15x takes 25min
            WatershedDistance=imfilter(WatershedDistance,double(Window)/sum(Window(:)));
            if m<Iterate % omit in last run because otherwise in the interpolated 3D data parts of the plaque are cut away
                WatershedDistance(PlaqueMap2==0)=0;
            end
        end
        timeTable('IntensityFiltering');
        WatershedDistance=max(WatershedDistance(:))-WatershedDistance;
        
        PlaqueMapWatershed=watershed(WatershedDistance,6); % 100min for kernel==6
        PlaqueMapWatershed=interpolate3D(PlaqueMapWatershed,[],[],Pix);
        
        timeTable('Watershed');
        PlaqueMapWatershed=uint16(PlaqueMapWatershed);
        PlaqueMapWatershed(PlaqueMap==0)=0;
    end
    
    RemoveRidgeLines=0;
    if RemoveRidgeLines==1 % remove ridge lines
        [Distance,Membership]=distanceMat_4(PlaqueMapWatershed,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',ResCalc); % 21min
        PlaqueMap=Membership.*PlaqueMap;
        timeTable('RemoveRidgeLines');
    else
        if exist('PlaqueMapWatershed','Var')==1
            PlaqueMap=PlaqueMapWatershed;
        end
    end
    clear PlaqueMapWatershed;
end

%% quantify PlaqueData
PlaqueData=table;
PlaqueData.PixelIdxList=label2idx(PlaqueMap).';
PlaqueData.NumPix=cellfun(@numel,PlaqueData.PixelIdxList);
PlaqueData.VolumeNoRoundation=PlaqueData.NumPix*prod(Res(1:3));

% refine plaques to be larger than 3µm diameter
PlaqueData=PlaqueData(PlaqueData.VolumeNoRoundation>=PlaqueMinimalVolume,:);
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(BW.PixelIdxList,2);
BW.ImageSize=size(PlaqueMap);
PlaqueMap=labelmatrix(BW);

if isempty(PlaqueData)
    DistanceFromBorder=ones(Pix.','uint16')*255;
    Membership=zeros(Pix.','uint16');
    return;
end

% get Zpos of maximal summed intensity

IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(uint16(1:Pix(1)).',[1,Pix(2),Pix(3)]),'Roi2'},Plaque,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave1]=max(double(IntensitySum),[],2);
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(uint16(1:Pix(2)),[Pix(1),1,Pix(3)]),'Roi2'},Plaque,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave2]=max(double(IntensitySum),[],2);
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},Plaque,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave3]=max(double(IntensitySum),[],2);
PlaqueData.PixCenterMaxIntSum=[Wave1,Wave2,Wave3];

% get maximal area in XY

Include=PlaqueMap>0;
Wave1=repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]); Wave1=Wave1(Include);
AreaSum=accumarray_10({PlaqueMap(Include),'Roi1';Wave1,'Roi2'},ones(sum(Include(:)),1,'uint8'),@sum,'2D'); % 12min
clear Include;
PlaqueData.TotalPixel=AreaSum;
% AreaSum=accumarray_10({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},ones(Pix.','uint8'),@sum,'2D',[],[],{1,0}); % 12min
% AreaSum=accumarray_10({PlaqueMap,'Roi1';permute(uint16(1:Pix(3)),[1,3,2]),'Roi2'},uint8(1),@sum,'2D',[],[],{1,0}); % 12min
% [Output]=accumarray_9(Rois,Data,Function,OutputFormat,AccumMethod,CountInstances,RoiExclude)
AreaSum=double(AreaSum)*prod(Res(1:2));
% get area at Zpos of max summed intensity
PlaqueData.AreaMaxIntSum=AreaSum(sub2ind(size(AreaSum),(1:size(PlaqueData,1)).',PlaqueData.PixCenterMaxIntSum(:,3)));
% % for m=1:size(PlaqueData,1)
% %     PlaqueData.AreaMaxIntSum(m,1)=AreaSum(m,PlaqueData.PixCenterMaxIntSum(m,3));
% % end

PlaqueData.RadiusMaxIntSum=(PlaqueData.AreaMaxIntSum/3.1415).^0.5;
% get max area independent of intensity
[Wave2,Wave3]=max(AreaSum,[],2);
PlaqueData.AreaMax=Wave2;
PlaqueData.ZpixAreaMax=Wave3;
PlaqueData.RadiusAreaMax=(PlaqueData.AreaMax/3.1415).^0.5;

% roundation
if Settings.Roundation{1}==1
	
    Wave1=PlaqueData.RadiusMaxIntSum.^2 - ((repmat(1:Pix(3),[size(PlaqueData,1),1])-repmat(PlaqueData.PixCenterMaxIntSum(:,3),[1,Pix(3)]))*Res(1)).^2;
    PlaqueData.AllowedPixel(:,1:Pix(3))=uint32(3.1415*Wave1/Res(1)^2);
    Wave1=PlaqueData.AllowedPixel;
    keyboard; % go on here
    Wave1(:,:,2)=PlaqueData.TotalPixel;
    PlaqueData.AllowedPixel=min(Wave1,[],3);
%     isequal(PlaqueData.Test(1:6404,:),PlaqueData.AllowedPixel(1:6404,:));
%     isequal(PlaqueData.Test(1:6403,:),PlaqueData.AllowedPixel(1:6403,:));
%     A1=sum(PlaqueData.Test,2);
% %     for Pl=1:size(PlaqueData,1) % A(d)=(r^2-d^2)*pi
% %         PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415* (PlaqueData.RadiusMaxIntSum(Pl)^2 - (((1:Pix(3))-PlaqueData.PixCenterMaxIntSum(Pl,3))*Res(1)).^2)/Res(1)^2);
% %     end
    keyboard; %go on here
    for Z=1:Pix(3)
        Table2=table;
        Plaque2D=Plaque(:,:,Z);
        PlaqueMap2D=PlaqueMap(:,:,Z);
        Table2.LinInd=find(PlaqueMap2D~=0);
        Table2.Intensity=Plaque2D(Table2.LinInd);
        Table2.Plaque=PlaqueMap2D(Table2.LinInd);
        
        Table2=sortrows(Table2,{'Plaque','Intensity'},{'ascend','descend'});
        PlaqueIds=unique(Table2.Plaque);
        %
        Table3=table;
        Table3.Pl=PlaqueIds;
        Table3.AllowedPixel=PlaqueData.AllowedPixel(PlaqueIds,Z);
        Table3.TotalPixel=PlaqueData.TotalPixel(PlaqueIds,Z);
        keyboard; % from AllowedPixel and TotalPixel make sequence of 1 and 0 and paste into Table2
        %
        Table2.Value(:,1)=0;
        for Pl=PlaqueIds.'
            Wave1=find(Table2.Plaque==Pl);
            Table2.Value(Wave1(1:min([PlaqueData.AllowedPixel(Pl,Z);size(Wave1,1)])))=1;
        end
        PlaqueMap2D(Table2.LinInd(Table2.Value==0))=0;
        PlaqueMap(:,:,Z)=PlaqueMap2D;
    end
    PlaqueData(:,'AllowedPixel') = [];
    timeTable('Roundation');
end
% BorderTouch, only positive if plaques touch border laterally
Wave1=ones(size(PlaqueMap),'uint8');Wave1(2:end-1,2:end-1,1:end)=0;
Wave1=unique(PlaqueMap(Wave1~=0&PlaqueMap~=0));
PlaqueData.BorderTouch(Wave1,1)=1;

% distance to Outside in all directions from core of the plaque as defined by max intensity
Inside=interpolate3D_3(Outside,Pix);
for Pl=1:size(PlaqueData,1)
    PixCenterMaxIntSum=PlaqueData.PixCenterMaxIntSum(Pl,:).';
    Wave1=PixCenterMaxIntSum(1:2).*Res(1:2);
    Wave2=1-permute(Inside(PixCenterMaxIntSum(1),PixCenterMaxIntSum(2),:),[3,2,1]);
    Wave3=[sum(Wave2(1:PixCenterMaxIntSum(3)));sum(Wave2(PixCenterMaxIntSum(3):end))];
    PlaqueData.DistanceCenter2Border(Pl)={[[Wave1,Res(1:2).*Pix(1:2)-Wave1];Wave3.'*Res(3)]};
end
clear Outside2;

% Distance transformation
if prod(Pix.*Res)>ThresholdLargeFile
    ResCalc=0.8;
else
    ResCalc=0.4;
end
[DistanceFromBorder,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',ResCalc); % 21min
timeTable('DistanceFromPlaqueBorder');

Membership(interpolate3D_3(Outside,Pix)==1)=0;

MergeFrayedPlaques=0; % allow DistanceTransformation of frayed plaques
if MergeFrayedPlaques==1
    % remove holes
    DistanceFromBorder=DistanceFromBorder<=52;
    BW=bwconncomp(~DistanceFromBorder,4);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Area=Table.NumPix*prod(Res(1:2));
    Table(Table.Area>1^2,:)=[];
    DistanceFromBorder(cell2mat(Table.IdxList))=1;
    [DistanceFromBorder]=distanceMat_4(DistanceFromBorder,{'DistInOut'},Res,1,1,1,50,'uint16',ResCalc);
    DistanceFromBorder=DistanceFromBorder+2;
    timeTable('MergeFrayedPlaques');
end

% clear Outside;

% calculate Volume and thereby radius
Wave1=PlaqueMap(PlaqueMap~=0);
[Wave1,Edges]=histcounts(Wave1,(1:1:max(Wave1(:))+1).');
PlaqueData.Volume=Wave1.'*prod(Res(:));
PlaqueData.RadiusFromVolume=(PlaqueData.Volume*3/4/3.1415).^(1/3);

% redo BW according to new PlaqueMap and calculate centroid
BW.PixelIdxList=label2idx(PlaqueMap);
BW.NumObjects=size(BW.PixelIdxList,2);
Wave1=struct2table(regionprops(BW,'Centroid'));

Wave2=Wave1.Centroid(:,[2,1,3]);
for Pl=1:size(PlaqueData,1)
    PlaqueData.PixCenter(Pl,1)={Wave2(Pl,:).'};
    PlaqueData.UmCenter(Pl,1)={Wave2(Pl,:).'.*Res};
end
PlaqueData(:,'PixelIdxList')=[];

% calculate percentile distribution for each plaque
for Pl=1:size(PlaqueData,1)
    Wave1=Plaque(PlaqueMap==Pl);
    PlaqueData.Percentile{Pl,1}=prctile_2(Wave1,(0:0.1:100));
    Wave1=Plaque(Membership==Pl & DistanceFromBorder<=50);
    PlaqueData.Percentile2{Pl,1}=prctile_2(Wave1,(0:0.1:100));
end

if ShowIntermediateSteps==1
    ex2Imaris_2(interpolate3D_3(DistanceFromBorder,PixInter),FilenameTotalCrude,'DistanceFromBorder');
    ex2Imaris_2(interpolate3D_3(PlaqueMap,PixInter),FilenameTotalCrude,'PlaqueMap');
    ex2Imaris_2(interpolate3D_3(Membership,PixInter),FilenameTotalCrude,'Membership');
end
timeTable('QuantifyPlaqueData_End');

%% volume versus distance distribution for each plaque
CalcDistanceDistribution=1;
if CalcDistanceDistribution==1
    ResCalc=2;
    PlaqueMap_2=interpolate3D_3(PlaqueMap,[],Res,repmat(ResCalc,[3,1]),@max);
    Outside_2=interpolate3D_2(interpolate3D_3(Outside,Pix),Res,repmat(ResCalc,[3,1]),[],@max);
    PlaqueData.UmCenter2=reshape(cell2mat(PlaqueData.UmCenter),[3,size(PlaqueData,1)]).';
    Wave1=round(PlaqueData.UmCenter2./repmat(ResCalc.',[size(PlaqueData,1),1])); Wave1(Wave1==0)=1;
    PlaqueData.LinearInd2=sub2ind(size(PlaqueMap_2),Wave1(:,1),Wave1(:,2),Wave1(:,3));
    
    for Pl=1:size(PlaqueData,1)
        DistInOut=distanceMat_4(PlaqueMap_2==Pl,{'DistInOut'},repmat(ResCalc,[3,1]),1,1,0,0,'uint16');
        Wave1=histcounts(DistInOut(Outside_2==0),0:1:1000).'*ResCalc^3;
        Wave1(2,1)=sum(Wave1(1:2))-PlaqueData.Volume(Pl);
        Wave1(1,1)=PlaqueData.Volume(Pl);
        PlaqueData.DistanceDistribution(Pl)={Wave1};
        
        Wave1=accumarray_9(PlaqueMap_2,DistInOut,@min); Wave1(Wave1.Roi1==0,:)=[];
        Table=table;
        Table.PlId=Wave1.Roi1; Table.Border2Border=Wave1.Value1;
        Table.Border2Center=DistInOut(PlaqueData.LinearInd2);
        Table.Center2Center=((PlaqueData.UmCenter2(:,1)-PlaqueData.UmCenter2(Pl,1)).^2 + (PlaqueData.UmCenter2(:,2)-PlaqueData.UmCenter2(Pl,2)).^2 + (PlaqueData.UmCenter2(:,3)-PlaqueData.UmCenter2(Pl,3)).^2).^0.5;
        PlaqueData.InterPlaqueDistance(Pl,1)={Table};
    end
    PlaqueData = removevars(PlaqueData,{'UmCenter2';'LinearInd2'});
    timeTable('CalcDistanceDistribution');
end

timeTable('End');
if ShowIntermediateSteps==1
    imarisSaveHDFlock(FilenameTotalCrude);
%     Application=openImaris_4(FilenameTotalCrude,1,1,1);
%     keyboard;
end
