function [PlaqueMap,DistanceFromBorder,Membership,PlaqueData,Output]=wholeSliceQuantification_PlaqueDetection_3(MetBlue,Outside,Res,FilenameTotal,Core2BackgroundRatio,CrudeDataVisualization)

if exist('CrudeDataVisualization','Var')==0
    CrudeDataVisualization=1; % display low resolution version of selected data
end
if CrudeDataVisualization==1; Res2=[1.6;1.6;1.6]; end;
Pix=size(MetBlue).';
Output=struct;
% calculate crude local 90th percentile, if small kernel then 90th percentile locally enhanced at plaques and plaques might be excluded
tic;
[MetBluePrc90]=percentileFilter3D(MetBlue,90,[27;27;3],Res,[20;20;Res(3)],Outside); % 500µm
disp(['MetBluePrc90: ',num2str(toc/60),' min']);

% define PlaqueCore as contiguous voxels of larger than 2 µm^3 over the defined threshold
tic;
PlaqueCore=(MetBlue>=MetBluePrc90*Core2BackgroundRatio) & Outside==0; % previously factor 2
if CrudeDataVisualization==1; [MetBlueBackgroundRatio_Res2,Wave1]=interpolate3D(uint16(single(MetBlue)./single(MetBluePrc90)*100),Res,Res2); PixCrude=Wave1.Pix; end;
if CrudeDataVisualization==1; MetBluePrc90_Res2=interpolate3D(MetBluePrc90,Res,Res2); end;
clear MetBluePrc90;
BW=bwconncomp(PlaqueCore,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueData=PlaqueData(PlaqueData.Volume>=2,:);
BW.PixelIdxList=PlaqueData.PixelIdxList.';
BW.NumObjects=size(PlaqueData,1);
PlaqueCore=labelmatrix(BW);
clear BW;
disp(['PlaqueCore: ',num2str(toc/60),' min']);

% calculate distance from core to define regions excluded from BackgroundSubtraction
tic
[DistanceFromCore]=distanceMat_4(PlaqueCore,{'DistInOut'},Res,1,1,1,50,'uint16',0.8); % 3.5min
disp(['PlaqueCoreDistance: ',num2str(toc/60),' min']);
clear PlaqueCore;
Exclude=Outside;
Exclude(DistanceFromCore<60)=1;
tic
[MetBlueLocalPrc]=percentileFilter2D(MetBlue,98,[35;35],Res,[1.6;1.6;Res(3)],Exclude); % 18min
clear Exclude;
disp(['MetBlueLocalPrc: ',num2str(toc/60),' min']);
PlaqueMap=(MetBlue>MetBlueLocalPrc & Outside==0 & DistanceFromCore<=65) | DistanceFromCore<=50;
if CrudeDataVisualization==1; MetBlueLocalPrc_Res2=interpolate3D(MetBlueLocalPrc,Res,Res2); end;
clear MetBlueLocalPrc; 


% remove plaques that have no plaque core or are smaller than 3µm diameter
BW=bwconncomp(PlaqueMap,6);
PlaqueData=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','PixelIdxList'});
PlaqueData.Volume=PlaqueData.NumPix*prod(Res(1:3));
PlaqueMap=labelmatrix(BW);
Wave1=PlaqueMap(DistanceFromCore<=50);
if CrudeDataVisualization==1; DistanceFromCore_Res2=interpolate3D(DistanceFromCore,Res,Res2); end;
clear DistanceFromCore; 
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
PlaqueData=PlaqueData(Wave2,:);
PlaqueData=PlaqueData(PlaqueData.Volume>=27,:);
PlaqueMap=zeros(size(PlaqueMap),'uint16');
PlaqueMap(cell2mat(PlaqueData.PixelIdxList))=1;

% seperate fused plaques according to intensity profile
if exist('SeparatePlaques','Var')==0
    SeparatePlaques='Intensity';
end
if strcmp(SeparatePlaques,'Intensity')
    tic;
    if CrudeDataVisualization==1; MetBlue_Res2=interpolate3D(MetBlue,Res,Res2); end;
    
%     WatershedDistance=MetBlue;
    
    ResCalc1=max([Res,[0.4;0.4;0.4]],[],2);
    if isequal(ResCalc1,Res)==0
        WatershedDistance=interpolate3D(MetBlue,Res,ResCalc1);
        PlaqueMap2=interpolate3D(PlaqueMap,Res,ResCalc1);
    end
    [~,Wave1]=imdilateWindow(4,ResCalc1);
        
    for m=1:20 % 15x takes 25min
        WatershedDistance=imgaussfilt3(WatershedDistance,10,'FilterSize',Wave1); % kernel 7 takes 2min, 5 takes 1.5min, 3 takes 1.3min
    end
    disp(['Gaussian: ',num2str(toc/60),' min']);
    % prevent that parts of nearby plaques are accounted to close very bright plaques, therefore set everything more distant than 2µm from a plaque to 65535
    PlaqueMap2=imdilate(PlaqueMap2,imdilateWindow([2;2;2],ResCalc1));
    WatershedDistance(PlaqueMap2==0)=0;
    
    WatershedDistance=max(WatershedDistance(:))-WatershedDistance;
    
    PlaqueMapWatershed=watershed(WatershedDistance,26); % 100min for kernel==6
    if isequal(ResCalc1,Res)==0
        PlaqueMapWatershed=interpolate3D(PlaqueMapWatershed,[],[],Pix);
    end
        
    tic;
        disp(['Watershed: ',num2str(toc/60),' min']);
    % % %     if CrudeDataVisualization==1
    % % %         tic;
    % % %         LocalMinima=imregionalmin(WatershedDistance,26); % 100min for kernel==6
    % % %         disp(['LocalMinima: ',num2str(toc/60),' min']);
    % % %         WatershedDistance(LocalMinima==1)=0;
    % % %     end
    if max(PlaqueMapWatershed(:))>65535
        keyboard
    end
    PlaqueMapWatershed=uint16(PlaqueMapWatershed);
    PlaqueMapWatershed(PlaqueMap==0)=0;
elseif strcmp(SeparatePlaques,'Distance')
    tic;
    [WatershedDistance]=distanceMat_4(imdilate(PlaqueMap,imdilateWindow([4;4;4],Res)),{'DistInOut'},Res,1,1,1,50,'uint16',0.8); % 3.5min
    disp(['WatershedDistance: ',num2str(toc/60),' min']);
    tic;
    PlaqueMapWatershed=uint16(watershed(WatershedDistance,26));
    disp(['Watershed: ',num2str(toc/60),' min']);
    PlaqueMapWatershed(PlaqueMap==0)=0;
end

if CrudeDataVisualization==1; WatershedDistance_Res2=interpolate3D(WatershedDistance,[],[],PixCrude); end;
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
IntensitySum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},MetBlue,@sum,'2D',[],[],{1,0}); % 12min
[~,Wave3]=max(double(IntensitySum),[],2);
PlaqueData.ZpixMaxIntSum=Wave3;

% get maximal area in XY
AreaSum=accumarray_9({PlaqueMap,'Roi1';repmat(permute(uint16(1:Pix(3)),[1,3,2]),[Pix(1),Pix(2),1]),'Roi2'},ones(Pix.','uint8'),@sum,'2D',[],[],{1,0}); % 12min
AreaSum=double(AreaSum)*prod(Res(1:2));
% get area at Zpos of max summed intensity
for m=1:size(PlaqueData,1)
    PlaqueData.AreaMaxIntSum(m,1)=AreaSum(m,PlaqueData.ZpixMaxIntSum(m));
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
tic;
for Pl=1:size(PlaqueData,1) % A(d)=(r^2-d^2)*pi
%     PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415*(PlaqueData.RadiusMaxIntSum(Pl)^2-((1:Pix(3))-PlaqueData.ZpixMaxIntSum(Pl)).^2*Res(3)^2)/Res(3)^2);
    PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415* (PlaqueData.RadiusMaxIntSum(Pl)^2 - (((1:Pix(3))-PlaqueData.ZpixMaxIntSum(Pl))*Res(1)).^2)/Res(1)^2);
    
%     PlaqueData.AllowedPixel(Pl,1:Pix(3))=uint32(3.1415*( (PlaqueData.RadiusMaxIntSum(Pl)/Res(1))^2 - (((1:Pix(3))-PlaqueData.ZpixMaxIntSum(Pl))/Res(1)).^2 )).';
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
%     disp(Z)
end
clear MetBlue;
disp(['Roundation: ',num2str(toc/60),' min']);

% Distance transformation
tic;
[DistanceFromBorder,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',0.8); % 21min
disp(['DistanceFromPlaqueBorder: ',num2str(toc/60),' min']);
Membership(Outside==1)=0;
% remove islands
tic;
[PlaqueMap]=removeIslands_3(PlaqueMap>0,6,[0;3],prod(Res(:)));
PlaqueMap=uint16(PlaqueMap).*Membership;
disp(['RemoveIslands: ',num2str(toc/60),' min']);

% Distance correction
DistanceFromBorder(DistanceFromBorder>50&PlaqueMap~=0)=50;
DistanceFromBorder(Outside==1)=0;
if CrudeDataVisualization==1; Outside_Res2=interpolate3D(Outside,Res,Res2); end;
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
PlaqueData.XYZpix=Wave1.Centroid;
PlaqueData.XYZpix(:,1:3)=PlaqueData.XYZpix(:,[2,1,3]);
PlaqueData.XYZum(:,1:3)=PlaqueData.XYZpix.*repmat(Res.',[size(PlaqueData,1),1]);

PlaqueData(:,'PixelIdxList') = [];
PlaqueData(:,'AllowedPixel') = [];

% make 3D image of selected data at low resolution
if CrudeDataVisualization==1
    DistanceFromBorder_Res2=interpolate3D(DistanceFromBorder,Res,Res2);
    PlaqueMap_Res2=interpolate3D(PlaqueMap,Res,Res2);
    Membership_Res2=interpolate3D(Membership,Res,Res2);
    tic
    Wave1=regexprep(FilenameTotal,'.ims','_Crude.ims');
    dataInspector3D({MetBlue_Res2;Outside_Res2;MetBluePrc90_Res2;MetBlueBackgroundRatio_Res2;DistanceFromCore_Res2;MetBlueLocalPrc_Res2;PlaqueMap_Res2;WatershedDistance_Res2;DistanceFromBorder_Res2;Membership_Res2},Res2,{'MetBlue';'Outside';'MetBluePrc90';'MetBlueBackgroundRatio';'DistanceFromCore';'MetBlueLocalPrc';'PlaqueMap';'WatershedDistance';'DistanceFromBorder';'Membership'},1,Wave1,0);
    disp(['SaveData2Imaris: ',num2str(toc/60),' min']);
end

% keyboard;