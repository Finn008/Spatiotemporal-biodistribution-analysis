function [vSpots,spotsInfo]=generateSpots(Application,RegionsOfInterest,ChannelIndex,EstimateDiameterXYZ,SubtractBackground,SpotFiltersString,RegionsFromLocalContrast,RegionsThresholdAutomatic,RegionsThresholdManual,RegionsSpotsDiameterFromVolume,RegionsCreateChannel,spotsInfo,spotsName,RGBA)

vSpots=Application.GetImageProcessing.DetectEllipticSpotsRegionGrowing(Application.GetDataSet,RegionsOfInterest,...
    ChannelIndex,EstimateDiameterXYZ,SubtractBackground,SpotFiltersString,RegionsFromLocalContrast,RegionsThresholdAutomatic,...
    RegionsThresholdManual,RegionsSpotsDiameterFromVolume,RegionsCreateChannel);
 	
% track spots over time
% try;
%     vSpots=Application.GetImageProcessing.TrackSurfacesAutoregressiveMotion(vSpots,aMaximalDistance,aGapSize,aTrackFiltersString);
% catch; end;

aViewer=Application.GetViewer; % otherwise surface not generated
if strcmp(char(aViewer),'eViewerSurpass')==0;
    aViewer = Imaris.tViewer.eViewerSurpass;
%     pause(1);
    Application.SetViewer(aViewer);
end
% show surfaces
vSurpassScene = Application.GetSurpassScene;

if isempty(vSurpassScene)
    a1=1;
end

if exist('spotsName','var') && isempty(spotsName)==0
    vSpots.SetName(spotsName);
end
if exist('RGBA','var') && isempty(RGBA)==0
    RGBA=RGBAconverter(RGBA);
    vSpots.SetColorRGBA(RGBA);
end

vSurpassScene.AddChild(vSpots, -1);
if exist('spotsInfo','var') && strcmp(spotsInfo,'getInfo');
    [spotsInfo]=getSurfaceInfo2(vSpots);
end