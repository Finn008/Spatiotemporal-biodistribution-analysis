%     application
%     aRegionsOfInterest
%     aChannelIndex
%     aSmoothFilterWidth
%     aLocalContrastFilterWidth
%     aLowerThresholdEnabled
%     aIntensityLowerThresholdAutomatic
%     aIntensityLowerThresholdManual
%     aUpperThresholdEnabled
%     aIntensityUpperThresholdAutomatic
%     aIntensityUpperThresholdManual
%     aSurfaceFiltersString
%     aGapSize
%     aTrackFiltersString
%     aMaximalDistance
%     surfaceInfo
%     surfaceName
%     RGBA

function [vSurfaces,surfaceInfo]=generateSurface(application,aRegionsOfInterest,aChannelIndex,aSmoothFilterWidth,aLocalContrastFilterWidth,aLowerThresholdEnabled,aIntensityLowerThresholdAutomatic,aIntensityLowerThresholdManual,aUpperThresholdEnabled,aIntensityUpperThresholdAutomatic,aIntensityUpperThresholdManual,aSurfaceFiltersString,aGapSize,aTrackFiltersString,aMaximalDistance,surfaceInfo,surfaceName,RGBA)

vSurfaces=application.GetImageProcessing.DetectSurfacesWithUpperThreshold(application.GetDataSet,aRegionsOfInterest,aChannelIndex,aSmoothFilterWidth,aLocalContrastFilterWidth,aLowerThresholdEnabled,aIntensityLowerThresholdAutomatic,aIntensityLowerThresholdManual,aUpperThresholdEnabled,aIntensityUpperThresholdAutomatic,aIntensityUpperThresholdManual,aSurfaceFiltersString);
% vSurfaces=application.GetImageProcessing.DetectSurfacesRegionGrowingWithUpperThreshold(application.GetDataSet,aRegionsOfInterest,aChannelIndex,aSmoothFilterWidth,aLocalContrastFilterWidth,aLowerThresholdEnabled,aIntensityLowerThresholdAutomatic,aIntensityLowerThresholdManual,aUpperThresholdEnabled,aIntensityUpperThresholdAutomatic,aIntensityUpperThresholdManual,aSeedsEstimateDiameter,aSeedsSubtractBackground,aSeedsFiltersString);

try;
    vSurfaces=application.GetImageProcessing.TrackSurfacesAutoregressiveMotion(vSurfaces,aMaximalDistance,aGapSize,aTrackFiltersString);
catch; end;
aViewer=application.GetViewer; % otherwise surface not generated
if strcmp(char(aViewer),'eViewerSurpass')==0;
    aViewer = Imaris.tViewer.eViewerSurpass;
%     pause(1);
    application.SetViewer(aViewer);
end
% show surfaces
vSurpassScene = application.GetSurpassScene;

if isempty(vSurpassScene)
    a1=1;
end

if exist('surfaceName','var') && isempty(surfaceName)==0
    vSurfaces.SetName(surfaceName);
end
if exist('RGBA','var') && isempty(RGBA)==0
    RGBA=RGBAconverter(RGBA);
    vSurfaces.SetColorRGBA(RGBA);
end

vSurpassScene.AddChild(vSurfaces, -1);
if exist('surfaceInfo','var') && strcmp(surfaceInfo,'getInfo');
    [surfaceInfo]=getObjectInfo(vSurfaces);
end