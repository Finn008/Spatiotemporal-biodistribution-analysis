% .ims: does not find Channelname
% [Fileinfo2add,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo('ExEvaR_M577_Roi1_TyLamp1.lsm');
% [Fileinfo2add,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo('2014.12.10_110b.lsm');
% [Fileinfo2add,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo('2014.11.25_102b.czi');
% [Fileinfo2add,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo('2014.11.25_106a.czi');
function [Fileinfo,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo(FilenameTotal)
global W;

if iscell(FilenameTotal)
    FilenameTotal=FilenameTotal{1};
end
[Path2file,Report]=getPathRaw(FilenameTotal);

Type=FilenameTotal(end-3:end);

try
    evalc('Wave1=bfGetReader(Path2file);'); % renew
catch Error
    keyboard;
end
OmeMetaDataRaw=Wave1.getMetadataStore();
OriginalMetaDataRaw=Wave1.getSeriesMetadata();
GlobalMetadataRaw=Wave1.getGlobalMetadata();
javaMethod('merge','loci.formats.MetadataTools',GlobalMetadataRaw,OriginalMetaDataRaw,'Global ');
% % % % % % evalc(['Wave1=bfopen(''',Path2file,''',1,1,1,1);']);
% % % % % % OriginalMetaDataRaw=Wave1{1,2};
% % % % % % OmeMetaDataRaw=Wave1{1,4};
clear Wave1;
[OriginalMetaData]=readHashtable(OriginalMetaDataRaw);
for m=1:size(OriginalMetaData,1)
    Wave1=OriginalMetaData.Value{m,1};
    if isnumeric(Wave1) && isequal(size(Wave1),[1,1])
        OriginalMetaData.Num(m,1)=Wave1;
    end
end


Str='getArcAnnotationRef, getArcID, getArcLotNumber, getArcManufacturer, getArcModel, getArcPower, getArcSerialNumber, getArcType, getBinaryFileFileName, getBinaryFileMIMEType, getBinaryFileSize, getBinaryOnlyMetadataFile, getBinaryOnlyUUID, getBooleanAnnotationAnnotationCount, getBooleanAnnotationAnnotationRef, getBooleanAnnotationAnnotator, getBooleanAnnotationCount, getBooleanAnnotationDescription, getBooleanAnnotationID, getBooleanAnnotationNamespace, getBooleanAnnotationValue, getChannelAcquisitionMode, getChannelAnnotationRef, getChannelAnnotationRefCount, getChannelColor, getChannelContrastMethod, getChannelCount, getChannelEmissionWavelength, getChannelExcitationWavelength, getChannelFilterSetRef, getChannelFluor, getChannelID, getChannelIlluminationType, getChannelLightSourceSettingsAttenuation, getChannelLightSourceSettingsID, getChannelLightSourceSettingsWavelength, getChannelName, getChannelNDFilter, getChannelPinholeSize, getChannelPockelCellSetting, getChannelSamplesPerPixel, getCommentAnnotationAnnotationCount, getCommentAnnotationAnnotationRef, getCommentAnnotationAnnotator, getCommentAnnotationCount, getCommentAnnotationDescription, getCommentAnnotationID, getCommentAnnotationNamespace, getCommentAnnotationValue, getDatasetAnnotationRef, getDatasetAnnotationRefCount, getDatasetCount, getDatasetDescription, getDatasetExperimenterGroupRef, getDatasetExperimenterRef, getDatasetID, getDatasetImageRef, getDatasetImageRefCount, getDatasetName, getDatasetRefCount, getDetectorAmplificationGain, getDetectorAnnotationRef, getDetectorAnnotationRefCount, getDetectorCount, getDetectorGain, getDetectorID, getDetectorLotNumber, getDetectorManufacturer, getDetectorModel, getDetectorOffset, getDetectorSerialNumber, getDetectorSettingsBinning, getDetectorSettingsGain, getDetectorSettingsID, getDetectorSettingsIntegration, getDetectorSettingsOffset, getDetectorSettingsReadOutRate, getDetectorSettingsVoltage, getDetectorSettingsZoom, getDetectorType, getDetectorVoltage, getDetectorZoom, getDichroicAnnotationRef, getDichroicAnnotationRefCount, getDichroicCount, getDichroicID, getDichroicLotNumber, getDichroicManufacturer, getDichroicModel, getDichroicSerialNumber, getDoubleAnnotationAnnotationCount, getDoubleAnnotationAnnotationRef, getDoubleAnnotationAnnotator, getDoubleAnnotationCount, getDoubleAnnotationDescription, getDoubleAnnotationID, getDoubleAnnotationNamespace, getDoubleAnnotationValue, getEllipseAnnotationRef, getEllipseFillColor, getEllipseFillRule, getEllipseFontFamily, getEllipseFontSize, getEllipseFontStyle, getEllipseID, getEllipseLineCap, getEllipseLocked, getEllipseRadiusX, getEllipseRadiusY, getEllipseStrokeColor, getEllipseStrokeDashArray, getEllipseStrokeWidth, getEllipseText, getEllipseTheC, getEllipseTheT, getEllipseTheZ, getEllipseTransform, getEllipseVisible, getEllipseX, getEllipseY, getExperimentCount, getExperimentDescription, getExperimenterAnnotationRef, getExperimenterAnnotationRefCount, getExperimenterCount, getExperimenterEmail, getExperimenterFirstName, getExperimenterGroupAnnotationRef, getExperimenterGroupAnnotationRefCount, getExperimenterGroupCount, getExperimenterGroupDescription, getExperimenterGroupExperimenterRef, getExperimenterGroupExperimenterRefCount, getExperimenterGroupID, getExperimenterGroupLeader, getExperimenterGroupName, getExperimenterID, getExperimenterInstitution, getExperimenterLastName, getExperimenterMiddleName, getExperimenterUserName, getExperimentExperimenterRef, getExperimentID, getExperimentType, getFilamentAnnotationRef, getFilamentID, getFilamentLotNumber, getFilamentManufacturer, getFilamentModel, getFilamentPower, getFilamentSerialNumber, getFilamentType, getFileAnnotationAnnotationCount, getFileAnnotationAnnotationRef, getFileAnnotationAnnotator, getFileAnnotationCount, getFileAnnotationDescription, getFileAnnotationID, getFileAnnotationNamespace, getFilterAnnotationRef, getFilterAnnotationRefCount, getFilterCount, getFilterFilterWheel, getFilterID, getFilterLotNumber, getFilterManufacturer, getFilterModel, getFilterSerialNumber, getFilterSetCount, getFilterSetDichroicRef, getFilterSetEmissionFilterRef, getFilterSetEmissionFilterRefCount, getFilterSetExcitationFilterRef, getFilterSetExcitationFilterRefCount, getFilterSetID, getFilterSetLotNumber, getFilterSetManufacturer, getFilterSetModel, getFilterSetSerialNumber, getFilterType, getGenericExcitationSourceAnnotationRef, getGenericExcitationSourceID, getGenericExcitationSourceLotNumber, getGenericExcitationSourceManufacturer, getGenericExcitationSourceMap, getGenericExcitationSourceModel, getGenericExcitationSourcePower, getGenericExcitationSourceSerialNumber, getImageAcquisitionDate, getImageAnnotationRef, getImageAnnotationRefCount, getImageCount, getImageDescription, getImageExperimenterGroupRef, getImageExperimenterRef, getImageExperimentRef, getImageID, getImageInstrumentRef, getImageMicrobeamManipulationRef, getImageName, getImageROIRef, getImageROIRefCount, getImagingEnvironmentAirPressure, getImagingEnvironmentCO2Percent, getImagingEnvironmentHumidity, getImagingEnvironmentMap, getImagingEnvironmentTemperature, getInstrumentAnnotationRef, getInstrumentAnnotationRefCount, getInstrumentCount, getInstrumentID, getLabelAnnotationRef, getLabelFillColor, getLabelFillRule, getLabelFontFamily, getLabelFontSize, getLabelFontStyle, getLabelID, getLabelLineCap, getLabelLocked, getLabelStrokeColor, getLabelStrokeDashArray, getLabelStrokeWidth, getLabelText, getLabelTheC, getLabelTheT, getLabelTheZ, getLabelTransform, getLabelVisible, getLabelX, getLabelY, getLaserAnnotationRef, getLaserFrequencyMultiplication, getLaserID, getLaserLaserMedium, getLaserLotNumber, getLaserManufacturer, getLaserModel, getLaserPockelCell, getLaserPower, getLaserPulse, getLaserPump, getLaserRepetitionRate, getLaserSerialNumber, getLaserTuneable, getLaserType, getLaserWavelength, getLeaderCount, getLightEmittingDiodeAnnotationRef, getLightEmittingDiodeID, getLightEmittingDiodeLotNumber, getLightEmittingDiodeManufacturer, getLightEmittingDiodeModel, getLightEmittingDiodePower, getLightEmittingDiodeSerialNumber, getLightPathAnnotationRef, getLightPathAnnotationRefCount, getLightPathDichroicRef, getLightPathEmissionFilterRef, getLightPathEmissionFilterRefCount, getLightPathExcitationFilterRef, getLightPathExcitationFilterRefCount, getLightSourceAnnotationRefCount, getLightSourceCount, getLightSourceType, getLineAnnotationRef, getLineFillColor, getLineFillRule, getLineFontFamily, getLineFontSize, getLineFontStyle, getLineID, getLineLineCap, getLineLocked, getLineMarkerEnd, getLineMarkerStart, getLineStrokeColor, getLineStrokeDashArray, getLineStrokeWidth, getLineText, getLineTheC, getLineTheT, getLineTheZ, getLineTransform, getLineVisible, getLineX1, getLineX2, getLineY1, getLineY2, getListAnnotationAnnotationCount, getListAnnotationAnnotationRef, getListAnnotationAnnotator, getListAnnotationCount, getListAnnotationDescription, getListAnnotationID, getListAnnotationNamespace, getLongAnnotationAnnotationCount, getLongAnnotationAnnotationRef, getLongAnnotationAnnotator, getLongAnnotationCount, getLongAnnotationDescription, getLongAnnotationID, getLongAnnotationNamespace, getLongAnnotationValue, getMapAnnotationAnnotationCount, getMapAnnotationAnnotationRef, getMapAnnotationAnnotator, getMapAnnotationCount, getMapAnnotationDescription, getMapAnnotationID, getMapAnnotationNamespace, getMapAnnotationValue, getMaskAnnotationRef, getMaskFillColor, getMaskFillRule, getMaskFontFamily, getMaskFontSize, getMaskFontStyle, getMaskHeight, getMaskID, getMaskLineCap, getMaskLocked, getMaskStrokeColor, getMaskStrokeDashArray, getMaskStrokeWidth, getMaskText, getMaskTheC, getMaskTheT, getMaskTheZ, getMaskTransform, getMaskVisible, getMaskWidth, getMaskX, getMaskY, getMicrobeamManipulationCount, getMicrobeamManipulationDescription, getMicrobeamManipulationExperimenterRef, getMicrobeamManipulationID, getMicrobeamManipulationLightSourceSettingsAttenuation, getMicrobeamManipulationLightSourceSettingsCount, getMicrobeamManipulationLightSourceSettingsID, getMicrobeamManipulationLightSourceSettingsWavelength, getMicrobeamManipulationRefCount, getMicrobeamManipulationROIRef, getMicrobeamManipulationROIRefCount, getMicrobeamManipulationType, getMicroscopeLotNumber, getMicroscopeManufacturer, getMicroscopeModel, getMicroscopeSerialNumber, getMicroscopeType, getObjectiveAnnotationRef, getObjectiveAnnotationRefCount, getObjectiveCalibratedMagnification, getObjectiveCorrection, getObjectiveCount, getObjectiveID, getObjectiveImmersion, getObjectiveIris, getObjectiveLensNA, getObjectiveLotNumber, getObjectiveManufacturer, getObjectiveModel, getObjectiveNominalMagnification, getObjectiveSerialNumber, getObjectiveSettingsCorrectionCollar, getObjectiveSettingsID, getObjectiveSettingsMedium, getObjectiveSettingsRefractiveIndex, getObjectiveWorkingDistance, getPixelsBigEndian, getPixelsBinDataBigEndian, getPixelsBinDataCount, getPixelsDimensionOrder, getPixelsID, getPixelsInterleaved, getPixelsPhysicalSizeX, getPixelsPhysicalSizeY, getPixelsPhysicalSizeZ, getPixelsSignificantBits, getPixelsSizeC, getPixelsSizeT, getPixelsSizeX, getPixelsSizeY, getPixelsSizeZ, getPixelsTimeIncrement, getPixelsType, getPlaneAnnotationRef, getPlaneAnnotationRefCount, getPlaneCount, getPlaneDeltaT, getPlaneExposureTime, getPlaneHashSHA1, getPlanePositionX, getPlanePositionY, getPlanePositionZ, getPlaneTheC, getPlaneTheT, getPlaneTheZ, getPlateAcquisitionAnnotationRef, getPlateAcquisitionAnnotationRefCount, getPlateAcquisitionCount, getPlateAcquisitionDescription, getPlateAcquisitionEndTime, getPlateAcquisitionID, getPlateAcquisitionMaximumFieldCount, getPlateAcquisitionName, getPlateAcquisitionStartTime, getPlateAcquisitionWellSampleRef, getPlateAnnotationRef, getPlateAnnotationRefCount, getPlateColumnNamingConvention, getPlateColumns, getPlateCount, getPlateDescription, getPlateExternalIdentifier, getPlateFieldIndex, getPlateID, getPlateName, getPlateRefCount, getPlateRowNamingConvention, getPlateRows, getPlateStatus, getPlateWellOriginX, getPlateWellOriginY, getPointAnnotationRef, getPointFillColor, getPointFillRule, getPointFontFamily, getPointFontSize, getPointFontStyle, getPointID, getPointLineCap, getPointLocked, getPointStrokeColor, getPointStrokeDashArray, getPointStrokeWidth, getPointText, getPointTheC, getPointTheT, getPointTheZ, getPointTransform, getPointVisible, getPointX, getPointY, getPolygonAnnotationRef, getPolygonFillColor, getPolygonFillRule, getPolygonFontFamily, getPolygonFontSize, getPolygonFontStyle, getPolygonID, getPolygonLineCap, getPolygonLocked, getPolygonPoints, getPolygonStrokeColor, getPolygonStrokeDashArray, getPolygonStrokeWidth, getPolygonText, getPolygonTheC, getPolygonTheT, getPolygonTheZ, getPolygonTransform, getPolygonVisible, getPolylineAnnotationRef, getPolylineFillColor, getPolylineFillRule, getPolylineFontFamily, getPolylineFontSize, getPolylineFontStyle, getPolylineID, getPolylineLineCap, getPolylineLocked, getPolylineMarkerEnd, getPolylineMarkerStart, getPolylinePoints, getPolylineStrokeColor, getPolylineStrokeDashArray, getPolylineStrokeWidth, getPolylineText, getPolylineTheC, getPolylineTheT, getPolylineTheZ, getPolylineTransform, getPolylineVisible, getProjectAnnotationRef, getProjectAnnotationRefCount, getProjectCount, getProjectDatasetRef, getProjectDescription, getProjectExperimenterGroupRef, getProjectExperimenterRef, getProjectID, getProjectName, getReagentAnnotationRef, getReagentAnnotationRefCount, getReagentCount, getReagentDescription, getReagentID, getReagentName, getReagentReagentIdentifier, getRectangleAnnotationRef, getRectangleFillColor, getRectangleFillRule, getRectangleFontFamily, getRectangleFontSize, getRectangleFontStyle, getRectangleHeight, getRectangleID, getRectangleLineCap, getRectangleLocked, getRectangleStrokeColor, getRectangleStrokeDashArray, getRectangleStrokeWidth, getRectangleText, getRectangleTheC, getRectangleTheT, getRectangleTheZ, getRectangleTransform, getRectangleVisible, getRectangleWidth, getRectangleX, getRectangleY, getRightsRightsHeld, getRightsRightsHolder, getROIAnnotationRef, getROIAnnotationRefCount, getROICount, getROIDescription, getROIID, getROIName, getROINamespace, getScreenAnnotationRef, getScreenAnnotationRefCount, getScreenCount, getScreenDescription, getScreenID, getScreenName, getScreenPlateRef, getScreenProtocolDescription, getScreenProtocolIdentifier, getScreenReagentSetDescription, getScreenReagentSetIdentifier, getScreenType, getShapeAnnotationRefCount, getShapeCount, getShapeType, getStageLabelName, getStageLabelX, getStageLabelY, getStageLabelZ, getTagAnnotationAnnotationCount, getTagAnnotationAnnotationRef, getTagAnnotationAnnotator, getTagAnnotationCount, getTagAnnotationDescription, getTagAnnotationID, getTagAnnotationNamespace, getTagAnnotationValue, getTermAnnotationAnnotationCount, getTermAnnotationAnnotationRef, getTermAnnotationAnnotator, getTermAnnotationCount, getTermAnnotationDescription, getTermAnnotationID, getTermAnnotationNamespace, getTermAnnotationValue, getTiffDataCount, getTiffDataFirstC, getTiffDataFirstT, getTiffDataFirstZ, getTiffDataIFD, getTiffDataPlaneCount, getTimestampAnnotationAnnotationCount, getTimestampAnnotationAnnotationRef, getTimestampAnnotationAnnotator, getTimestampAnnotationCount, getTimestampAnnotationDescription, getTimestampAnnotationID, getTimestampAnnotationNamespace, getTimestampAnnotationValue, getTransmittanceRangeCutIn, getTransmittanceRangeCutInTolerance, getTransmittanceRangeCutOut, getTransmittanceRangeCutOutTolerance, getTransmittanceRangeTransmittance, getUUID, getUUIDFileName, getUUIDValue, getWellAnnotationRef, getWellAnnotationRefCount, getWellColor, getWellColumn, getWellCount, getWellExternalDescription, getWellExternalIdentifier, getWellID, getWellReagentRef, getWellRow, getWellSampleCount, getWellSampleID, getWellSampleImageRef, getWellSampleIndex, getWellSamplePositionX, getWellSamplePositionY, getWellSampleRefCount, getWellSampleTimepoint, getWellType, getXMLAnnotationAnnotationCount, getXMLAnnotationAnnotationRef, getXMLAnnotationAnnotator, getXMLAnnotationCount, getXMLAnnotationDescription, getXMLAnnotationID, getXMLAnnotationNamespace, getXMLAnnotationValue';
Str=regexprep(Str,' ','');
Str=regexprep(Str,',',''';''');
Str=['{''',Str,'''};'];
Str=eval(Str);

OmeMetaData=table;
OmeMetaData.Tag=Str;

for m=1:size(OmeMetaData,1)
    clear Wave1;
    Path=['Wave1=OmeMetaDataRaw.',OmeMetaData.Tag{m,1},'(0);'];
    try
        eval(Path);
    end
    if exist('Wave1')~=1 || isempty(Wave1)
        OmeMetaData.Remove(m,1)=1;
        continue;
    end
    if strfind1(OmeMetaData.Tag{m,1},'getPixelsPhysicalSize')
        Wave1=Wave1.value(ome.units.UNITS.MICROM).doubleValue; % in µm
    end
    if strfind1(OmeMetaData.Tag{m,1},'getPixelsSize')
        Wave1=Wave1.getValue();
    end
    if isnumeric(Wave1)==0 && ischar(Wave1)==0
        try
            Wave1=char(Wave1);
        end
        if isempty(str2num(Wave1))==0
            Wave1=str2num(Wave1);
        end
    end
    OmeMetaData.Value(m,1)={Wave1};
end
OmeMetaData(OmeMetaData.Remove==1,:)=[];
OmeMetaData.Remove=[];
OmeMetaData.Properties.RowNames=OmeMetaData.Tag;
OmeMetaData.Tag=[];

Fileinfo=table;
GetSizeX=OmeMetaData.Value{'getPixelsSizeX'};
GetSizeY=OmeMetaData.Value{'getPixelsSizeY'};
GetSizeZ=OmeMetaData.Value{'getPixelsSizeZ'};
Fileinfo.Pix={[GetSizeX;GetSizeY;GetSizeZ]};

Res(1)=OmeMetaData.Value{'getPixelsPhysicalSizeX'};
Res(2,1)=OmeMetaData.Value{'getPixelsPhysicalSizeY'};
try; Res(3,1)=OmeMetaData.Value{'getPixelsPhysicalSizeZ'}; end; % try because might be 2D
Fileinfo.Res={Res};

Fileinfo.Um={Fileinfo.Res{1}.*Fileinfo.Pix{1}};


if strfind1({'.ids';'.lsm';'.czi'},Type,1)
    Fileinfo.UmStart{1}=-Fileinfo.Um{1}/2;
    Fileinfo.UmEnd{1}=+Fileinfo.Um{1}/2;
elseif strfind1({'.ims'},Type,1)
    UmStart(1,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMin0')};
    UmStart(2,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMin1')};
    UmStart(3,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMin2')};
    UmEnd(1,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMax0')};
    UmEnd(2,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMax1')};
    UmEnd(3,1)=OriginalMetaData.Value{strfind1(OriginalMetaData.Tag,'Global ExtMax2')};
    Fileinfo.UmStart(1)={UmStart};
    Fileinfo.UmEnd(1)={UmEnd};
else
    keyboard;
end

Fileinfo.GetSizeC=OmeMetaData.Value{'getPixelsSizeC'};
Fileinfo.GetSizeT=OmeMetaData.Value{'getPixelsSizeT'};
Fileinfo.GetType(1)=OmeMetaData.Value('getPixelsType');

if strfind1({'.ims'},Type,1)
    keyboard;
end

%% read out OriginalMetaData
if strfind1({'.ids','.ims'},Type,1)==0
    for m=1:Fileinfo.GetSizeC
        ChannelList(m,1)={getBFinfo_ChannelName(OriginalMetaData,Type,m)};
    end
    Fileinfo.ChannelList(1)={ChannelList};
end

if strfind1({'.lsm';'.czi'},Type,1)
    
    ChannelInfo=table;
    ChannelInfo.Name=ChannelList;
    for Ch=1:size(ChannelInfo,1)
        Track=str2num(ChannelInfo.Name{Ch}(end));
        if size(ChannelInfo,1)==1; Track=1;end;
        if size(ChannelInfo,1)==2&&Track==3; Track=2;end;
        ChannelInfo.Track{Ch}=Track;
        % Wavelength
        ChannelInfo.WaveLength(Ch,1)=getBFinfo_Wavelength(OriginalMetaData,Type,Ch,Track);
        % Transmission
        Wave1=getBFinfo_Transmission(OriginalMetaData,Type,Ch,FilenameTotal,Track);
        ChannelInfo.Transmission(Ch,1:size(Wave1,1))=Wave1.';
        % DetectionRange
        ChannelInfo.Detection(Ch,1:2)=getBFinfo_Detection(OriginalMetaData,Type,Ch);
        % MasterGain
        ChannelInfo.MasterGain(Ch,1)=getBFinfo_MasterGain(OriginalMetaData,Type,Ch);
        % DigitalGain
        ChannelInfo.DigitalGain(Ch,1)=getBFinfo_DigitalGain(OriginalMetaData,Type,Ch);
    end
    ZenInfo=struct;
    ZenInfo.ChannelInfo=ChannelInfo;
    
    ZenInfo.Zoom=getBFinfo_Zoom(OriginalMetaData,Type,Ch);
    ZenInfo.PixelDwell=getBFinfo_PixelDwell(OriginalMetaData,Type,Ch);
    try
        ZenInfo.TilePix=OriginalMetaData.Num(strfind1(OriginalMetaData.Tag,'Recording Lines Per Plane #1'));
        ZenInfo.TilePix(2,1)=OriginalMetaData.Num(strfind1(OriginalMetaData.Tag,'Recording Samples Per Line #1'));
        ZenInfo.TileNumber=[GetSizeX;GetSizeY]./ZenInfo.TilePix;
    end
else
    ZenInfo=[];
end