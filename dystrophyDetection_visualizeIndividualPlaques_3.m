% check function generateTimelineStacks_AllPlaquesPerTimepoint_2(Mouse,MouseInfo,PlaqueListSingle)
% previously: dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,Version,DataType,Selection)
function dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,Struct)

global W;
v2struct(Struct);
if exist('ImageGeneration','Var')~=1
    ImageGeneration='EachPlaque';
end
PlaqueListSingle=fuseTable_MatchingColums_4(PlaqueListSingle,MouseInfo,{'MouseId'},{'TreatmentType'});
% PlaqueListSingle(ismember(PlaqueListSingle.TreatmentType,{'NB360';'TauKD'}),:)=[];
PlaqueListSingle.TreatmentType(strcmp(PlaqueListSingle.TreatmentType,'NB360Vehicle'),1)={'Control'};

%% data selection
PlaqueListSingle=fuseTable_MatchingColums_4(PlaqueListSingle,SingleStacks,{'Filename'},{'DystrophyDetection'});
if exist('Selection','Var')~=1
    Selection='None';
end
PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'Microglia#2'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'Ubiquitin#2'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'IntensityCorrection#Done,NAB228,Ab126468|'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'IntensityCorrection#Done,NAB228,Ab126468|'),:);
% PlaqueListSingle(strfind1(PlaqueListSingle.Filename,'ExKatrinP_M381_Roi2_IhcMethoxy,VGLUT,NAB228,Ab12686_REGcortex_Date201907290950'),:)=[];
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'APPY188#'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'Bace1#'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'Microglia#'),:);
% PlaqueListSingle=PlaqueListSingle(strfind1(PlaqueListSingle.DystrophyDetection,'Lamp1#'),:);

% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrControl_IhcBace1_Ihd160416_M266_HemRight_Roi6';'ExHazal_TrControl_IhcBace1_Ihd160416_M259_HemRight_Roi9';'ExHazalS_IhcIba1_M266_PLQ5_HemRight_Roi10';'ExHazalS_IhcIba1_M266_PLQ5_HemLeft_Roi09';'ExHazal_IhcAPPY188_M341_Roi6';'ExHazal_TrVehicle_IhcBace1_Ihd160416_M341_HemLeft_Roi1'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrTauKO_IhcBace1_Ihd160703_M396_HemLeft_Roi4';'ExHazal_TrTauKO_IhcBace1_Ihd160703_M381_HemLeft_Roi4';'ExHazal_TrTauKO_IhcBace1_Ihd160703_M381_HemRight_Roi10'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrControl_IhcBace1_Ihd160416_M266_HemRight_Roi6'});
% % % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazalS_IhcLamp1_M353_PLQ8_HemLeft_Roi17';'ExHazal_TrTauKO_IhcBace1_Ihd170403_M429_HemRight_Roi9'});
% % % Wave1=strfind1(PlaqueListSingle.Filename,{'ExHazal_TrControl_IhcBace1_Ihd160416_M259_HemLeft_Roi1'});
% % % PlaqueListSingle=PlaqueListSingle(Wave1,:);

% define Filename and PlId
Selection=[]; % Selection='VisualizeIndividualPlaques';
if strcmp(Selection,'VisualizeIndividualPlaques')
    [Path2file,Report]=getPathRaw('VisualizeIndividualPlaques.xlsx');
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);
    SelectedFiles=xlsActxGet(Workbook,'Lamp1',1); % BACE1, Iba1, APPY188, Lamp1,VGLUt1,Ubiquitin
    for File=1:size(SelectedFiles,1)
        SelectedFiles.File(File,1)=find(~cellfun(@isempty,strfind(PlaqueListSingle.Filename,SelectedFiles.Filename{File})) & PlaqueListSingle.PlId==SelectedFiles.PlId(File));
    end
    PlaqueListSingle=PlaqueListSingle(SelectedFiles.File,:);
end

%% Image versions
ChannelInfo=table;
if find(Version==1)
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;40000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;30000]}}; % Iba1
    ChannelInfo(3,{'Channel','Colormap','ColorMinMax','ImageAdjustment'})={'DistInOut',{[1;1;1]},{[0;1]},'PlaqueBorder'};
end
if Version==2
    ChannelInfo(1,{'Channel','Colormap','ColorMinMax'})={'MetBlue',{[0;1;1]},{[0;30000]}};
    ChannelInfo(2,{'Channel','Colormap','ColorMinMax'})={DataType,{[1;0;1]},{[0;20000]}}; % Iba1: 30000
end
if Version==3 % BACE1 stainings for TauKO paper
    Wave1={'Version',3.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.2;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.2;'Channel','Bace1';'Colormap',[1;0;1];'IntensityMinMax',[0;8000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.3;'Channel','Bace1';'Colormap',[1;0;1];'IntensityMinMax',[0;8000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.4;'Channel','DistInOut';'Colormap',[1;1;1];'IntensityMinMax',[50;51];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.5;'Channel','MetBlue';'Colormap',[1,0.5,0;1,1,1];'IntensityMinMax','Norm100';'IntensityGamma',0.333;'ColorChannel','DistInOut';'ColorMinMax',[50;51];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.6;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.7;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',3.8;'Channel','Bace1';'Colormap',[1,1,1;1,0.5,0];'IntensityMinMax',[0;8000];'ColorChannel','Bace1Corona';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
  
    
end

% if find(Version==4) % InVivo: Vglut1 colorcoded
%      Wave1={'Version',4;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm99.5';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% end
% if find(Version==5) % InVivo: Vglut1
%     Wave1={'Version',5;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm99.5';'Res',[0.1;0.1;0.4]};
%     ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% end
if find(Version==5) % InVivo: VglutGreen
    Wave1={'Version',5.0;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.1) % InVivo: MetBlue
    Wave1={'Version',5.1;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.2) % VglutGreen&Methoxy
    Wave1={'Version',5.2;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.2;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.3) % InVivo: VglutGreen colorcoded
    Wave1={'Version',5.3;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.4) % InVivo: VglutGreen colorcoded and Methoxy
    Wave1={'Version',5.4;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.4;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Dystrophies2Radius';'ColorMinMax',[0;30];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.5) % InVivo: MetBlue
    Wave1={'Version',5.5;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100Center60';'IntensityGamma',0.5;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.6) % InVivo: Distance
    Wave1={'Version',5.6;'Channel','DistInOut';'D2D','D2DTrace';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==5.7) % ExVivo VglutGreen&Methoxy
    Wave1={'Version',5.7;'Channel','MetBlue';'D2D','D2DRatioB';'Colormap','Black2Blue2LightBlue';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',5.7;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     ChannelInfo.Res(:,1)={[0.1;0.1;0.4]};
end
if find(Version==7)
%     % ExVivo Vglut1&Methoxy
%     Wave1={'Version',7;'Channel','Vglut1';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).'; % previously Norm99
%     Wave1={'Version',7;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     % ExVivo Vglut1-Diameter&Methoxy
%     Wave1={'Version',7.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',7.1;'Channel','Vglut1';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Vglut1DystrophiesDiameter';'ColorMinMax',[0;60];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     % ExVivo Vglut1-Diameter
%     Wave1={'Version',7.2;'Channel','Vglut1';'Colormap','Spectrum1';'IntensityMinMax','Norm96';'ColorChannel','Vglut1DystrophiesDiameter';'ColorMinMax',[0;60];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     
%     Wave1={'Version',7.3;'Channel','Vglut1';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',7.4;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.33;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',7.5;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',7.6;'Channel','MetBlue';'Colormap',[1,0.5,0;1,1,1];'IntensityMinMax','Norm100';'IntensityGamma',0.333;'ColorChannel','DistInOut';'ColorMinMax',[50;51];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==8) % ExVivo APPY188&Methoxy
    Wave1={'Version',8;'Channel','APP';'Colormap',[1;0;1];'IntensityMinMax',[0;30000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',8;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==9) % ExVivo Methoxy
%     Wave1={'Version',9;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.9';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',9;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',9;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     ChannelInfo.Res(:,1)={[0.05;0.05;0.05]};
%     ImageFormat='.tif';
end
if find(Version==10) % DistanceBins of 5µm
%     Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBinsPlus1';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBinsMinus1';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',10;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==11) % ExVivo Vglut1-Diameter&Methoxy
    Wave1={'Version',11;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',11;'Channel','Iba1';'Colormap',[1;0;1];'IntensityMinMax','Norm99.5';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% % %     Wave1={'Version',11;'Channel','Iba1';'Colormap','WhiteOrMagenta';'IntensityMinMax','Norm96';'ColorChannel','Microglia';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==12) % Imaris
%     Wave1={'Version',12;'Channel','MetBlue';'D2D','D2DRatioB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'ChannelName','MetBlue';'Channel',{2};'D2D','D2DDeFinB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'ChannelName','MetRed';'Channel',{1};'D2D','D2DDeFinB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',12;'Channel','MetRed';'D2D','D2DRatioB'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','VglutGreen';'D2D','D2DRatioA'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','VglutRed';'D2D','D2DRatioA'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','Membership';'D2D','D2DTrace'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',12;'Channel','DistInOut';'D2D','D2DTrace'}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',5.0;'Channel','VglutGreen';'D2D','D2DRatioA';'Colormap',[0.5;1;0];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    ChannelInfo.Res(:,1)={[0.15;0.15;0.4]};
    ChannelInfo.SizeUm(:,1)={[350;350;60]};
end
if find(Version==13) % ExVivo NAB228
    Wave1={'Version',13;'Channel','NAB228';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==14) % ExVivo Vglut1-Diameter&Methoxy
%     Wave1={'Version',14.1;'Channel','Ab126468';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',14.2;'Channel','Ab22C11';'Colormap','Spectrum';'IntensityMinMax','Norm99.99';'ColorChannel','Ab22C11_Diameter';'ColorMinMax',[0;60];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',14.3;'Channel','Ab22C11';'Colormap',[1;0;1];'IntensityMinMax','Norm99.99';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end

if find(Version==15) % ExVivo Vglut1-Diameter&Methoxy
    Wave1={'Version',15;'Channel','RBB';'Colormap',[1;0;1];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',15;'Channel','MetBlue';'Colormap',[0;1;1];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if find(Version==16) % ExVivo Vglut1-Diameter&Methoxy
    Wave1={'Version',16;'Channel','Ab4G8';'Colormap',[1;0;1];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',16;'Channel','MetBlue';'Colormap',[0;1;1];'IntensityMinMax','Norm96';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end

if Version==17 % Iba1 stainings for TauKO paper
%     Wave1={'Version',17.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.1;'Channel','Iba1';'Colormap',[1;0;1];'IntensityMinMax','Norm99';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.1;'Channel','DistInOut';'Colormap',[0,0,0;0.5,0.5,0.5;0,0,0];'IntensityMinMax',[50;52];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    
%     Wave1={'Version',17.2;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.2;'Channel','Iba1';'Colormap',[1;0;1];'IntensityMinMax','Norm99';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.3;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.4;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.5;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',17.5;'Channel','Iba1';'Colormap',[1,1,1;1,0.5,0];'IntensityMinMax','Norm99';'IntensityGamma',0.333;'ColorChannel','Microglia';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',17.6;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if Version==18 % APPY188 stainings for TauKO paper
%     Wave1={'Version',18.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',18.1;'Channel','APPY188';'Colormap',[1;0;1];'IntensityMinMax',[0;8000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',18.1;'Channel','DistInOut';'Colormap',[0,0,0;1,1,1;0,0,0];'IntensityMinMax',[50;52];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';

    Wave1={'Version',18.2;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',18.2;'Channel','APPY188';'Colormap',[1;0;1];'IntensityMinMax',[0;3000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',18.3;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',18.4;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.5;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',18.5;'Channel','APPY188';'Colormap',[1,1,1;1,0.5,0];'IntensityMinMax','Norm99';'IntensityGamma',0.333;'ColorChannel','APPCorona';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    % [0;8000]
end
if Version==19 % Lamp1 stainings for TauKO paper
%     Wave1={'Version',19.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',19.1;'Channel','Lamp1';'Colormap',[1;0;1];'IntensityMinMax',[0;12000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',19.1;'Channel','DistInOut';'Colormap',[0,0,0;1,1,1;0,0,0];'IntensityMinMax',[50;52];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
% 
%     Wave1={'Version',19.2;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm100';'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',19.2;'Channel','Lamp1';'Colormap',[1;0;1];'IntensityMinMax',[0;10000];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',19.3;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',19.4;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.5;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',19.5;'Channel','Lamp1';'Colormap',[1,1,1;1,0.5,0];'IntensityMinMax','Norm99';'IntensityGamma',0.333;'ColorChannel','Lamp1Corona';'ColorMinMax',[0;1];'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',19.6;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.333;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end

if Version==20 % triple Abeta staining
    Wave1={'Version',20.0;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax',[0;10000];'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax',[0;10000];'IntensityGamma',0.33;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.2;'Channel','NAB228';'Colormap',[1;0;1];'IntensityMinMax',[0;3500];'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.3;'Channel','NAB228';'Colormap',[1;0;1];'IntensityMinMax',[0;3500];'IntensityGamma',0.33;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.4;'Channel','Ab126468';'Colormap',[1;0.5;0];'IntensityMinMax',[0;8000];'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.5;'Channel','Ab126468';'Colormap',[1;0.5;0];'IntensityMinMax',[0;8000];'IntensityGamma',0.33;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',20.6;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.2;0.2;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
if Version==21 % triple Abeta staining
    Wave1={'Version',21.1;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',21.2;'Channel','Ubiquitin';'Colormap',[1;0;1];'IntensityMinMax',[0;3000];'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',21.3;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',21.3;'Channel','Ubiquitin';'Colormap',[1;0;1];'IntensityMinMax',[0;3000];'IntensityGamma',1;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
%     Wave1={'Version',21.5;'Channel','DistInOut';'Colormap','Distance_5umBins';'IntensityMinMax',[0;255];'Res',[0.2;0.2;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',21.6;'Channel','Ubiquitin';'Colormap',[1,1,1;1,0.5,0];'IntensityMinMax','Norm99';'IntensityGamma',0.333;'ColorChannel','UbiquitinDystrophies';'ColorMinMax',[0;1];'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',21.7;'Channel','MetBlue';'Colormap','Black2Blue2White';'IntensityMinMax','Norm99.5';'IntensityGamma',0.333;'Res',[0.2;0.2;0.8]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end

if Version==22 % Iba1 stainings for Tanja
    Wave1={'Version',22.0;'Channel','NAB228';'Colormap','Black2Blue2White';'IntensityMinMax',[0;8000];'IntensityGamma',1;'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
    Wave1={'Version',22.0;'Channel','Iba1';'Colormap',[1;0;1];'IntensityMinMax','Norm99';'Res',[0.1;0.1;0.4]}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
end
%%
if exist('ImageFormat','Var')==0
    ImageFormat='.jpg';
end
if strfind1(ChannelInfo.Properties.VariableNames.','ChannelName',1)==0
    ChannelInfo.ChannelName=ChannelInfo.Channel;
else
    Wave1=find(isempty_2(ChannelInfo.ChannelName));
    ChannelInfo.ChannelName(Wave1,:)=ChannelInfo.Channel(Wave1);
end

Version=unique(ChannelInfo.Version);
if strfind1(PlaqueListSingle.Properties.VariableNames.','Time',1)==0
    PlaqueListSingle.Time(:,1)=1;
end

if strfind1(ChannelInfo.Properties.VariableNames.','SizeUm',1)==0
    ChannelInfo.SizeUm(:,1)={[100;100;0.4]};
end
if strfind1(ChannelInfo.Properties.VariableNames.','Res',1)==0
    ChannelInfo.Res(:,1)={[]};
end
MouseIds=unique(PlaqueListSingle.MouseId);
% MouseIds=384;
for Mouse=1:size(MouseIds,1)
    MouseId=MouseIds(Mouse);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & isempty_2(PlaqueListSingle.UmCenter)==0,:);
    if max(PlaqueListSingle2.Time)==1
        [~,~,PlaqueListSingle2.RoiId]=unique(PlaqueListSingle2.Filename);
    end
    RoiIds=unique(PlaqueListSingle2.RoiId);
    for Roi=1:size(RoiIds,1)
        RoiId=RoiIds(Roi);
        Timepoints=unique(PlaqueListSingle2.Time(PlaqueListSingle2.RoiId==floor(RoiId)));
        for Time=1:size(Timepoints,1)
% Time=2;
            TimeId=Timepoints(Time);
            PlaqueListSingle3=PlaqueListSingle2(find(PlaqueListSingle2.Time==TimeId & PlaqueListSingle2.RoiId==floor(RoiId)),:);
            % load the intensity data
            % in vivo
            if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                Filename=PlaqueListSingle3.Filename{1,2};
                if isempty(Filename); continue; end;
                [D2DDeFinB,D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax,FileinfoRatioA,FileinfoRatioB]=getRotationDrift_2(Filename,TimeId);
%                 [D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax,FileinfoRatioA,FileinfoRatioB]=getRotationDrift(flip(Filename),TimeId);
                if isempty(D2DDeFinAgreen);continue; end;
                Data3D=ChannelInfo(:,{'ChannelName';'Channel';'D2D';'Res'});
%                 Data3D=ChannelInfo(:,{'Channel';'D2D'});
                try; Data3D(end+1:end+size(ChannelInfo,1),Data3D.Properties.VariableNames)=ChannelInfo(:,{'ColorChannel';'D2D';'Res'}); end;
                Data3D(isempty_2(Data3D.ChannelName),:)=[];
                [~,Wave1]=unique(Data3D.ChannelName);
                Data3D=Data3D(Wave1,:);
                for m=1:size(Data3D,1)
                    Wave1=eval(Data3D.D2D{m});
                    Wave1.Tres=Data3D.Res{m};
                    Wave1=rmfield(Wave1,'Tpix');
                    Data3D.Data(m,1)={applyDrift2Data_4(Wave1,Data3D.ChannelName{m,1})};
                end
            else
                % ex vivo
                FilenameTotal=regexprep(PlaqueListSingle3.Filename{1},{'.lsm';'.czi'},{'.ims'});
                [~,Report]=getPathRaw(FilenameTotal);
                if Report==0; break; end;
                [Fileinfo]=getFileinfo_2(FilenameTotal);
                
%                 Fileinfo.Res{1};
%                 Pix=Fileinfo.Pix{1};
                if min(ismember(ChannelInfo.Channel,Fileinfo.ChannelList{1}))==0; continue; end;
                
                Data3D=ChannelInfo(:,{'ChannelName';'Res'});
%                 Data3D=ChannelInfo(:,{'Channel'});
                try; Data3D(end+1:end+size(ChannelInfo,1),Data3D.Properties.VariableNames)=ChannelInfo(:,{'ColorChannel';'Res'}); end;
                Data3D(isempty_2(Data3D.ChannelName),:)=[];
                [~,Wave1]=unique(Data3D.ChannelName);
                Data3D=Data3D(Wave1,:);
                for m=1:size(Data3D,1)
                    Wave1=im2Matlab_3(FilenameTotal,Data3D.ChannelName{m});
%                     [Wave1,Out]=interpolate3D(Wave1,Fileinfo.Res{1},Data3D.Res{m});
                    [Wave1,Out]=interpolate3D(Wave1,Fileinfo.Res{1},Data3D.Res{m});
                    Data3D.Data(m,1)={Wave1};
                end
            end
            
            for Pl=1:size(PlaqueListSingle3,1)
% Pl=2;
                PlId=PlaqueListSingle3.PlId(Pl);
                if strfind1(ChannelInfo.Properties.VariableNames.','D2D')~=0
                    PlXYZtrace=PlaqueListSingle3.UmCenter{Pl}; % Center in Trace file
                    [Wave1]=YofBinFnc(repmat(PlXYZtrace(3),[3,1]),FitCoefTrace2B(:,1),FitCoefTrace2B(:,2),FitCoefTrace2B(:,3));
                    PlXYZb=PlXYZtrace+Wave1; % Center in RatioB
                    [Wave1]=YofBinFnc(repmat(PlXYZb(3),[3,1]),FitCoefB2A(:,1),FitCoefB2A(:,2),FitCoefB2A(:,3));
                    PlXYZa=PlXYZb+Wave1; % Center in RatioA
                    
%                     PlXYZb=PlXYZb-FileinfoRatioB.UmStart{1}(:,1);
                    PlXYZa=PlXYZa-FileinfoRatioA.UmStart{1}(:,1);
                end
                for Ver=1:size(Version,1)
% Ver=3;
                    VerId=Version(Ver);
                    ChannelInfo2=ChannelInfo(find(ChannelInfo.Version==VerId),:);
                    for Ch=1:size(ChannelInfo2,1)
                        Ind=find(strcmp(ChannelInfo2.ChannelName{Ch,1},Data3D.ChannelName)); % Ind=find(strcmp(ChannelInfo2.Channel,Data3D.Channel)&strcmp(ChannelInfo2.D2D,Data3D.D2D));
                        Pix=size(Data3D.Data{Ind,1}).';
                        SizeUm=ChannelInfo2.SizeUm{Ch,1};
                        Res=ChannelInfo.Res{Ch,1};
                        if strfind1(ChannelInfo2.Properties.VariableNames.','D2D')==0
                            CenterPix=round(PlaqueListSingle3.PixCenter{Pl}.*Fileinfo.Res{1}./Res);
                        elseif strfind1(ChannelInfo2.Properties.VariableNames.',{'D2DRatioA';'D2DRatioB';'D2DTrace';'D2DDeFinB'})==0
                            CenterPix=round((PlXYZa./Res));
%                         elseif strcmp(ChannelInfo2.D2D{Ch},'D2DRatioA')
%                             CenterPix=round((PlXYZa./Res));
%                         elseif strcmp(ChannelInfo2.D2D{Ch},'D2DRatioB')
%                             CenterPix=round((PlXYZa./Res));
%                         elseif strcmp(ChannelInfo2.D2D{Ch},'D2DTrace')
%                             CenterPix=round((PlXYZa./Res));
%                         elseif strcmp(ChannelInfo2.D2D{Ch},'D2DDeFinB')
%                             CenterPix=round((PlXYZa./Res));
                        else
                            keyboard;
                        end
                        
                        SquarePix=round2odd(SizeUm./Res);
                        CenterPixPaste=(SquarePix+1)/2;
                        [Cut,Paste]=pixelOverhang(CenterPix,SquarePix,CenterPixPaste,Pix);
                        
                        Wave1=zeros(SquarePix.','uint16');
                        Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                        
                        if strfind1(ImageGeneration,'ImarisStack')
                            Data3D.Data(Ind)={Wave1};
                        else
                            ChannelInfo2.IntensityData{Ch,1}=max(Wave1,[],3);
                            if strfind1(ChannelInfo2.Properties.VariableNames.','ColorChannel')~=0 && isempty(ChannelInfo2.ColorChannel{Ch})==0
                                Ind=strfind1(Data3D.ChannelName,ChannelInfo2.ColorChannel{Ch,1},1);
                                Wave1=zeros(SquarePix.','uint16');
                                Wave1(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3D.Data{Ind}(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
                                ChannelInfo2.ColorData{Ch,1}=max(Wave1,[],3);
                            end
                        end
                    end
                    if strfind1(ImageGeneration,'ImarisStack')
                        FilenameTotal=['TimeLine','_M',num2str(MouseId),'_Version',num2str(VerId),'.ims'];
                        Res=Data3D.Res{1};
                        Pix=size(Data3D.Data{1}).';
                        [PathRaw,Report]=getPathRaw(FilenameTotal);
                        if Report==0
                            J=struct;J.PixMax=[Pix(1);Pix(2);Pix(3);0;2]; J.Resolution=Res; J.Path2file=W.PathImarisSample;
                            Application=openImaris_2(J); Application.SetVisible(1);
                            Application.FileSave(PathRaw,'writer="Imaris5"');
                            quitImaris(Application);
                            clear Application;
                        end
                        Wave1=Data3D.Data{strcmp(Data3D.ChannelName,'Membership'),1};
                        Wave2=Data3D.Data{strcmp(Data3D.ChannelName,'DistInOut'),1};
                        Wave1(Wave2>50)=0;
                        Data3D(end+1,{'ChannelName';'Data'})={{'PlaqueID'},Wave1};
                        Data3D(strfind1(Data3D.ChannelName,{'Membership';'DistInOut'}),:)=[];
                        for m=1:size(Data3D,1)
                            ex2Imaris_2(Data3D.Data{m,1},FilenameTotal,Data3D.ChannelName{m,1},Time);
% %                             imarisSaveHDFlock(FilenameTotal);
                        end
                    end
                    if strfind1(ImageGeneration,'EachPlaque')
                        FilenameTotal=[PlaqueListSingle3.TreatmentType{Pl,1},'_M',num2str(MouseId),'_Pl',num2str(PlId),'_Time',num2str(TimeId),'_',PlaqueListSingle3.Filename{Pl,1},'_Version',num2str(VerId)];
                        Path2file=[W.PathExp,'\Output\ImageGenerator\',TargetFolder,'\'];
                        if strfind1(ImageGeneration,'RadiusBin')
                            Wave1=str2num(ImageGeneration{1}(strfind(ImageGeneration{1},'RadiusBin')+9));
                            Wave2=ceil(PlaqueListSingle3.PlaqueRadius(Pl)/Wave1)*Wave1;
                            Path2file=[Path2file,num2str(Wave2),'um\'];
                        end
                        mkdir(Path2file);
                        Path2file=[Path2file,FilenameTotal,ImageFormat];
                        imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                    end
                    Wave1=find(PlaqueListSingle.MouseId==MouseId&strcmp(PlaqueListSingle.Filename,PlaqueListSingle3.Filename{Pl,1})&PlaqueListSingle.PlId==PlId&PlaqueListSingle.Time==TimeId);
                    PlaqueListSingle.ImageGenerator(Wave1,Ver)={ChannelInfo2};
                    
                end
            end
        end
        if strfind1(ImageGeneration,'PlaqueTimeLine') && strfind1(PlaqueListSingle.Properties.VariableNames.','ImageGenerator')
            for Pl=1:size(PlaqueListSingle3,1)
                PlId=PlaqueListSingle3.PlId(Pl);
                Wave1=find(PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.RoiId==RoiId&PlaqueListSingle.PlId==PlId&isempty_2(PlaqueListSingle.ImageGenerator(:,1))~=1);
                PlaqueListSingle4=PlaqueListSingle(Wave1,:);
                if size(PlaqueListSingle4,1)==0;break;end;
                for Ver=1:size(Version,1)
                    VerId=Version(Ver);
                    ChannelInfo2=PlaqueListSingle4.ImageGenerator{1,Ver};
                    for m=2:size(PlaqueListSingle4,1)
                        for n=1:size(ChannelInfo2,1)
                            ChannelInfo2.IntensityData(n,1)={[ChannelInfo2.IntensityData{n,1};PlaqueListSingle4.ImageGenerator{m,Ver}.IntensityData{n,1}]};
                            try; ChannelInfo2.ColorData(n,1)={[ChannelInfo2.ColorData{n,1};PlaqueListSingle4.ImageGenerator{m,Ver}.ColorData{n,1}]}; end;
                        end
                    end
                    FilenameTotal=['M',num2str(MouseId),'_Pl',num2str(Pl),'_',PlaqueListSingle3.Filename{Pl,1},'_Version',num2str(VerId)];
                    Path2file=[W.G.PathOut,'\ImageGenerator\',TargetFolder,'\PlaqueTimeLine\'];
                    mkdir(Path2file);
                    Path2file=[Path2file,FilenameTotal,ImageFormat];
                    imageGenerator_2(ChannelInfo2,Path2file,[],struct('Rotate',-90));
                end
            end
        end
    end
end
% keyboard;
% show all plaques sorted by size in each mouse printable as DinA4
ShowAllPlaqueDinA4=0;
if ShowAllPlaqueDinA4==1
    dystrophyDetection_visualizeIndividualPlaques_AllPlaqueDinA4(PlaqueListSingle,MouseIds,MouseInfo,TargetFolder,Version);
end