function [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,Plaque,Output]=wholeSliceQuantification_PlaqueDetection_7(Plaque,Outside,Res,FilenameTotal,Settings)
% global W;
global ShowIntermediateSteps;
timeTable('Start');
PlaqueChannelName=Settings.Name{1};

if exist('ShowIntermediateSteps')~=1 || ShowIntermediateSteps~=1 % display low resolution version of selected data
    ShowIntermediateSteps=0;
else % imarisSaveHDFlock(FilenameTotalCrude); Application=openImaris_3(FilenameTotalCrude,[],1); global Application;
    FilenameTotalCrude=FilenameTotal; % FilenameTotalCrude=regexprep(FilenameTotal,'.ims','_Crude.ims'); %
    Res2=Res; % Res2=[1.6;1.6;1.6];
end

Pix=size(Plaque).';
Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded

ThresholdLargeFile=1000*1000*50;
if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Plaque,Res,Res2),FilenameTotalCrude,'PlaqueOrig'); end;
if prod(Pix.*Res)>ThresholdLargeFile
    keyboard;
    [~,Plaque]=percentileFilter3D_3(Plaque,70,Res,[8;8;Res(3)],Outside,400,[500;500;Res(3)],1);
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

if Settings.RemoveBlood{1}==1 % blood vessels are 2-3µm in diameter
    Data3D=imdilate(PlaqueMap,imdilateWindow([2;2;2],Res));
    Data3D=imerode(Data3D,imdilateWindow([5;5;5],Res)); % previously 7
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Data3D,Res,Res2),FilenameTotalCrude,'PlaqueMap_3'); end;
    Data3D=imdilate(Data3D,imdilateWindow([3;3;3],Res)); % previously 6
    PlaqueMap(Data3D==0)=0;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap_4'); end;
    clear Data3D;
end

%% separate individual plaques
SeparatePlaques=Settings.SeparatePlaques{1};
if exist('SeparatePlaques','Var')==1
    if strcmp(SeparatePlaques,'DistanceFromPlaqueBorder')
        ResCalc=max([max(Res),0.8],[],2); % previously 0.4
        [PlaqueMapWatershed,LocalMaxima,WatershedDistance]=watershedSegmentation(PlaqueMap,'Radius',Res,ResCalc,1,3,1);
        if ShowIntermediateSteps==1
            ex2Imaris_2(interpolate3D(WatershedDistance,[],[],Pix),FilenameTotalCrude,'Plaque_WatershedDistance');
            ex2Imaris_2(interpolate3D(LocalMaxima,Res,Res2),FilenameTotalCrude,'Plaque_LocalMaxima');
        else
            clear WatershedDistance;
            clear LocalMaxima;
        end

%         ex2Imaris_2(PlaqueMap,Application,'PlaqueMap');
%         ex2Imaris_2(WatershedDistance,Application,'WatershedDistance');
%         ex2Imaris_2(LocalMinima,Application,'LocalMinima');
        
%         [WatershedDistance]=distanceMat_4(imdilate(PlaqueMap,imdilateWindow([3;3;3],Res)),{'DistInOut'},Res,1,1,1,50,'uint16',0.8); % previously imdilate8
%         timeTable('WatershedDistance');
%         WatershedDistance(WatershedDistance<45)=45;
%         PlaqueMapWatershed=uint16(watershed(WatershedDistance,6));
%         timeTable('Watershed');
%         PlaqueMapWatershed(PlaqueMap==0)=0;
    end
    % seperate fused plaques according to intensity profile
    if strfind1(SeparatePlaques,'Intensity')
        keyboard;
        ResCalc=max([Res,[0.8;0.8;0.8]],[],2); % previously 0.4
        WatershedDistance=double(interpolate3D(Plaque,Res,ResCalc));
        % prevent that parts of nearby plaques are accounted to close very bright plaques, therefore set everything more distant than 2µm from a plaque to 65535
        
        PlaqueMap2=imdilate(PlaqueMap,imdilateWindow_2([2;2;2],ResCalc,1,'ellipsoid'));
        PlaqueMap2=interpolate3D(PlaqueMap2,Res,ResCalc);
        
        [Window,Wave1]=imdilateWindow_2([8;8;8],ResCalc,1,'ellipsoid'); % previously 4µm cube
        Iterate=str2num(regexprep(SeparatePlaques,'Intensity',''));
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
%     clear PlaqueWatershedDistance;
    clear PlaqueMapWatershed;
end

if exist('SeparatePlaques','Var')==0
    BW=bwconncomp(PlaqueMap,26);
    PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
    PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
    PlaqueMap=labelmatrix(BW);
end



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
MergeFrayedPlaques=1; % allow DistanceTransformation of frayed plaques
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


% % % % remove islands
% % % [PlaqueMap]=removeIslands_4(PlaqueMap>0,6,[0;3],Res);
% % % PlaqueMap=uint16(PlaqueMap).*Membership;
% % % timeTable('RemoveIslands');
% % % % Distance correction
% % % DistanceFromBorder(DistanceFromBorder>50&PlaqueMap~=0)=50;
% % % DistanceFromBorder(Outside==1)=0;
clear Outside;

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
timeTable('End');
% imarisSaveHDFlock(FilenameTotal);
% keyboard;
