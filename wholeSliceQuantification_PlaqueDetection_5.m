function [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,MetBlue,Output]=wholeSliceQuantification_PlaqueDetection_5(MetBlue,Outside,Res,FilenameTotal,Core2BackgroundRatio,SeparatePlaques,CrudeDataVisualization)

if exist('CrudeDataVisualization')~=1 || CrudeDataVisualization~=1 % display low resolution version of selected data
    CrudeDataVisualization=0
else
    FilenameTotalCrude=regexprep(FilenameTotal,'.ims','_Crude.ims');
    Res2=Res; % Res2=[1.6;1.6;1.6];
end

Pix=size(MetBlue).';
Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded
Timer=datenum(now);
Window=[500;500;Res(3)];
ThresholdLargeFile=1000*1000*50;
if prod(Pix.*Res)>ThresholdLargeFile
    ResWatershed=[8;8;Res(3)];
    [~,MetBlue]=percentileFilter3D_2(MetBlue,70,Res,ResWatershed,Outside,400,Window);
else
    ResWatershed=[10;10;Res(3)];
    [~,MetBlue]=sparseFilter_2(MetBlue,Outside,Res,10000,Window,ResWatershed,70,'Multiply400');
end

disp(['MetBluePrc70: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 2.9min

% define PlaqueCore as contiguous voxels of larger than 2 µm^3 over the defined threshold
Threshold=prctile(MetBlue(Outside==0),90)*Core2BackgroundRatio;

PlaqueCore=(MetBlue>=Threshold) & Outside==0; % previously factor 2
if CrudeDataVisualization==1
    dataInspector3D(interpolate3D(uint16(single(MetBlue)./single(Threshold)*100),Res,Res2),Res2,'MetBlueBackgroundRatio',1,FilenameTotalCrude,0);
    FileinfoCrude=getFileinfo_2(FilenameTotalCrude);
end
if CrudeDataVisualization==1; ex2Imaris_2(interpolate3D(MetBlue,Res,Res2),FilenameTotalCrude,'MetBlue'); end;
clear MetBluePrc90;
BW=bwconncomp(PlaqueCore,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.Volume>=2,:);
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(PlaqueData,1);
PlaqueCore=labelmatrix(BW);
clear BW;
disp(['PlaqueCore: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 1.1min

% calculate distance from core to define regions excluded from BackgroundSubtraction
[DistanceFromCore,CoreMembership]=distanceMat_4(PlaqueCore,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',0.8);
disp(['PlaqueCoreDistance: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 35.1min
if CrudeDataVisualization==1; ex2Imaris_2(interpolate3D(DistanceFromCore,Res,Res2),FilenameTotalCrude,'DistanceFromCore'); end;
clear PlaqueCore;
Exclude=Outside;
Exclude(DistanceFromCore<60)=1;

[MetBlueLocalPrc]=percentileFilter2D(MetBlue,98,[35;35],Res,[1.6;1.6;Res(3)],Exclude); 
clear Exclude;
disp(['MetBlueLocalPrc: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now); % 25.7min
PlaqueMap=(MetBlue>MetBlueLocalPrc & Outside==0 & DistanceFromCore<=65) | DistanceFromCore<=50;
% if CrudeDataVisualization==1; MetBlueLocalPrc_Res2=interpolate3D(MetBlueLocalPrc,Res,Res2); end;
if CrudeDataVisualization==1; ex2Imaris_2(interpolate3D(MetBlueLocalPrc,Res,Res2),FilenameTotalCrude,'MetBlueLocalPrc'); end;
clear MetBlueLocalPrc; 


% remove plaques that have no plaque core or are smaller than 3µm diameter
BW=bwconncomp(PlaqueMap,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueMap=labelmatrix(BW);
Wave1=PlaqueMap(DistanceFromCore<=50);
% if CrudeDataVisualization==1; DistanceFromCore_Res2=interpolate3D(DistanceFromCore,Res,Res2); end;

clear DistanceFromCore;
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
PlaqueData=PlaqueData(Wave2,:);
PlaqueData=PlaqueData(PlaqueData.Volume>=27,:);
PlaqueMap=zeros(size(PlaqueMap),'uint16');
PlaqueMap(cell2mat(PlaqueData.PixelIdxList))=1;

%% separate individual plaques
% SeparatePlaques='DistanceFromPlaqueCore';
if exist('SeparatePlaques','Var')==0
    SeparatePlaques='Intensity20';
end
% ResWatershed=max([Res,[0.1;0.1;0.4]],[],2);
ResWatershed=max([Res,[0.4;0.4;0.4]],[],2);
% ResWatershed=Res;
% seperate fused plaques according to intensity profile
if strfind1(SeparatePlaques,'Intensity')
    WatershedDistance=interpolate3D(MetBlue,Res,ResWatershed);
    PlaqueMap2=interpolate3D(PlaqueMap,Res,ResWatershed);
    
    [~,Wave1]=imdilateWindow([4;4;4],ResWatershed);
    Iterate=str2num(regexprep(SeparatePlaques,'Intensity',''));
    for m=1:Iterate % 15x takes 25min
        WatershedDistance=imgaussfilt3(WatershedDistance,10,'FilterSize',Wave1); % kernel 7 takes 2min, 5 takes 1.5min, 3 takes 1.3min
    end
    disp(['Gaussian: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
    % prevent that parts of nearby plaques are accounted to close very bright plaques, therefore set everything more distant than 2µm from a plaque to 65535
    PlaqueMap2=imdilate(PlaqueMap2,imdilateWindow([2;2;2],ResWatershed));
    WatershedDistance(PlaqueMap2==0)=0;
    WatershedDistance=max(WatershedDistance(:))-WatershedDistance;
    
    PlaqueMapWatershed=watershed(WatershedDistance,26); % 100min for kernel==6
    PlaqueMapWatershed=interpolate3D(PlaqueMapWatershed,[],[],Pix);
    
    disp(['Watershed: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
    % % %     if CrudeDataVisualization==1
    % % %         Timer=datenum(now);
    % % %         LocalMinima=imregionalmin(WatershedDistance,26); % 100min for kernel==6
    % % %         disp(['LocalMinima: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']);
    % % %         WatershedDistance(LocalMinima==1)=0;
    % % %     end
%     if max(PlaqueMapWatershed(:))>65535
%         keyboard
%     end
    PlaqueMapWatershed=uint16(PlaqueMapWatershed);
    PlaqueMapWatershed(PlaqueMap==0)=0;
    clear PlaqueMap2;
end
if strcmp(SeparatePlaques,'DistanceFromPlaqueBorder')
    
    [WatershedDistance]=distanceMat_4(imdilate(PlaqueMap,imdilateWindow([4;4;4],Res)),{'DistInOut'},Res,1,1,1,50,'uint16',0.8); % 3.5min
    disp(['WatershedDistance: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
    
    PlaqueMapWatershed=uint16(watershed(WatershedDistance,26));
    disp(['Watershed: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
    PlaqueMapWatershed(PlaqueMap==0)=0;
end
if strcmp(SeparatePlaques,'DistanceFromPlaqueCore')
    PlaqueMapWatershed=PlaqueMap.*CoreMembership;
%     WatershedDistance=interpolate3D(DistanceFromCore,Res,ResWatershed);
%     PlaqueMap2=interpolate3D(PlaqueMap,Res,ResWatershed);
%     [WatershedDistance]=distanceMat_4(WatershedDistance<=50,{'DistInOut'},ResWatershed,1,1,0,50,'uint16',0.8);
    %     [WatershedDistance]=distanceMat_4(imdilate(PlaqueMap,imdilateWindow([4;4;4],Res)),{'DistInOut'},Res,1,1,1,50,'uint16',0.8); % 3.5min
    %     disp(['WatershedDistance: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
    %     PlaqueMapWatershed=DistanceFromCore;
    %     WatershedDistance(WatershedDistance<50)=50;
%     PlaqueMapWatershed=uint16(watershed(WatershedDistance,26));
%     disp(['Watershed: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
%     if isequal(ResWatershed,Res)==0
%         PlaqueMapWatershed=interpolate3D(PlaqueMapWatershed,[],[],Pix);
%     end
%     PlaqueMapWatershed(PlaqueMap==0)=0;
end

clear CoreMembership;
% if CrudeDataVisualization==1; WatershedDistance_Res2=interpolate3D(WatershedDistance,Res,Res2); end;
if CrudeDataVisualization==1 && exist('WatershedDistance','Var'); ex2Imaris_2(interpolate3D(WatershedDistance,[],[],FileinfoCrude.Pix{1}),FilenameTotalCrude,'WatershedDistance'); end;
clear WatershedDistance;

PlaqueMapWatershed(Outside==1)=0;

% quantify PlaqueData
PlaqueData=table;
PlaqueData.PixelIdxList=label2idx(PlaqueMapWatershed).';
clear PlaqueMapWatershed;
PlaqueData.NumPix=cellfun(@numel,PlaqueData.PixelIdxList);
PlaqueData.VolumeNoRoundation=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.VolumeNoRoundation>=27,:);
% refine plaques to be larger than 3µm diameter
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(BW.PixelIdxList,2);
PlaqueMap=labelmatrix(BW); % separation lines between plaques have to be removed using Membership and PlaqueMap

% get Zpos of maximal summed intensity
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(uint16(1:Pix(1)).',[1,Pix(2),Pix(3)]),'Roi2'},MetBlue,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave1]=max(double(IntensitySum),[],2);
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(uint16(1:Pix(2)),[Pix(1),1,Pix(3)]),'Roi2'},MetBlue,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave2]=max(double(IntensitySum),[],2);
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},MetBlue,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave3]=max(double(IntensitySum),[],2);
% PlaqueData.ZpixMaxIntSum=Wave3;
PlaqueData.PixCenterMaxIntSum=[Wave1,Wave2,Wave3];

% get maximal area in XY
AreaSum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},ones(Pix.','uint8'),@sum,'2D',[],[],{1,0}); % 12min
AreaSum=double(AreaSum)*prod(Res(1:2));
% get area at Zpos of max summed intensity
for m=1:size(PlaqueData,1)
%     PlaqueData.AreaMaxIntSum(m,1)=AreaSum(m,PlaqueData.ZpixMaxIntSum(m));
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
for Pl=1:size(PlaqueData,1) % A(d)=(r^2-d^2)*pi
%     PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415* (PlaqueData.RadiusMaxIntSum(Pl)^2 - (((1:Pix(3))-PlaqueData.ZpixMaxIntSum(Pl))*Res(1)).^2)/Res(1)^2);
    PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415* (PlaqueData.RadiusMaxIntSum(Pl)^2 - (((1:Pix(3))-PlaqueData.PixCenterMaxIntSum(Pl,3))*Res(1)).^2)/Res(1)^2);
end
for Z=1:Pix(3)
    Table2=table;
    MetBlue2D=MetBlue(:,:,Z);
    PlaqueMap2D=PlaqueMap(:,:,Z);
    Table2.LinInd=find(PlaqueMap2D~=0);
    Table2.Intensity=MetBlue2D(Table2.LinInd);
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
disp(['Roundation: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);

% BorderTouch, only positive if plaques touch border laterally
Wave1=ones(size(PlaqueMap),'uint8');Wave1(2:end-1,2:end-1,1:end)=0;
Wave1=unique(PlaqueMap(Wave1~=0&PlaqueMap~=0));
PlaqueData.BorderTouch(Wave1,1)=1;

% distance to Outside in all directions from core of the plaque as defined by max intensity
% keyboard;
for Pl=1:size(PlaqueData,1)
    PixCenterMaxIntSum=PlaqueData.PixCenterMaxIntSum(Pl,:).';
    Wave1=PixCenterMaxIntSum(1:2).*Res(1:2);
    Wave2=1-permute(Outside(PixCenterMaxIntSum(1),PixCenterMaxIntSum(2),:),[3,2,1]);
    Wave3=[sum(Wave2(1:PixCenterMaxIntSum(3)));sum(Wave2(PixCenterMaxIntSum(3):end))];
    PlaqueData.DistanceCenter2Border(Pl)={[[Wave1,Res(1:2).*Pix(1:2)-Wave1];Wave3.'*Res(3)]};
end

% Distance transformation
if prod(Pix.*Res)>ThresholdLargeFile
    ResWatershed=0.8;
else
    ResWatershed=0.4;
end
[DistanceFromBorder,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',ResWatershed); % 21min
disp(['DistanceFromPlaqueBorder: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
Membership(Outside==1)=0;
% remove islands
[PlaqueMap]=removeIslands_4(PlaqueMap>0,6,[0;3],Res);
PlaqueMap=uint16(PlaqueMap).*Membership;
disp(['RemoveIslands: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);

% Distance correction
DistanceFromBorder(DistanceFromBorder>50&PlaqueMap~=0)=50;
DistanceFromBorder(Outside==1)=0;
% if CrudeDataVisualization==1; Outside_Res2=interpolate3D(Outside,Res,Res2); end;
if CrudeDataVisualization==1; ex2Imaris_2(interpolate3D(Outside,Res,Res2),FilenameTotalCrude,'Outside'); end;
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
% PlaqueData.XYZpix=Wave1.Centroid;
% PlaqueData.XYZpix(:,1:3)=PlaqueData.XYZpix(:,[2,1,3]);
% PlaqueData.XYZum(:,1:3)=PlaqueData.XYZpix.*repmat(Res.',[size(PlaqueData,1),1]);


Wave2=Wave1.Centroid(:,[2,1,3]);
for Pl=1:size(PlaqueData,1)
    PlaqueData.PixCenter(Pl,1)={Wave2(Pl,:).'};
    PlaqueData.UmCenter(Pl,1)={Wave2(Pl,:).'.*Res};
end
PlaqueData(:,'PixelIdxList') = [];

% make 3D image of selected data at low resolution
if CrudeDataVisualization==1
    ex2Imaris_2(interpolate3D(DistanceFromBorder,Res,Res2),FilenameTotalCrude,'DistanceFromBorder');
    ex2Imaris_2(interpolate3D(PlaqueMap,Res,Res2),FilenameTotalCrude,'PlaqueMap');
    ex2Imaris_2(interpolate3D(Membership,Res,Res2),FilenameTotalCrude,'Membership');
%     DistanceFromBorder_Res2=interpolate3D(DistanceFromBorder,Res,Res2);
%     PlaqueMap_Res2=interpolate3D(PlaqueMap,Res,Res2);
%     Membership_Res2=interpolate3D(Membership,Res,Res2);
    
%     Wave1=regexprep(FilenameTotal,'.ims','_Crude.ims');
%     dataInspector3D({MetBlue_Res2;Outside_Res2;MetBlueBackgroundRatio_Res2;DistanceFromCore_Res2;MetBlueLocalPrc_Res2;PlaqueMap_Res2;WatershedDistance_Res2;DistanceFromBorder_Res2;Membership_Res2},Res2,{'MetBlue';'Outside';'MetBlueBackgroundRatio';'DistanceFromCore';'MetBlueLocalPrc';'PlaqueMap';'WatershedDistance';'DistanceFromBorder';'Membership'},1,Wave1,0);
%     disp(['SaveData2Imaris: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
end




