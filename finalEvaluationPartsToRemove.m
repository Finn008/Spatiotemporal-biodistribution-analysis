function finalEvaluationPartsToRemove()






return;
% vglutBoutonAnalysis(PlaqueListSingle,VglutArray1,BoutonList2,PlaqueArray1,MouseInfo,'TotalBoutonDensity');

% vglutClusterAnalysis_TwoBins(PlaqueListSingle,VglutArray1,VglutArray2,PlaqueArray1,MouseInfo);


Wave1=accumarray_8(PlaqueArray1(:,{'MouseId';'RoiId';'PlId';'Time'}),[],@sum);
PlaqueListSingle=fuseTable_MatchingColums(PlaqueListSingle,Wave1,{'MouseId';'RoiId';'PlId';'Time'});


% % % PlaqueListSingle(:,'Volume')=[];
PlaqueListSingle=finalEvaluation_Distance4PlaqueListSingle(PlaqueListSingle,PlaqueArray1,'VolumeUm3',[1;2;3;4;5],[50;255]);



% % % [SingleStacks]=finalEvaluation_IntegrateSurfaceSpotInfo_2(SingleStacks,DataAssignment); % 16min
% [PlaqueListSingle]=finalEvaluation_GatherData_3(MouseInfo,SingleStacks,PlaqueListSingle,DataAssignment); % 25min
keyboard;
[BinTableBoutons1]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'Boutons1',[999],[999]);
[BinTableDystrophies1]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'Dystrophies1',[5],[7]);
[BinTableMetBlue]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'MetBlue',[5],[7]);



keyboard;
% % % [MouseInfoTime,MouseInfo]=finalEvaluation_PlaqueDensity(MouseInfo,PlaqueList,MouseInfoTime); % [MouseInfoTime,MouseInfo]=finalEvaluation_BabyPlaques(MouseInfo,PlaqueList,MouseInfoTime);
% [MouseInfoTime,MouseInfo]=finalEvaluation_PlaqueDensity_2(MouseInfo,PlaqueList,MouseInfoTime,PlaqueListSingle);


[MouseInfoTime]=finalEvaluation_RecalculateDistance_2(MouseInfo(1:18,:),MouseInfoTime,PlaqueListSingle,NewBornPlaqueList);
% [MouseInfoTime]=finalEvaluation_VolumeDistribution(MouseInfo,MouseInfoTime,PlaqueListSingle);



keyboard;
finalEvaluation_MouseWeight();

% [PlaqueListSingle]=finalEvaluation_Dystrophies1Quantification_5(MouseInfo,PlaqueListSingle); % 3min
% [PlaqueListSingle]=finalEvaluation_Boutons1Quantification_2(MouseInfo,PlaqueListSingle);

% DataAssignment=table;
% DataAssignment({'Volume1b'},{'SubPools','FileType'})={{{[1;2;3;4;5]}},1};
% DataAssignment({'Volume2b'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Volume1a'},{'SubPools','FileType'})={{{[1;2;3;4;5]}},2};
% % % DataAssignment({'Dystrophies1'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'DystrophiesPl'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Autofluo1'},{'SubPools','FileType'})={{{[1;2]}},1};
% % % DataAssignment({'VglutGreen'},{'SubPools','FileType'})={{{[2]}},2};
% DataAssignment({'MetBlue'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Boutons1'},{'SubPools','FileType'})={{{[1;2]}},2};
% DataAssignment.Name=DataAssignment.Properties.RowNames;
% % % quadrants =1; lateral to plaque =2; above plaque =3; below plaque =4; Blood =5; Outside =6;








keyboard;


% [MouseInfo]=finalEvaluationPoolRois(MouseInfo);
% [MouseInfoTime,MouseInfo]=finalEvaluation_PlaquesQuantificationGlobal_2(MouseInfo,PlaqueList,PlaqueListSingle,MouseInfoTime,PathExcelExport);


PlaqueList=PlaqueList(:,{'MouseId','RoiId','Pl','TreatmentType','StartTreatmentNum','PlBirth','PlaqueSizeFit'});


[SingleStacks]=finalEvaluation_PoolSubRegions(SingleStacks); %10min











TreatmentGroups=finalEvaluation_PoolTreatmentTypes(MouseInfoTime,MouseInfo);


finalEvaluation_ShowPlaqueGrowth(PlaqueList);

% % % [SingleStacks]=finalEvaluation_RemoveParameters(SingleStacks); % 15min

% [SingleStacks]=finalEvaluation_IntegrateSurfaceSpotInfo(SingleStacks); % 8min
% % % % [MouseInfo,PlaqueListBoutons1]=finalEvaluation_Boutons1Global(SingleStacks,MouseInfo);

% fuse defined SubRegions




% calculate density NormTotal etc.

% get corresponding data from different timepoints into one table for each plaque
% % % [TimeDistTable]=finalEvaluation_GatherData(MouseInfo,SingleStacks); % 105min
% [MouseInfo]=finalEvaluation_Quantification2(MouseInfo); % trace fits to temporal progression of different Mods

% OrigMouseInfo=MouseInfo;

% [PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification(MouseInfo); % 9min

% % % [SingleStacks]=finalEvaluation_DensityCalc(SingleStacks); % 10min





keyboard;









[MouseInfo]=finalEvaluation_Boutons1GlobalDensity(SingleStacks,MouseInfo);

[MouseInfo,PlaqueListAutofluo1]=finalEvaluation_Autofluo1Quantification(TimeDistTable,MouseInfo);


[MouseInfo,PlaqueListMetBlue]=finalEvaluation_MetBlueQuantification(TimeDistTable,MouseInfo);
[MouseInfo,PlaqueListMetRed]=finalEvaluation_MetRedQuantification(TimeDistTable,MouseInfo);



% % finalEvaluation_Autofluo1Quantification(MouseInfo);

% make smoothing calculations
[TimeDistTable]=finalEvaluation_Smoothing(TimeDistTable,MouseInfo);


%% export images and movies
finalEvaluation_Visualize(MouseInfo,TimeDistTable);







% include TotalResults
[PlaqueData]=finalEvaluationSub8(PlaqueData,SibInfo);
% calculate dystrophy extension for each plaque
[PlaqueData]=finalEvaluationSub7(PlaqueData);






%% extract surfaces/spots regardless of Membership of all timepoints into single table
[SurfaceData]=finalEvaluationSub2(FileTypes,NameTable);



%% finish data setting
%     TotalResults=struct;
%     Co.Xaxis=Xaxis;
TotalResults.VariableNames=VariableNames;
TotalResults.FA=FA;
TotalResults.PlaqueData=PlaqueData;
TotalResults.SuperficialAutofluoMargin=SuperficialAutofluoMargin;

save(PathTotalResults,'TotalResults');



%% make scatter plot for Autofluo distance versus size
J=struct;
J.Tit='Autofluorescence distance versus density';
J.X=SurfaceData.AutofluoSurface.Distance;
J.Y=SurfaceData.AutofluoSurface.Volume;
J.Sp={'w.'};
J.Xlab='Distance [µm]';
J.Ylab='Volume [µm^3]';
J.Layout='black';
J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',AutofluoDistanceDensity.emf'];
movieBuilder_4(J);


%% make image for depth distribution of autofluorescent particles
J=struct;
J.Tit='Autofluorescence depth distribution';
J.X=AutofluoDepthDistribution.Depth;
J.Y=[AutofluoDepthDistribution{:,2:6}*100];
J.Sp={'r.';'c.';'y-';'w-';'g-'};
J.Xlab='Depth [µm]';
J.Ylab='Volume [µm^3]';
J.Layout='black';
J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',AutofluoDepthDistribution.emf'];
movieBuilder_4(J);



%% make movie for each plaque
for m=1:size(PlaqueData,1)
    J=struct;
    J.Tit=strcat({'Timepoint: '},num2strArray((1:21).'));
    J.Frequency=2;
    J.X=(-50:205).';
    J.OrigYaxis=[   {PlaqueData.Vector{m,1}.Plaque{1}{:,:}./PlaqueData.Vector{m,1}.Volume{1}{:,:}},{'w.'};...
        ];
    J.OrigType=3;
    J.Xlab='Distance [µm]';
    J.Ylab='Intensity [a.u.]';
    J.Xrange=[-10;150];
    J.Layout='black';
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',Plaque',num2str(m),',Plaque.avi'];
    movieBuilder_4(J);
end



% LargeBoutons density for each plaque
for m=1:size(PlaqueData,1)
    Timepoints=2;
    J=struct;
    J.Tit=strcat({'Timepoint: '},num2strArray((1:Timepoints).'));
    J.Frequency=2;
    J.X=(-50:205).';
    J.OrigYaxis=[   {PlaqueData.Vector{m,2}.BoutonsLarge{1}{:,1:Timepoints}./PlaqueData.Vector{m,2}.Volume{1}{:,1:Timepoints}},{'w.'};...
        ];
    J.OrigType=3;
    J.Xlab='Distance [µm]';
    J.Ylab='Bouton density [/µm^3]';
    J.Xrange=[-10;150];
    %         J.Yrange=[0;0.05];
    J.Layout='black';
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',Plaque',num2str(m),',BoutonsLarge.avi'];
    movieBuilder_4(J);
end


















return;


% [TraceFileinfo]=getFileinfo_2(NameTable{'Trace','FilenameTotal'});
% PathTotalResults=[SibInfo.FamilyName,'_RatioResults.mat'];
% [PathTotalResults,Report]=getPathRaw(PathTotalResults);
% if Report==1
%     %         keyboard;
%     TotalResults=load(PathTotalResults);
%     TotalResults=TotalResults.TotalResults;
%     %         v2struct(TotalResults);
% else
%     TotalResults=struct;
%     FA=table;
% end

%% calculate nearby Autofluo and empty corona as well as normal level far from Plaque
for m=1:PlaqueNumber
    Modalities=table; % Timepoints in X, Plaques in Y
    % ProximalAutofluo : <10
    % EmptyCorona : 10 to 30
    % DistalAutofluo : >30
    Wave1=PlaqueData.Info3D{m,1}(:,VariableNames.AutofluoSurface,:);
    Wave1=permute(Wave1,[1,3,2]);
    Modalities.ProximalAutofluoVolume=nansum(Wave1(1:60,:),1).';
    
    Volume=PlaqueData.Info3D{m,1}(:,VariableNames.Volume,:);
    Volume=permute(Volume,[1,3,2]);
    Modalities.ProximalAutofluoDensity=Modalities.ProximalAutofluoVolume./nansum(Volume(1:60,:),1).';
    Modalities.MedialAutofluoDensity=Modalities.ProximalAutofluoVolume./nansum(Volume(60:80,:),1).';
    Modalities.DistalAutofluoDensity=nansum(Wave1(80:end,:),1).'./nansum(Volume(80:end,:),1).';
    
    PlaqueData.Modalities(m,1)={Modalities};
    
    
end


%% gather info on Surfaces and Spots objects
for m2=1:size(FileTypes,1)
    Timepoints=max(FileTypes.FA{m2,1}.Timepoint);
    
    for m=1:size(FileTypes.FA{m2,1},1)
        VariableNames=varName2Col(FileTypes.FA{m2,1}.RatioResults{m,1}.Statistics.AutofluoSurface.ChannelNames);
        Statistics=FileTypes.FA{m2,1}.RatioResults{m,1}.Statistics.AutofluoSurface.ObjInfo;
        
        A1=struct2table(Statistics);
        
        AutofluoStatistics=table;
        AutofluoStatistics.Volume=Statistics.Volume;
        AutofluoStatistics.DistancetoImageBorderXYZ=Statistics.DistancetoImageBorderXYZ;
        AutofluoStatistics.CenterofHomogeneousMassXYZ=[Statistics.CenterofHomogeneousMassX,Statistics.CenterofHomogeneousMassY,Statistics.CenterofHomogeneousMassZ];
        AutofluoStatistics.IntensityMean=Statistics.IntensityMean;
        AutofluoStatistics.Sphericity=Statistics.Sphericity;
        % depth
        keyboard; % update MultiDimInfo retrieval
        TumMinMax=FileTypes.FA{m2,1}.MultiDimInfo{m,1}.TumMinMax;
        Wave1=TumMinMax(3,1)-FileTypes.FA{m2,1}.Fileinfo{m,1}.UmStart{1}(3,1);
        AutofluoStatistics.Depth=AutofluoStatistics.CenterofHomogeneousMassXYZ(:,3)+Wave1;
        % Membership
        AutofluoStatistics.Membership=round(AutofluoStatistics.IntensityMean(:,VariableNames.Membership));
        % Distance to next plaque
        AutofluoStatistics.Distance2Plaque=AutofluoStatistics.IntensityMean(:,VariableNames.DistInOut);
        FileTypes.FA{m2,1}.AutofluoStatistics(m,1)={AutofluoStatistics};
    end
    
    
end

%% define SuperficialAutofluoMargin
AllAutofluo=FA.AutofluoStatistics{1,1};
for m=2:size(FA,1)
global W;

[MouseInfo,SingleStacks]=finalEvaluation_LoadData_2(); % 11min

load(getPathRaw('FinalEvaluation_PlaqueListSingle.mat'),'PlaqueListSingle');
load(getPathRaw('FinalEvaluation_PlaqueList.mat'),'PlaqueList');
load(getPathRaw('FinalEvaluation_PlaqueArray1.mat'),'PlaqueArray1');
load(getPathRaw('FinalEvaluation_PlaqueHistograms.mat'),'PlaqueHistograms');
load(getPathRaw('FinalEvaluation_VglutArray1.mat'),'VglutArray1');
load(getPathRaw('FinalEvaluation_VglutArray2.mat'),'VglutArray2');
load(getPathRaw('FinalEvaluation_VglutArray3.mat'),'VglutArray3');
load(getPathRaw('FinalEvaluation_BoutonList2.mat'),'BoutonList2');



PlaqueListSingle=table;
CaseOutliars=finalEvaluation_CaseOutliars(MouseInfo);
[PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification_3(MouseInfo,CaseOutliars,PlaqueListSingle,1); % 45 min

[PlaqueArray1,VglutArray1,VglutArray2,VglutArray3,BoutonList2,PlaqueHistograms,SingleStacks]=finalEvaluation_GatherData_4(MouseInfo,SingleStacks,PlaqueListSingle);
SingleStacks(:,'BoutonList2') = [];
% clear SingleStacks;

%% gather data on MouseInfoTime
MouseInfoTime=accumarray_8(PlaqueArray1(:,{'MouseId';'Time2Treatment'}),[],@sum);
MouseInfoTime(:,'Count')=[];
[MouseInfoTime]=sortrows_2(MouseInfoTime);
% calculate total volume
Wave1=accumarray_8(PlaqueHistograms(:,{'MouseId';'Time'}),PlaqueHistograms(:,'VolumeRealUm3'),@sum);
MouseInfoTime=fuseTable_MatchingColums(MouseInfoTime,Wave1,{'MouseId';'Time'});


[NewBornPlaqueList]=finalEvaluation_PlaqueDensity_4(MouseInfo,PlaqueListSingle,PlaqueList,MouseInfoTime,PlaqueHistograms,[30.42;14;7]);
finalEvaluation_RadiusDistribution(MouseInfo,PlaqueListSingle,MouseInfoTime,[2],[14;7]);


vglutClusterAnalysis(PlaqueListSingle,VglutArray1,VglutArray2,MouseInfo);


% Wave1=accumarray_4(PlaqueArray1(:,{'MouseId';'RoiId';'PlId';'Time'}),[],@sum);
% PlaqueListSingle=fuseTable_MatchingColums(PlaqueListSingle,Wave1,{'MouseId';'RoiId';'PlId';'Time'});




% % % PlaqueListSingle(:,'Volume')=[];
% PlaqueListSingle=finalEvaluation_Distance4PlaqueListSingle(PlaqueListSingle,PlaqueArray1,'VolumeUm3',[1;2;3;4;5],[50;255]);



% % % [SingleStacks]=finalEvaluation_IntegrateSurfaceSpotInfo_2(SingleStacks,DataAssignment); % 16min
% [PlaqueListSingle]=finalEvaluation_GatherData_3(MouseInfo,SingleStacks,PlaqueListSingle,DataAssignment); % 25min
keyboard;
[BinTableBoutons1]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'Boutons1',[999],[999]);
[BinTableDystrophies1]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'Dystrophies1',[5],[7]);
[BinTableMetBlue]=processTraceGroups_2(MouseInfo(1:18,:),PlaqueListSingle,'MetBlue',[5],[7]);
[MouseInfoTime,PlaqueListSingle,MouseInfo]=finalEvaluation_PathologyPercentage_2(MouseInfo,PlaqueListSingle,BinTableBoutons1,BinTableDystrophies1);
finalEvaluation_VisualizePathologyPercentage(MouseInfo,MouseInfoTime);

keyboard;
% % % [MouseInfoTime,MouseInfo]=finalEvaluation_PlaqueDensity(MouseInfo,PlaqueList,MouseInfoTime); % [MouseInfoTime,MouseInfo]=finalEvaluation_BabyPlaques(MouseInfo,PlaqueList,MouseInfoTime);
% [MouseInfoTime,MouseInfo]=finalEvaluation_PlaqueDensity_2(MouseInfo,PlaqueList,MouseInfoTime,PlaqueListSingle);
finalEvaluation_PlaqueGrowth_2(MouseInfo,PlaqueListSingle);

[MouseInfoTime]=finalEvaluation_RecalculateDistance_2(MouseInfo(1:18,:),MouseInfoTime,PlaqueListSingle,NewBornPlaqueList);
% [MouseInfoTime]=finalEvaluation_VolumeDistribution(MouseInfo,MouseInfoTime,PlaqueListSingle);
finalEvaluation_VolumeDistribution_2(MouseInfo,MouseInfoTime);


keyboard;
finalEvaluation_MouseWeight();
finalEvaluation_ShowImagingTimepoints(MouseInfo);
% [PlaqueListSingle]=finalEvaluation_Dystrophies1Quantification_5(MouseInfo,PlaqueListSingle); % 3min
% [PlaqueListSingle]=finalEvaluation_Boutons1Quantification_2(MouseInfo,PlaqueListSingle);

% DataAssignment=table;
% DataAssignment({'Volume1b'},{'SubPools','FileType'})={{{[1;2;3;4;5]}},1};
% DataAssignment({'Volume2b'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Volume1a'},{'SubPools','FileType'})={{{[1;2;3;4;5]}},2};
% % % DataAssignment({'Dystrophies1'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'DystrophiesPl'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Autofluo1'},{'SubPools','FileType'})={{{[1;2]}},1};
% % % DataAssignment({'VglutGreen'},{'SubPools','FileType'})={{{[2]}},2};
% DataAssignment({'MetBlue'},{'SubPools','FileType'})={{{[2]}},1};
% % % DataAssignment({'Boutons1'},{'SubPools','FileType'})={{{[1;2]}},2};
% DataAssignment.Name=DataAssignment.Properties.RowNames;
% % % quadrants =1; lateral to plaque =2; above plaque =3; below plaque =4; Blood =5; Outside =6;








keyboard;


% [MouseInfo]=finalEvaluationPoolRois(MouseInfo);
% [MouseInfoTime,MouseInfo]=finalEvaluation_PlaquesQuantificationGlobal_2(MouseInfo,PlaqueList,PlaqueListSingle,MouseInfoTime,PathExcelExport);


PlaqueList=PlaqueList(:,{'MouseId','RoiId','Pl','TreatmentType','StartTreatmentNum','PlBirth','PlaqueSizeFit'});


[SingleStacks]=finalEvaluation_PoolSubRegions(SingleStacks); %10min











TreatmentGroups=finalEvaluation_PoolTreatmentTypes(MouseInfoTime,MouseInfo);


finalEvaluation_ShowPlaqueGrowth(PlaqueList);

% % % [SingleStacks]=finalEvaluation_RemoveParameters(SingleStacks); % 15min

% [SingleStacks]=finalEvaluation_IntegrateSurfaceSpotInfo(SingleStacks); % 8min
% % % % [MouseInfo,PlaqueListBoutons1]=finalEvaluation_Boutons1Global(SingleStacks,MouseInfo);

% fuse defined SubRegions




% calculate density NormTotal etc.

% get corresponding data from different timepoints into one table for each plaque
% % % [TimeDistTable]=finalEvaluation_GatherData(MouseInfo,SingleStacks); % 105min
% [MouseInfo]=finalEvaluation_Quantification2(MouseInfo); % trace fits to temporal progression of different Mods

% OrigMouseInfo=MouseInfo;

% [PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification(MouseInfo); % 9min

% % % [SingleStacks]=finalEvaluation_DensityCalc(SingleStacks); % 10min





keyboard;









[MouseInfo]=finalEvaluation_Boutons1GlobalDensity(SingleStacks,MouseInfo);

[MouseInfo,PlaqueListAutofluo1]=finalEvaluation_Autofluo1Quantification(TimeDistTable,MouseInfo);


[MouseInfo,PlaqueListMetBlue]=finalEvaluation_MetBlueQuantification(TimeDistTable,MouseInfo);
[MouseInfo,PlaqueListMetRed]=finalEvaluation_MetRedQuantification(TimeDistTable,MouseInfo);



% % finalEvaluation_Autofluo1Quantification(MouseInfo);

% make smoothing calculations
[TimeDistTable]=finalEvaluation_Smoothing(TimeDistTable,MouseInfo);


%% export images and movies
finalEvaluation_Visualize(MouseInfo,TimeDistTable);







% include TotalResults
[PlaqueData]=finalEvaluationSub8(PlaqueData,SibInfo);
% calculate dystrophy extension for each plaque
[PlaqueData]=finalEvaluationSub7(PlaqueData);






%% extract surfaces/spots regardless of Membership of all timepoints into single table
[SurfaceData]=finalEvaluationSub2(FileTypes,NameTable);



%% finish data setting
%     TotalResults=struct;
%     Co.Xaxis=Xaxis;
TotalResults.VariableNames=VariableNames;
TotalResults.FA=FA;
TotalResults.PlaqueData=PlaqueData;
TotalResults.SuperficialAutofluoMargin=SuperficialAutofluoMargin;

save(PathTotalResults,'TotalResults');



%% make scatter plot for Autofluo distance versus size
J=struct;
J.Tit='Autofluorescence distance versus density';
J.X=SurfaceData.AutofluoSurface.Distance;
J.Y=SurfaceData.AutofluoSurface.Volume;
J.Sp={'w.'};
J.Xlab='Distance [µm]';
J.Ylab='Volume [µm^3]';
J.Layout='black';
J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',AutofluoDistanceDensity.emf'];
movieBuilder_4(J);


%% make image for depth distribution of autofluorescent particles
J=struct;
J.Tit='Autofluorescence depth distribution';
J.X=AutofluoDepthDistribution.Depth;
J.Y=[AutofluoDepthDistribution{:,2:6}*100];
J.Sp={'r.';'c.';'y-';'w-';'g-'};
J.Xlab='Depth [µm]';
J.Ylab='Volume [µm^3]';
J.Layout='black';
J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',AutofluoDepthDistribution.emf'];
movieBuilder_4(J);



%% make movie for each plaque
for m=1:size(PlaqueData,1)
    J=struct;
    J.Tit=strcat({'Timepoint: '},num2strArray((1:21).'));
    J.Frequency=2;
    J.X=(-50:205).';
    J.OrigYaxis=[   {PlaqueData.Vector{m,1}.Plaque{1}{:,:}./PlaqueData.Vector{m,1}.Volume{1}{:,:}},{'w.'};...
        ];
    J.OrigType=3;
    J.Xlab='Distance [µm]';
    J.Ylab='Intensity [a.u.]';
    J.Xrange=[-10;150];
    J.Layout='black';
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',Plaque',num2str(m),',Plaque.avi'];
    movieBuilder_4(J);
end



% LargeBoutons density for each plaque
for m=1:size(PlaqueData,1)
    Timepoints=2;
    J=struct;
    J.Tit=strcat({'Timepoint: '},num2strArray((1:Timepoints).'));
    J.Frequency=2;
    J.X=(-50:205).';
    J.OrigYaxis=[   {PlaqueData.Vector{m,2}.BoutonsLarge{1}{:,1:Timepoints}./PlaqueData.Vector{m,2}.Volume{1}{:,1:Timepoints}},{'w.'};...
        ];
    J.OrigType=3;
    J.Xlab='Distance [µm]';
    J.Ylab='Bouton density [/µm^3]';
    J.Xrange=[-10;150];
    %         J.Yrange=[0;0.05];
    J.Layout='black';
    J.Path=[SavePath,NameTable{'Trace','Filename'}{1},',Plaque',num2str(m),',BoutonsLarge.avi'];
    movieBuilder_4(J);
end


















return;


% [TraceFileinfo]=getFileinfo_2(NameTable{'Trace','FilenameTotal'});
% PathTotalResults=[SibInfo.FamilyName,'_RatioResults.mat'];
% [PathTotalResults,Report]=getPathRaw(PathTotalResults);
% if Report==1
%     %         keyboard;
%     TotalResults=load(PathTotalResults);
%     TotalResults=TotalResults.TotalResults;
%     %         v2struct(TotalResults);
% else
%     TotalResults=struct;
%     FA=table;
% end

%% calculate nearby Autofluo and empty corona as well as normal level far from Plaque
for m=1:PlaqueNumber
    Modalities=table; % Timepoints in X, Plaques in Y
    % ProximalAutofluo : <10
    % EmptyCorona : 10 to 30
    % DistalAutofluo : >30
    Wave1=PlaqueData.Info3D{m,1}(:,VariableNames.AutofluoSurface,:);
    Wave1=permute(Wave1,[1,3,2]);
    Modalities.ProximalAutofluoVolume=nansum(Wave1(1:60,:),1).';
    
    Volume=PlaqueData.Info3D{m,1}(:,VariableNames.Volume,:);
    Volume=permute(Volume,[1,3,2]);
    Modalities.ProximalAutofluoDensity=Modalities.ProximalAutofluoVolume./nansum(Volume(1:60,:),1).';
    Modalities.MedialAutofluoDensity=Modalities.ProximalAutofluoVolume./nansum(Volume(60:80,:),1).';
    Modalities.DistalAutofluoDensity=nansum(Wave1(80:end,:),1).'./nansum(Volume(80:end,:),1).';
    
    PlaqueData.Modalities(m,1)={Modalities};
    
    
end


%% gather info on Surfaces and Spots objects
for m2=1:size(FileTypes,1)
    Timepoints=max(FileTypes.FA{m2,1}.Timepoint);
    
    for m=1:size(FileTypes.FA{m2,1},1)
        VariableNames=varName2Col(FileTypes.FA{m2,1}.RatioResults{m,1}.Statistics.AutofluoSurface.ChannelNames);
        Statistics=FileTypes.FA{m2,1}.RatioResults{m,1}.Statistics.AutofluoSurface.ObjInfo;
        
        A1=struct2table(Statistics);
        
        AutofluoStatistics=table;
        AutofluoStatistics.Volume=Statistics.Volume;
        AutofluoStatistics.DistancetoImageBorderXYZ=Statistics.DistancetoImageBorderXYZ;
        AutofluoStatistics.CenterofHomogeneousMassXYZ=[Statistics.CenterofHomogeneousMassX,Statistics.CenterofHomogeneousMassY,Statistics.CenterofHomogeneousMassZ];
        AutofluoStatistics.IntensityMean=Statistics.IntensityMean;
        AutofluoStatistics.Sphericity=Statistics.Sphericity;
        % depth
        keyboard; % update MultiDimInfo retrieval
        TumMinMax=FileTypes.FA{m2,1}.MultiDimInfo{m,1}.TumMinMax;
        Wave1=TumMinMax(3,1)-FileTypes.FA{m2,1}.Fileinfo{m,1}.UmStart{1}(3,1);
        AutofluoStatistics.Depth=AutofluoStatistics.CenterofHomogeneousMassXYZ(:,3)+Wave1;
        % Membership
        AutofluoStatistics.Membership=round(AutofluoStatistics.IntensityMean(:,VariableNames.Membership));
        % Distance to next plaque
        AutofluoStatistics.Distance2Plaque=AutofluoStatistics.IntensityMean(:,VariableNames.DistInOut);
        FileTypes.FA{m2,1}.AutofluoStatistics(m,1)={AutofluoStatistics};
    end
    
    
end

%% define SuperficialAutofluoMargin
AllAutofluo=FA.AutofluoStatistics{1,1};
for m=2:size(FA,1)
    AllAutofluo=[AllAutofluo;FA.AutofluoStatistics{m,1}];
end
Wave1=AllAutofluo(:,{'Depth';'Volume'});
Wave1.Depth=round(Wave1.Depth);
AutofluoDepthDistribution=table;
AutofluoDepthDistribution.Depth=(min(Wave1.Depth):max(Wave1.Depth)).';
for m=1:size(AutofluoDepthDistribution,1)
    AutofluoDepthDistribution.Volume(m,1)=sum(Wave1.Volume(Wave1.Depth==AutofluoDepthDistribution.Depth(m,1)));
    AutofluoDepthDistribution.Count(m,1)=size(find(Wave1.Depth==AutofluoDepthDistribution.Depth(m,1)),1);
end
Smooth=table; Smooth.Power=[10;10;10];
[Wave1,Out]=ableitung_2([AutofluoDepthDistribution.Volume;0;0],[],Smooth);
Ind=max(Out.MaximaLocs(:,2)); % first max of 1.Ableitung
SuperficialAutofluoMargin=AutofluoDepthDistribution.Depth(Ind);
AutofluoDepthDistribution.Smooth=Wave1(:,1);
AutofluoDepthDistribution.Abl1=Wave1(:,2);
AutofluoDepthDistribution.Abl2=Wave1(:,3);
AutofluoDepthDistribution.Volume=AutofluoDepthDistribution.Volume/max(AutofluoDepthDistribution.Volume);
AutofluoDepthDistribution.Count=AutofluoDepthDistribution.Count/max(AutofluoDepthDistribution.Count);




    AllAutofluo=[AllAutofluo;FA.AutofluoStatistics{m,1}];
end
Wave1=AllAutofluo(:,{'Depth';'Volume'});
Wave1.Depth=round(Wave1.Depth);
AutofluoDepthDistribution=table;
AutofluoDepthDistribution.Depth=(min(Wave1.Depth):max(Wave1.Depth)).';
for m=1:size(AutofluoDepthDistribution,1)
    AutofluoDepthDistribution.Volume(m,1)=sum(Wave1.Volume(Wave1.Depth==AutofluoDepthDistribution.Depth(m,1)));
    AutofluoDepthDistribution.Count(m,1)=size(find(Wave1.Depth==AutofluoDepthDistribution.Depth(m,1)),1);
end
Smooth=table; Smooth.Power=[10;10;10];
[Wave1,Out]=ableitung_2([AutofluoDepthDistribution.Volume;0;0],[],Smooth);
Ind=max(Out.MaximaLocs(:,2)); % first max of 1.Ableitung
SuperficialAutofluoMargin=AutofluoDepthDistribution.Depth(Ind);
AutofluoDepthDistribution.Smooth=Wave1(:,1);
AutofluoDepthDistribution.Abl1=Wave1(:,2);
AutofluoDepthDistribution.Abl2=Wave1(:,3);
AutofluoDepthDistribution.Volume=AutofluoDepthDistribution.Volume/max(AutofluoDepthDistribution.Volume);
AutofluoDepthDistribution.Count=AutofluoDepthDistribution.Count/max(AutofluoDepthDistribution.Count);