function [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,Plaque,Output]=wholeSliceQuantification_PlaqueDetection_8(Plaque,Outside,Res,FilenameTotal,Settings)
% global W;
global ShowIntermediateSteps;
timeTable('Start wholeSliceQuantification_PlaqueDetection');
PlaqueChannelName=Settings.Name{1};

if exist('ShowIntermediateSteps')~=1 || ShowIntermediateSteps~=1 % display low resolution version of selected data
    ShowIntermediateSteps=0;
else
    FilenameTotalCrude=FilenameTotal; % FilenameTotalCrude=regexprep(FilenameTotal,'.ims','_Crude.ims'); %
    Res2=Res;
% %     Res2=[5;5;5]; %  % Res2=[1.6;1.6;1.6];
% %     FilenameTotalCrude=regexprep(FilenameTotal,'.ims','_Outside.ims');
end

Pix=size(Plaque).';
Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded

ThresholdLargeFile=1000*1000*50;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Plaque,Res,Res2),FilenameTotalCrude,Settings.Name{1}); end;

if prod(Pix.*Res)>ThresholdLargeFile
    [~,Plaque]=percentileFilter3D_3(Plaque,70,Res,[10;10;5],Outside,400,[500;500;Res(3)],1);
else
    [~,Plaque]=percentileFilter3D_3(Plaque,70,Res,[2;2;Res(3)],Outside,400,[200;200;1],1);
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Plaque,Res,Res2),FilenameTotalCrude,'Plaque_PercentileFilter3D'); end;
end

timeTable('PlaquePrc70');
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    % % %     dataInspector3D(interpolate3D(Plaque,Res,Res2),Res2,'Plaque',1,FilenameTotalCrude,0);
    FileinfoCrude=getFileinfo_2(FilenameTotalCrude);
end

%% core plaque quantification
% if strcmp(PlaqueChannelName,'MetBlue')
% define PlaqueCore as contiguous voxels of larger than 2 µm^3 over the defined threshold
Background=prctile(Plaque(Outside==0),90);
Threshold=Background*Settings.Core2BackgroundRatio{1};

PlaqueCore=(Plaque>=Threshold) & Outside==0; % previously factor 2
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(uint16(single(Plaque)./single(Background)*1000),Res,Res2),FilenameTotalCrude,'PlaqueBackgroundRatio'); end;

BW=bwconncomp(PlaqueCore,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.Volume>=2,:);
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(PlaqueData,1);
PlaqueCore=labelmatrix(BW);
clear BW;
timeTable('PlaqueCore');
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueCore,Res,Res2),FilenameTotalCrude,'PlaqueCore'); end;

% calculate distance from core to define regions excluded from BackgroundSubtraction
[DistanceFromCore,CoreMembership]=distanceMat_4(PlaqueCore,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',0.8);
timeTable('PlaqueCoreDistance');
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(DistanceFromCore,Res,Res2),FilenameTotalCrude,'DistanceFromCore'); end;
clear PlaqueCore;

Exclude=Outside;
Exclude(DistanceFromCore<Settings.DistanceFromCoreThreshold{1}+50)=1;

%% calculate PlaqueMap
PlaqueLocalPrc=percentileFilter3D_3(Plaque,98,Res,[0.8;0.8;Res(3)],Exclude,[],[35;35;Res(3)],1);
clear Exclude;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueLocalPrc,Res,Res2),FilenameTotalCrude,'PlaqueLocalPrc'); end;

timeTable('PlaqueLocalPrc');
PlaqueMap=(Plaque>PlaqueLocalPrc & Outside==0 & DistanceFromCore<=60) | DistanceFromCore<=50;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap_1'); end;
clear PlaqueLocalPrc;

% remove plaques that have no plaque core or are smaller than 3µm diameter
BW=bwconncomp(PlaqueMap,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueMap=labelmatrix(BW);
Wave1=PlaqueMap(DistanceFromCore<=50);
clear DistanceFromCore;
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
PlaqueData=PlaqueData(Wave2,:);
PlaqueData=PlaqueData(PlaqueData.Volume>=27,:);
PlaqueMap=zeros(size(PlaqueMap),'uint16');
PlaqueMap(cell2mat(PlaqueData.PixelIdxList))=1;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap_2'); end;

if Settings.MergeFrayedPlaques{1}==1
    [Distance]=distanceMat_4(PlaqueMap,{'DistInOut'},Res,0.1,1,0,0,'uint16',0.2);
    timeTable('DistanceFromPlaque');
    Distance(Outside==1)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Distance,Res,Res2),FilenameTotalCrude,'Plaque_DistanceFromPlaque'); end;
    BasinThreshold=40;
    Basins=uint16(watershed(BasinThreshold-uint8(Distance),6));
    Basins(PlaqueMap==1)=0;
    Basins(Outside==1)=0;
    
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
        ex2Imaris_2(interpolate3D(Wave2,Res,Res2),FilenameTotalCrude,'Nuclei_Basins_DistanceMax');
    end
end

if Settings.RemoveBlood{1}==1 % blood vessels are 2-3µm in diameter
    Data3D=imdilate(PlaqueMap,imdilateWindow([2;2;2],Res));
    Data3D=imerode(Data3D,imdilateWindow([5;5;5],Res)); % previously 7
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Data3D,Res,Res2),FilenameTotalCrude,'PlaqueMap_3'); end;
    Data3D=imdilate(Data3D,imdilateWindow([3;3;3],Res)); % previously 6
    PlaqueMap(Data3D==0)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap_4'); end;
    clear Data3D;
end

PlaqueMap=labelmatrix(bwconncomp(PlaqueMap,6));
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap_5'); end;
% ex2Imaris_2(PlaqueMap,Application,'PlaqueMap_5');

%% separate individual plaques
% SeparatePlaques=Settings.SeparatePlaques{1};
if strfind1(Settings.Properties.VariableNames.','SeparatePlaques',1)
    if strcmp(Settings.SeparatePlaques{1},'DistanceFromPlaqueBorder')
        ResCalc=max([max(Res),0.8],[],2); % previously 0.4
        [PlaqueMapWatershed,LocalMaxima,WatershedDistance]=watershedSegmentation(PlaqueMap,'Radius',Res,ResCalc,1,3,1);
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D(WatershedDistance,[],[],Pix),FilenameTotalCrude,'Plaque_WatershedDistance');
            ex2Imaris_2(interpolate3D(LocalMaxima,Res,Res2),FilenameTotalCrude,'Plaque_LocalMaxima');
        else
            clear WatershedDistance;
            clear LocalMaxima;
        end
    end
    if strcmp(Settings.SeparatePlaques{1},'Morphology')
        Version=struct('SeedImpact','Radius','Thresholds','Plaque','Imdilation',1,'WatershedUmBin',0.1,'ResCalc',0.8,'WatershedType','Morphology','IdentifyLocalMaximaExtent',8,'DistanceDimensionality','XY');
        [PlaqueMapWatershed,LocalMaxima,~,Seeds]=watershedSegmentation_2(PlaqueMap,Version,Res);
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D(PlaqueMapWatershed,[],[],Pix),FilenameTotalCrude,'Plaque_PlaqueMapWatershed');
            ex2Imaris_2(interpolate3D(LocalMaxima,Res,Res2),FilenameTotalCrude,'Plaque_LocalMaxima');
%             imarisSaveHDFlock(FilenameTotalCrude);
%             Application=openImaris_4(FilenameTotalCrude,1,1);
%             keyboard;
        end
        
        %         ex2Imaris_2(PlaqueMapWatershed,Application,'PlaqueMap_6');
    end
    if strcmp(Settings.SeparatePlaques{1},'Intensity&Morphology')
        ResCalc=max([Res,[0.8;0.8;0.8]],[],2);
        WatershedData=double(Plaque);
        [Window,Wave1]=imdilateWindow_2([5;5;5],Res,1,'ellipsoid'); % previously 4µm cube
        for m=1:5
            WatershedData(PlaqueMap==0)=0;
            WatershedData=imfilter(WatershedData,double(Window)/sum(Window(:)));
        end
        % identify seed loci and watershed from intensity
        Version=struct('SeedImpact','Radius','Thresholds','Plaque','Imdilation',1,'WatershedUmBin',0.1,'ResCalc',0.8,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',8,'DistanceDimensionality','XY');
        [PlaqueMapWatershed,LocalMaxima,Wave1,Seeds]=watershedSegmentation_2(PlaqueMap,Version,Res,WatershedData);
        %         ex2Imaris_2(interpolate3D(Wave1,[],[],Pix),Application2,'Plaque_WatershedData');
        %         ex2Imaris_2(interpolate3D(LocalMaxima,Res,Res2),Application2,'Plaque_LocalMaxima');
        %         ex2Imaris_2(interpolate3D(PlaqueMapWatershed,[],[],Pix),Application2,'Plaque_PlaqueMapWatershed');
        
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D(WatershedData,[],[],Pix),FilenameTotalCrude,'Plaque_WatershedData');
            ex2Imaris_2(interpolate3D(LocalMaxima,Res,Res2),FilenameTotalCrude,'Plaque_LocalMaxima');
        else
            clear WatershedDistance;
            clear LocalMaxima;
        end
        %         ex2Imaris_2(interpolate3D(PlaqueMapWatershed,[],[],Pix),FilenameTotalCrude,'Plaque_PlaqueMapWatershed');
        %         imarisSaveHDFlock(FilenameTotalCrude);
        %         Application=openImaris_4(FilenameTotalCrude,1,1);
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
        PlaqueMap=PlaqueMapWatershed;
    end
    clear PlaqueMapWatershed;
end

% if exist('SeparatePlaques','Var')==0
%     BW=bwconncomp(PlaqueMap,26);
%     PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
%     PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
%     PlaqueMap=labelmatrix(BW);
% end

%% quantify PlaqueData
PlaqueData=table;
PlaqueData.PixelIdxList=label2idx(PlaqueMap).';
PlaqueData.NumPix=cellfun(@numel,PlaqueData.PixelIdxList);
PlaqueData.VolumeNoRoundation=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.VolumeNoRoundation>=27,:);
% refine plaques to be larger than 3µm diameter
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(BW.PixelIdxList,2);
PlaqueMap=labelmatrix(BW); % separation lines between plaques have to be removed using Membership and PlaqueMap

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
AreaSum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},ones(Pix.','uint8'),@sum,'2D',[],[],{1,0}); % 12min
AreaSum=double(AreaSum)*prod(Res(1:2));
% get area at Zpos of max summed intensity
for m=1:size(PlaqueData,1)
    PlaqueData.AreaMaxIntSum(m,1)=AreaSum(m,PlaqueData.PixCenterMaxIntSum(m,3));
end
if min(PlaqueData.AreaMaxIntSum(:))==0 % check why some Plaques have AreaMaxIntSum of zero
    keyboard; % did not occur since 2017.12.21
end
PlaqueData.RadiusMaxIntSum=(PlaqueData.AreaMaxIntSum/3.1415).^0.5;
% get max area independent of intensity
[Wave2,Wave3]=max(AreaSum,[],2);
PlaqueData.AreaMax=Wave2;
PlaqueData.ZpixAreaMax=Wave3;
PlaqueData.RadiusAreaMax=(PlaqueData.AreaMax/3.1415).^0.5;

% roundation
if Settings.Roundation{1}==1
    for Pl=1:size(PlaqueData,1) % A(d)=(r^2-d^2)*pi
        PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415* (PlaqueData.RadiusMaxIntSum(Pl)^2 - (((1:Pix(3))-PlaqueData.PixCenterMaxIntSum(Pl,3))*Res(1)).^2)/Res(1)^2);
    end
    for Z=1:Pix(3)
        Table2=table;
        Plaque2D=Plaque(:,:,Z);
        PlaqueMap2D=PlaqueMap(:,:,Z);
        Table2.LinInd=find(PlaqueMap2D~=0);
        Table2.Intensity=Plaque2D(Table2.LinInd);
        Table2.Plaque=PlaqueMap2D(Table2.LinInd);
        
        Table2=sortrows(Table2,{'Plaque','Intensity'},{'ascend','descend'});
        PlaqueIds=unique(Table2.Plaque);
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
for Pl=1:size(PlaqueData,1)
    PixCenterMaxIntSum=PlaqueData.PixCenterMaxIntSum(Pl,:).';
    Wave1=PixCenterMaxIntSum(1:2).*Res(1:2);
    Wave2=1-permute(Outside(PixCenterMaxIntSum(1),PixCenterMaxIntSum(2),:),[3,2,1]);
    Wave3=[sum(Wave2(1:PixCenterMaxIntSum(3)));sum(Wave2(PixCenterMaxIntSum(3):end))];
    PlaqueData.DistanceCenter2Border(Pl)={[[Wave1,Res(1:2).*Pix(1:2)-Wave1];Wave3.'*Res(3)]};
end

% Distance transformation
if prod(Pix.*Res)>ThresholdLargeFile
    ResCalc=0.8;
else
    ResCalc=0.4;
end
[DistanceFromBorder,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',ResCalc); % 21min
timeTable('DistanceFromPlaqueBorder');

Membership(Outside==1)=0;

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
    ex2Imaris_2(interpolate3D(DistanceFromBorder,Res,Res2),FilenameTotalCrude,'DistanceFromBorder');
    ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap');
    ex2Imaris_2(interpolate3D(Membership,Res,Res2),FilenameTotalCrude,'Membership');
end

%% volume versus distance distribution for each plaque
CalcDistanceDistribution=1;
if CalcDistanceDistribution==1
    ResCalc=2;
    PlaqueMap_2=interpolate3D_2(PlaqueMap,Res,repmat(ResCalc,[3,1]),[],@max);
    Outside_2=interpolate3D_2(Outside,Res,repmat(ResCalc,[3,1]),[],@max);
    PlaqueData.UmCenter2=reshape(cell2mat(PlaqueData.UmCenter),[3,size(PlaqueData,1)]).';
    Wave1=round(PlaqueData.UmCenter2./repmat(ResCalc.',[size(PlaqueData,1),1])); Wave1(Wave1==0)=1;
    PlaqueData.LinearInd2=sub2ind(size(PlaqueMap_2),Wave1(:,1),Wave1(:,2),Wave1(:,3));
    
    
    for Pl=1:size(PlaqueData,1)
        DistInOut=distanceMat_4(PlaqueMap_2==Pl,{'DistInOut'},repmat(ResCalc,[3,1]),1,1,0,0,'uint16');
        %         DistInOut=interpolate3D_2(DistInOut,[],[],Pix);
        %         DistInOut(DistInOut==0 & PlaqueMap==0)=ResCalc;
        Wave1=histcounts(DistInOut(Outside_2==0),0:1:1000).'*ResCalc^3;
        Wave1(2,1)=sum(Wave1(1:2))-PlaqueData.Volume(Pl);
        Wave1(1,1)=PlaqueData.Volume(Pl);
        PlaqueData.DistanceDistribution(Pl)={Wave1};
        
        Wave1=accumarray_9(PlaqueMap_2,DistInOut,@min); Wave1(Wave1.Roi1==0,:)=[];
        Table=table; Table.PlId=Wave1.Roi1; Table.Border2Border=Wave1.Value1;
        Table.Border2Center=DistInOut(PlaqueData.LinearInd2);
        Table.Center2Center=((PlaqueData.UmCenter2(:,1)-PlaqueData.UmCenter2(Pl,1)).^2 + (PlaqueData.UmCenter2(:,2)-PlaqueData.UmCenter2(Pl,2)).^2 + (PlaqueData.UmCenter2(:,3)-PlaqueData.UmCenter2(Pl,3)).^2).^0.5;
        PlaqueData.InterPlaqueDistance(Pl,1)={Table};
    end
    PlaqueData = removevars(PlaqueData,{'UmCenter2';'LinearInd2'});
    timeTable('CalcDistanceDistribution');
end

% ex2Imaris_2(DistInOut,Application,'DistanceFromBorder');
% imarisSaveHDFlock(FilenameTotalCrude); Application=openImaris_4(FilenameTotalCrude,[],1);
% imarisSaveHDFlock(FilenameTotal); Application=openImaris_4(FilenameTotal,[],1);
timeTable('End');
if ShowIntermediateSteps==1
    imarisSaveHDFlock(FilenameTotalCrude);
    Application=openImaris_4(FilenameTotalCrude,1,1,1);
    keyboard;
end