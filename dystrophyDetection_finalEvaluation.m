function dystrophyDetection_finalEvaluation()
global W;
W.XaxisType='Age'; %'TimeToTreatment'
DataSelection=table;

% Tanja Blume 2
DataSelection.DystrophyDetection={'Plaque#2|Microglia#2|ChannelNames#DAPI,Iba1,NAB228|'};


% Finn and Hazal
DataSelection.DystrophyDetection={'Plaque#'};

% Fanfan
DataSelection.DystrophyDetection={'Microglia#2|'};

% Yuan
DataSelection.DystrophyDetection={'Plaque#2|ChannelNames#MetBlue,Ab4G8|'};

% Tanja Blume
DataSelection.DystrophyDetection={'Plaque#2|ChannelNames#MetBlue,RBB|'};

% Katrin Pratsch
DataSelection.DystrophyDetection={'Plaque#2|PlaqueChannelName#Ab126468|'};

% Becky
DataSelection.DystrophyDetection={'Plaque#2|'};

% EvaRodriguez
DataSelection.DystrophyDetection={'Plaque#2|';'Bace1#2|'};

%%
[MouseInfo,SingleStacks]=dystrophyDetection_LoadData_3(DataSelection);
[PlaqueListSingle,DataArrays]=dystrophyDetection_GatherData_3(MouseInfo,SingleStacks);


%% Settings
% Tanja
TreatmentTypes=[]; %{'PLX';'Control'};
DataSelection={'Plaque#2|ChannelNames#MetBlue,NAB228'};

% Microglia for microglia depletion project
TreatmentTypes={'PLX';'Control'};
DataSelection={'Microglia#2'};


% SynucleinFibrils for FanFan
TreatmentTypes={'Plx';'Contr'};
DataSelection={'SynucleinFibrils#2'};


% Microglia for Pioglitazone project
TreatmentTypes={'Veh';'Pio'};
DataSelection={'Microglia#2'};
DataSelection={'Plaque#3'};

% SonjaB, EF1A spot analysis
% only "dystrophyDetection_LoadData" then directly "imarisSpot" (not "dystrophyDetection_GatherData_2")
TreatmentTypes={'ctrl';'syn'};
DataSelection={'ImarisSpot#2'};




% Methoxy-X04 profile for Finn and Hazal
TreatmentTypes={'Control';'NB360';'NB360Vehicle';'TauKO';'TauKD'};
DataSelection={'Plaque#1'};

% APP profile for Finn and Hazal
TreatmentTypes={'Control';'NB360';'NB360Vehicle';'TauKO';'TauKD'};
DataSelection={'APPY188#2'};

% Bace1 profile for Finn and Hazal
TreatmentTypes={'Control';'NB360';'NB360Vehicle';'TauKO';'TauKD'};
DataSelection={'Bace1#2'};

% Microglia for Gant project
TreatmentTypes={'Wt';'Gant'};
DataSelection={'Microglia#2';'Microglia#3'};

% BACE1 for DE9 project
TreatmentTypes={'NB360';'NB360Vehicle'};
DataSelection='Bace1#2';

% DataSelection='Lamp1#2';
% DataSelection={'Microglia#2';'Microglia#3'};




% [~,MouseInfo.Test]=ismember(MouseInfo.TreatmentType,TreatmentTypes);
% MouseInfo=sortrows(MouseInfo,'Test');
% MouseInfo(:,'Test')=[];


% SingleStacks=SingleStacks(strfind1(SingleStacks.DystrophyDetection,'Microglia#3'),:);
% OrigMouseInfo=MouseInfo;
% [Wave1]=ismember(unique(PlaqueListSingle.MouseId),MouseInfo.MouseId);
% MouseInfo=MouseInfo(Wave1,:);
%% Spotfire
SpotfireTable=DataArrays.Standard;
SpotfireTable.Properties.VariableNames{4} = 'PlId';
SpotfireTable=fuseTable_MatchingColums_4(SpotfireTable,PlaqueListSingle,{'Filename';'MouseId';'PlId'},{'PlaqueRadius';'BorderTouch'});

OutputFilename=[W.G.T.TaskName{W.Task},'_Spotfire.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);
writetable(SpotfireTable,PathExcelExport);
%% Calculations

processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Ab4G8',[4;10;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'RBB',[4;10;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Microglia',[4;8;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Bace1Corona',[2;4;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Lamp1Corona',[2;4;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'SynucleinFibrils');
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'APPCorona',[4;999]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'MetBlue',[4]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'NAB228',[4]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Ab126468',[4]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'UbiquitinDystrophies',[4]);
processTraceGroups_5(MouseInfo,PlaqueListSingle,DataArrays.Standard,'Ubiquitin',[4]);

vglutClusterAnalysis_4(PlaqueListSingle,MouseInfo,DataArrays.Vglut1DystrophiesDiameter,SingleStacks,'Vglut1DystrophiesDiameter');

Settings=struct('PlaqueRadiusBin',4,'Plot_PlaqueRadiusBin',4,'Plot_PercentMax',5,'Plot_ClusterSizeEdges',[(0:1:60).';999],'Plot_DistanceMinMax',[-20;51]);
[PlaqueListSingle]=vglutClusterAnalysis_4(PlaqueListSingle,MouseInfo,DataArrays.Ab22C11_Diameter,SingleStacks,'Ab22C11_Diameter',Settings);

dystrophyDetection_finalEvaluation_Plaque_3(MouseInfo,PlaqueListSingle,DataArrays.Standard);

dystrophyDetection_IntensityDistribution_2(MouseInfo,SingleStacks);
dystrophyDetection_ImarisSpot_2(MouseInfo,SingleStacks);

dystrophyDetection_finalMicroglia(MouseInfo,SingleStacks);
dystrophyDetection_finalBoutons(MouseInfo,SingleStacks);


dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,3,'Bace1');
dystrophyDetection_visualizeIndividualPlaques_2(MouseInfo,PlaqueListSingle,2,'Iba1');
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[7;7.1],'ImageGeneration',{{'EachPlaque_RadiusBin2'}},'TargetFolder','VGLUT8')); % Vglut1
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[8],'ImageGeneration',{{'EachPlaque_RadiusBin2'}},'TargetFolder','APP')); % APPY188
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[9],'ImageGeneration',{{'EachPlaque_RadiusBin2'}},'TargetFolder','MethoxyX04')); % MethoxyX04
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[10],'TargetFolder','Distance4')); % DistanceRings
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[11],'ImageGeneration',{{'EachPlaque_RadiusBin4'}},'TargetFolder','Microglia'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[9],'ImageGeneration',{{'EachPlaque_RadiusBin4'}},'TargetFolder','Becky_MethoxyX04_2'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[15],'ImageGeneration',{{'EachPlaque_RadiusBin4'}},'TargetFolder','Tanja_RBBvsMethoxy'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[16],'ImageGeneration',{{'EachPlaque_RadiusBin4'}},'TargetFolder','Yuan_4G8vsMethoxy'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[14],'ImageGeneration',{{'EachPlaque_RadiusBin4'}},'TargetFolder','Katrin_Ab22C11'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[3],'TargetFolder','TauKO_BACE1'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[3],'TargetFolder','Test'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[17],'TargetFolder','Test2'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[18],'TargetFolder','TauKO_APP'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[19],'TargetFolder','TauKO_Lamp1'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[17],'TargetFolder','TauKO_Iba1'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[20],'TargetFolder','TauKO_Abeta'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[21],'TargetFolder','TauKO_Ubiquitin'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[7],'TargetFolder','TauKO_VGLUT1'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[20],'TargetFolder','PlaqueCompactness'));
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,SingleStacks,struct('Version',[22],'TargetFolder','Tanja_Iba1'));