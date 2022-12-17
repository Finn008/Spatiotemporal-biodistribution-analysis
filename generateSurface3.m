%     Application   aDataSet
%     Roi           aRegionsOfInterest
%     Channel       aChannelIndex
%     Smooth        aSmoothFilterWidth
%     Background    aLocalContrastFilterWidth
%     LowerEnabled  aLowerThresholdEnabled
%     LowerAuto     aIntensityLowerThresholdAutomatic
%     LowerManual   aIntensityLowerThresholdManual
%     UpperEnabled  aUpperThresholdEnabled
%     UpperAuto     aIntensityUpperThresholdAutomatic
%     UpperManual   aIntensityUpperThresholdManual
%     SeedsDiameter aSeedsEstimateDiameter
%                   aSeedsFiltersString
%     SurfaceFilter aSurfaceFiltersString 
%     Gap
%     TrackFilter
%     MaxDist
%     SurfaceInfo
%     StoreAsChannel
%     RGBA
% Smooth==0 --> disabled
% Background==0 --> no local contrast
% LowerEnabled==1 --> LowerAuto and LowerManual ignored
% LowerAuto==1 --> LowerManual ignored


function [vSurfaces,SurfaceInfo]=generateSurface3(ii)
% keyboard; % delete existant Surface of same name
v2struct(ii);
setImarisViewer(Application,'surpass');
% set nonexistent inputs to empty
nonexistentVars={...
    'Background','0';...
    'BlackBox','[]';...
    'CreateRegionsChannel','0';...
    'DiaXYZ','[1,1,1]';...
    'Gap','[]';...
    'GrowingType','0';...
    'LowerAuto','1';...
    'LowerEnabled','0';...
    'MaxDist','[]';...
    'ObjectType','''Surface''';...
    'RegionsFromLocalContrast','0';...
    'RGBA','[]';...
    'Roi','[]';...
    'SeedsBackground','0';...
    'SeedsDiameter','0';...
    'SeedsFilter','[]';...
    'Smooth','0';...
    'StoreAsChannel','0';...
    'SurfaceFilter','[]';...
    'SurfaceInfo','[]';...
    'SurfaceName','[]';...
    'TrackFilter','[]';...    
    'UpperAuto','1';...
    'UpperEnabled','0';...
    };

for m=1:size(nonexistentVars,1)
    if exist(nonexistentVars{m,1})~=1
%         if isfield(i,nonexistentVars{m,1})==0
%         path=['i.',nonexistentVars{m,1},'=',nonexistentVars{m,2},';'];
        Path2File=[nonexistentVars{m,1},'=',nonexistentVars{m,2},';'];
        eval(Path2File);
    end
end



if isnumeric(Channel)==0
    Channel=getChannelId(Application,Channel);
else
    Channel=Channel;
end
if isempty(BlackBox)==0
%     [DataOrig]=Im2Matlab(Application,Channel,1);
    [DataOrig]=im2Matlab_2(Application,Channel,1);
    DataBlack=DataOrig;
    DataBlack(:,:,1)=BlackBox;
    DataBlack(:,:,end)=BlackBox;
    DataBlack(:,1,:)=BlackBox;
    DataBlack(:,end,:)=BlackBox;
    DataBlack(1,:,:)=BlackBox;
    DataBlack(end,:,:)=BlackBox;
    Ex2Imaris(Application,DataBlack,Channel,1);
end

% automatic is default
if exist('LowerManual')==1 && LowerManual~=0
% if isfield(i,'LowerManual')
    LowerEnabled=1;
    LowerAuto=0;
else % use automatic
     LowerManual=10;
     LowerAuto=1;
     keyboard; % does not work
end
if exist('UpperManual')==1
%     if isfield(i,'UpperManual')
    UpperEnabled=1;
    UpperAuto=0;
else
%     UpperEnabled=0;
     UpperManual=0;
end

if strcmp(ObjectType,'Spot')
    vSurfaces=Application.GetImageProcessing.DetectEllipticSpotsRegionGrowing(...
        Application.GetDataSet,...
        Roi,...
        Channel-1,...
        DiaXYZ,...
        Background,...
        SurfaceFilter,...
        RegionsFromLocalContrast,... % RegionsFromLocalContrast
        LowerAuto,... % RegionsThresholdAutomatic
        LowerManual,... % RegionsThresholdManual
        GrowingType,...
        CreateRegionsChannel);
elseif strcmp(ObjectType,'Surface')
    if SeedsDiameter==0
        vSurfaces=Application.GetImageProcessing.DetectSurfacesWithUpperThreshold(...
            Application.GetDataSet,...
            Roi,...
            Channel-1,...
            Smooth,...
            Background,...
            LowerEnabled,...
            LowerAuto,...
            LowerManual,...
            UpperEnabled,...
            UpperAuto,...
            UpperManual,...
            SurfaceFilter);
    else
        vSurfaces=Application.GetImageProcessing.DetectSurfacesRegionGrowingWithUpperThreshold(...
            Application.GetDataSet,...
            Roi,...
            Channel-1,...
            Smooth,...
            Background,...
            LowerEnabled,...
            LowerAuto,...
            LowerManual,...
            UpperEnabled,...
            UpperAuto,...
            UpperManual,...
            SeedsDiameter,...
            SeedsBackground,...
            SeedsFilter,...
            SurfaceFilter);
    end
end
if isempty(MaxDist)==0
    if exist('TrackAlgorythm')~=1
        TrackAlgorythm='AutoregressiveMotion';
    end
    if strfind1(TrackAlgorythm,'AutoregressiveMotion',1)
        vSurfaces=Application.GetImageProcessing.TrackSurfacesAutoregressiveMotion(vSurfaces,MaxDist,Gap,TrackFilter);
    elseif strfind1(TrackAlgorythm,'BrownianMotion',1)
        vSurfaces=Application.GetImageProcessing.TrackSurfacesBrownianMotion(vSurfaces,MaxDist,Gap,TrackFilter);
    end
end





setImarisViewer(Application,'surpass')

% show Surfaces
vSurpassScene = Application.GetSurpassScene;

if isempty(vSurpassScene)
    a1=asdfedd;
end
% if exist('SurfaceName','var') && isempty(SurfaceName)==0
if isempty(SurfaceName)==0
    % delete Surface of same name
    [Object2delete,Ind,ObjectList]=selectObject(Application,SurfaceName);
    if isempty(Object2delete)==0
        Application.GetSurpassScene.RemoveChild(Object2delete);
    end
    vSurfaces.SetName(SurfaceName);
end
% if exist('RGBA','var') && isempty(RGBA)==0
if isempty(RGBA)==0
    RGBA=RGBAconverter(RGBA);
    vSurfaces.SetColorRGBA(RGBA);
end

vSurpassScene.AddChild(vSurfaces, -1);
if StoreAsChannel==1
    keyboard;
    [Data3D]=im2Matlab_3(Application,SurfaceName,1,'Surface')
%     [mask]=im2Matlab_2(Application,{vSurfaces},[],'Surface')
    ex2Imaris_2(Data3D,Application,SurfaceName,1)
%     Ex2Imaris(Application,mask,SurfaceName,1);
    Application.GetSurpassScene.RemoveChild(vSurfaces);
%     vSurfaces=mask;
%     clear mask;
    clear Data3D;
end

if isempty(SurfaceInfo)==0
    % if exist('SurfaceInfo','var') && strcmp(SurfaceInfo,'getInfo');
    [SurfaceInfo]=getObjectInfo_2(vSurfaces,[],Application);
%     [SurfaceInfo]=getObjectInfo(vSurfaces);
else
    SurfaceInfo=[];
end
if isempty(BlackBox)==0
    keyboard;
    Ex2Imaris(Application,DataOrig,Channel,1);
end
