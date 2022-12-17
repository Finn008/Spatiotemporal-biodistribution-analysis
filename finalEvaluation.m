function finalEvaluation()
% global W;

%% recalculate all the data
[MouseInfo,SingleStacks]=finalEvaluation_LoadData_2(); % 11min
PlaqueListSingle=table;

[PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification_3(MouseInfo,PlaqueListSingle); % 66 min
[PlaqueArray1,VglutArray1,VglutArray2,BoutonList2,PlaqueHistograms,SingleStacks]=finalEvaluation_GatherData_4(MouseInfo,SingleStacks,PlaqueListSingle);

save(getPathRaw('FinalEvaluation_MouseInfo.mat'),'MouseInfo');
save(getPathRaw('FinalEvaluation_PlaqueListSingle.mat'),'PlaqueListSingle');
save(getPathRaw('FinalEvaluation_PlaqueList.mat'),'PlaqueList');

save(getPathRaw('FinalEvaluation_PlaqueArray1.mat'),'PlaqueArray1');
save(getPathRaw('FinalEvaluation_VglutArray1.mat'),'VglutArray1');
save(getPathRaw('FinalEvaluation_VglutArray2.mat'),'VglutArray2');
save(getPathRaw('FinalEvaluation_BoutonList2.mat'),'BoutonList2','-v7.3');
save(getPathRaw('FinalEvaluation_PlaqueHistograms.mat'),'PlaqueHistograms');
save(getPathRaw('FinalEvaluation_SingleStacks.mat'),'SingleStacks','-v7.3');

%% start with already saved data for BACE1 inhibition project
FolderPath='\\Gnp42n\marvin\Finn\data\X0103 presentations\X0209 Paper1\Backup';
load([FolderPath,'\FinalEvaluation_MouseInfo.mat'],'MouseInfo');
load([FolderPath,'\FinalEvaluation_PlaqueListSingle.mat'],'PlaqueListSingle');
load([FolderPath,'\FinalEvaluation_PlaqueList.mat'],'PlaqueList');
load([FolderPath,'\FinalEvaluation_PlaqueArray1.mat'],'PlaqueArray1');
load([FolderPath,'\FinalEvaluation_VglutArray1.mat'],'VglutArray1');
load([FolderPath,'\FinalEvaluation_VglutArray2.mat'],'VglutArray2');
load([FolderPath,'\FinalEvaluation_BoutonList2.mat'],'BoutonList2');
load([FolderPath,'\FinalEvaluation_VglutArray3.mat'],'VglutArray3');
load([FolderPath,'\FinalEvaluation_PlaqueHistograms.mat'],'PlaqueHistograms');
load([FolderPath,'\FinalEvaluation_SingleStacks.mat'],'SingleStacks');

%% TauKO
load(getPathRaw('FinalEvaluation_MouseInfo.mat'),'MouseInfo');
load(getPathRaw('FinalEvaluation_PlaqueListSingle.mat'),'PlaqueListSingle');
load(getPathRaw('FinalEvaluation_PlaqueList.mat'),'PlaqueList');
load(getPathRaw('FinalEvaluation_PlaqueArray1.mat'),'PlaqueArray1');
load(getPathRaw('FinalEvaluation_VglutArray1.mat'),'VglutArray1');
load(getPathRaw('FinalEvaluation_VglutArray2.mat'),'VglutArray2');
load(getPathRaw('FinalEvaluation_BoutonList2.mat'),'BoutonList2');
load(getPathRaw('FinalEvaluation_VglutArray3.mat'),'VglutArray3');
load(getPathRaw('FinalEvaluation_PlaqueHistograms.mat'),'PlaqueHistograms');
load(getPathRaw('FinalEvaluation_SingleStacks.mat'),'SingleStacks');


%% finalEvaluation_DataAdjustment();
% gather data on MouseInfoTime
MouseInfoTime=accumarray_9(PlaqueListSingle(:,{'MouseId';'Time2Treatment';'Age'}),[],@sum);
MouseInfoTime(:,'Count')=[];
[MouseInfoTime]=sortrows_2(MouseInfoTime);
% determine total volume for each timepoint in each mouse
Wave1=accumarray_9(PlaqueHistograms(:,{'MouseId';'Time2Treatment'}),PlaqueHistograms(:,'VolumeRealUm3'),@sum);
MouseInfoTime=fuseTable_MatchingColums(MouseInfoTime,Wave1,{'MouseId';'Time2Treatment'});
MouseInfoTime.Properties.VariableNames{end}='TotalVolume';

% check which plaques have VglutGreenInformation
Wave1=accumarray_9(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),VglutArray1(:,{'Distance'}),@min);
Wave1.Properties.VariableNames{1}='MinimalVglutDistance';
PlaqueListSingle.MinimalVglutDistance(:,1)=NaN;
PlaqueListSingle=fuseTable_MatchingColums_2(PlaqueListSingle,Wave1,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'MinimalVglutDistance'});

% calculate smallest available distance in PlaqueArray1 for each plaque
Wave1=accumarray_9(PlaqueArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),PlaqueArray1(:,{'Distance'}),@min);
Wave1.Properties.VariableNames{1}='MinimalMethoxyDistance';
PlaqueListSingle.MinimalMethoxyDistance(:,1)=NaN;
PlaqueListSingle=fuseTable_MatchingColums_2(PlaqueListSingle,Wave1,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'MinimalMethoxyDistance'});

Wave1=PlaqueListSingle(PlaqueListSingle.MinimalVglutDistance<0,:);
Wave1=accumarray_9(Wave1(:,{'MouseId';'RoiId';'PlId'}),[],@sum);
Wave1.Properties.VariableNames{1}='AvailableVglutData';
PlaqueList=fuseTable_MatchingColums_2(PlaqueList,Wave1,{'MouseId';'RoiId';'PlId'},{'AvailableVglutData'});

Wave1=accumarray_9(Wave1(:,{'MouseId'}),[],@sum);
Wave1.Properties.VariableNames{1}='AvailableVglutData';
MouseInfo=fuseTable_MatchingColums_2(MouseInfo,Wave1,{'MouseId'},{'AvailableVglutData'});

Wave1=PlaqueHistograms(PlaqueHistograms.VolumeRealUm3~=0,:);
Wave2=accumarray_9(Wave1(:,{'MouseId'}),Wave1(:,'Distance'),@min);
Wave2=fuseTable_MatchingColums_2(MouseInfo,Wave2,{'MouseId'},{'Distance'});
MouseInfo.RealDistanceMinMax=Wave2.Distance-50;
Wave2=accumarray_9(Wave1(:,{'MouseId'}),Wave1(:,'Distance'),@max);
Wave2=fuseTable_MatchingColums_2(MouseInfo,Wave2,{'MouseId'},{'Distance'});
MouseInfo.RealDistanceMinMax(:,2)=Wave2.Distance-50;

% % % global XaxisType='Age';

% [PlaqueHistograms,VglutArray1,VglutArray2,BoutonList2,PlaqueListSingle,PlaqueArray1]=redistributeTime2Treatment_3(MouseInfo,BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueList,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2);
[BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2]=redistributeTime2Treatment_4(MouseInfo,BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2);
for Mouse=1:size(MouseInfo,1)
    Wave1=MouseInfoTime.TotalVolume(MouseInfoTime.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.VolumeMinMeanMax(Mouse,1:3)=[min(Wave1),mean(Wave1),max(Wave1)];
end
MouseId=279; Mouse=find(MouseInfo.MouseId==279);
MouseInfo.TotalVolume(Mouse,1)=min(MouseInfoTime.TotalVolume(MouseInfoTime.MouseId==MouseId));
PlaqueHistograms.Distance=PlaqueHistograms.Distance-50;
%% specific calculations
W.XaxisType='Age'; %'TimeToTreatment'
[NewBornPlaqueList]=finalEvaluation_PlaqueDensity_6(MouseInfo,PlaqueListSingle,PlaqueList,MouseInfoTime,PlaqueHistograms,[7]);
keyboard;
finalEvaluation_RecalculateDistance_2(MouseInfo(MouseInfo.RealDistanceMinMax(:,1)==-49,:),MouseInfoTime,PlaqueListSingle,NewBornPlaqueList); % calculate real distance at every timepoint such that ghost plaques are excluded


finalEvaluation_RadiusDistribution_2(MouseInfo,PlaqueListSingle,MouseInfoTime);

finalEvaluation_ShowImagingTimepoints(MouseInfo);

vglutClusterAnalysis_3(PlaqueListSingle,VglutArray1,VglutArray2,PlaqueArray1,BoutonList2,MouseInfo);

autofluorescenceAnalysis(PlaqueListSingle,PlaqueArray1,MouseInfo);


finalEvaluation_UpdatePipeline(SingleStacks);

satellitePlaqueImage_2(MouseInfo,NewBornPlaqueList,PlaqueList,PlaqueListSingle);

finalEvaluation_PlaqueGrowth_2(MouseInfo,PlaqueListSingle);
% [MouseInfoTime,PlaqueListSingle,MouseInfo]=finalEvaluation_PathologyPercentage_2(MouseInfo,PlaqueListSingle,BinTableBoutons1,BinTableDystrophies1);
finalEvaluation_VisualizePlaqueBurden(MouseInfo,PlaqueArray1);
% finalEvaluation_VisualizePathologyPercentage(MouseInfo,MouseInfoTime);

finalEvaluation_VolumeDistribution_3(MouseInfo,PlaqueHistograms);
% generateTimelineStacks(MouseInfo,PlaqueListSingle)
generateTimeLineDataSets(MouseInfo,PlaqueListSingle);
dystrophyDetection_visualizeIndividualPlaques_3(MouseInfo,PlaqueListSingle,struct('Version',[5.2],'ImageGeneration',{{'EachPlaque';'PlaqueTimeLine'}},'TargetFolder','InVivo4'));

