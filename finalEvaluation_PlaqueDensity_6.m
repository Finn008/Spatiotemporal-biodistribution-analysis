function [NewBornPlaqueList]=finalEvaluation_PlaqueDensity_5(MouseInfo,PlaqueListSingle,PlaqueList,MouseInfoTime,PlaqueHistograms,TimeBinning)
global W;
XaxisType='Age'; %'TimeToTreatment'
ExcelFilename=['PlaqueDensity'];
OutputFilename=[W.G.T.TaskName{W.Task},'_',ExcelFilename,'.xlsx'];
PathExcelExport=getPathRaw(OutputFilename);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

% % % MouseInfo=MouseInfo(ismember(MouseInfo.TreatmentType,{'NB360';'NB360Vehicle'}),:);
MouseInfo(MouseInfo.RealDistanceMinMax(:,2)==-50,:)=[]; % remove mice with no longitudinal data
for Mouse=1:size(MouseInfo,1)
    Wave1=PlaqueListSingle.Time2Treatment(PlaqueListSingle.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.Time2Treatment(Mouse,1:2)=[min(Wave1),max(Wave1)];
    Wave1=PlaqueListSingle.Age(PlaqueListSingle.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.Age(Mouse,1:2)=[min(Wave1),max(Wave1)];
end
% calculate real volume at each distance
Wave1=accumarray_8(PlaqueHistograms(:,{'MouseId';'Time2Treatment';'Distance'}),PlaqueHistograms(:,'VolumeRealUm3'),@sum);
Wave1=distributeColumnHorizontally_2(Wave1,{'MouseId';'Time2Treatment'},'Distance','VolumeRealUm3',[0;255]);
MouseInfoTime=fuseTable_MatchingColums(MouseInfoTime,Wave1,{'MouseId';'Time2Treatment'});
MouseInfoTime.Properties.VariableNames{end}='VolumeRealPerDistance';

% identify date of formation for each plaque
PlaqueDetectionLimit=4;
for Pl=1:size(PlaqueList,1)
    Selection=PlaqueListSingle(PlaqueListSingle.MouseId==PlaqueList.MouseId(Pl) & PlaqueListSingle.RoiId==PlaqueList.RoiId(Pl) & PlaqueListSingle.PlId==PlaqueList.PlId(Pl),:);
    IndPresent=find(Selection.RadiusFit1>PlaqueDetectionLimit,1);
    IndNotPresent=find(Selection.RadiusFit1<=PlaqueDetectionLimit,1);
    AllNaN=min(isnan(Selection.RadiusFit1));
    if IndPresent==1 % plaque exists from beginning on
        Age=0;
        Time2Treatment=-99999999999;
    elseif AllNaN==1 && max(Selection.Radius)<=PlaqueDetectionLimit % plaque did not form at all
        Age=NaN;
        Time2Treatment=NaN;
    elseif AllNaN==1 && max(Selection.Radius)>PlaqueDetectionLimit % plaque exists from beginning on
        Age=0;
        Time2Treatment=-99999999999;
    elseif isempty(IndPresent)==1 && isempty(IndNotPresent)==0 % plaque did not form at all
        Age=NaN;
        Time2Treatment=NaN;
    elseif IndPresent>1 && isempty(IndNotPresent)==0 % plaque formed during imaging period
        Age=Selection.Age(IndPresent);
        Time2Treatment=Selection.Time2Treatment(IndPresent);
        PlaqueList.Time(Pl,1)=Selection.Time(IndPresent);
        Wave1=find(isnan(Selection.ClosestPlaque(1:IndPresent))==0,1,'last'); % if Radius is NaN at that location then find previous nonNaN
        PlaqueList.ClosestPlaque(Pl,1)=Selection.ClosestPlaque(Wave1);
        PlaqueList.Distance2ClosestPlaque(Pl,1)=Selection.Distance2ClosestPlaque(Wave1);
    elseif IndPresent>1 && isempty(IndNotPresent)==1 % plaque touched the border at all timepoints before it surpassed PlaqueDetectionLimit
        Age=0; % plaque exists from beginning on
        Time2Treatment=-99999999999;
    
    else
        keyboard;
    end
    PlaqueList.PlBirth(Pl,1)=Age;
    PlaqueList.PlBirth(Pl,2)=Time2Treatment;
end
PlaqueList(isnan(PlaqueList.PlBirth(:,1)),:)=[];
NewBornPlaqueList=PlaqueList(PlaqueList.PlBirth(:,1)~=0,:);
NewBornPlaqueList.PlBirth=NewBornPlaqueList.PlBirth(:,1);
TimeMinMax=[min(PlaqueListSingle{:,XaxisType});max(PlaqueListSingle{:,XaxisType})];

if strcmp(XaxisType,'Age')
    PlaqueList.PlBirth=PlaqueList.PlBirth(:,1);
elseif strcmp(XaxisType,'TimeToTreatment')
    PlaqueList.PlBirth=PlaqueList.PlBirth(:,2);
end

%% export number of plaques and newborn plaques for each mouse
Table=MouseInfo(:,{'MouseId';'TreatmentType'});
Wave1=unique(PlaqueListSingle(:,{'MouseId';'RoiId';'PlId'}));
Wave1.Count(:,1)=1;
Wave1=accumarray_9(Wave1(:,{'MouseId'}),Wave1(:,'Count'),@sum);
Table.AllPlaques(ismember2(Wave1.MouseId,Table.MouseId))=Wave1.Count;

Wave1=PlaqueListSingle(PlaqueListSingle.MinimalVglutDistance<1,:);
Wave1=unique(Wave1(:,{'MouseId';'RoiId';'PlId'}));
Wave1.Count(:,1)=1;
Wave1=accumarray_9(Wave1(:,{'MouseId'}),Wave1(:,'Count'),@sum);
Table.Vglut1Plaques(ismember2(Wave1.MouseId,Table.MouseId))=Wave1.Count;

Wave1=NewBornPlaqueList;
Wave1.Count(:,1)=1;
Wave1=accumarray_9(Wave1(:,{'MouseId'}),Wave1(:,'Count'),@sum);
Table.NewPlaques(ismember2(Wave1.MouseId,Table.MouseId))=Wave1.Count;

xlsActxWrite(Table,Workbook,'PlaqueNumber',[],'Delete');
%% distribution of plaque centers
BinInfo={'Time',14,[28;42]}; %  previously [56;70]
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax'});

[BinTable,~]=generateBinTable_3(BinInfo,MouseInfo);
Table=table;
Table('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'DistMin';'DistMax';'DistBin';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,NaN,NaN,MouseInfo.MouseId.'};
DistBin=20;
for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,:);
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        
        Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId...
            & PlaqueListSingle.Time2Treatment>BinTable.TimeMin(Bin)...
            & PlaqueListSingle.Time2Treatment<=BinTable.TimeMax(Bin)...
            ,:);
        if size(Selection,1)==0; continue; end;
        
        [CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(Selection.MinCenter2Center,(0:DistBin:200).');
        
        RowId=table; RowId.DistMin=Ranges(:,1);RowId.DistMax=Ranges(:,2); RowId.Specification(:,1)={'Center2Center'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,NormHistogram,RowId,Mouse);
        
        [CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(Selection.Distance2ClosestPlaque,(0:DistBin:200).');
        RowId=table; RowId.DistMin=Ranges(:,1);RowId.DistMax=Ranges(:,2); RowId.Specification(:,1)={'Border2Border'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,NormHistogram,RowId,Mouse);
    end
end


TableExport=addData2OutputTable_2(Table,struct(),table(MouseInfo.TreatmentType,'VariableNames',{'TreatmentType'}),{'DistMin';'DistBin';'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'Center2Center',[],'Delete');

%% plaque formation in regards to closest plaque distance
DoPlaqueFormationWithDistance=1;
if DoPlaqueFormationWithDistance==1
    TimeRange=30.42*[3;6];
    % calculate mean volume of each distance bin for every timepoint
    BinInfo={'MouseId',0,0,0;
        'Age',0,0,0;
        'Time2Treatment',0,0,0;
        'Distance',20,[-60;200],0;
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
    TableVolume=accumArrayBinning(PlaqueHistograms,BinInfo,'VolumeRealUm3',[],@sum);
    
    NewBornPlaqueList2=NewBornPlaqueList;
    NewBornPlaqueList2.Distance2ClosestPlaque(NewBornPlaqueList2.Distance2ClosestPlaque==0)=0.01;
    NewBornPlaqueList2.Age=NewBornPlaqueList2.PlBirth;
    NewBornPlaqueList2.Time2Treatment=NewBornPlaqueList2.PlBirth;
    NewBornPlaqueList2.Distance=NewBornPlaqueList2.Distance2ClosestPlaque;
    NewBornPlaqueList2.NewPlaques(:,1)=1;
    TablePlaqueNumber=accumArrayBinning(NewBornPlaqueList2,BinInfo,'NewPlaques',[],@sum);
       
    TableVolume=fuseTable_MatchingColums_2(TableVolume,TablePlaqueNumber,{'MouseId';'Age';'Distance_Min';'Distance_Max'},{'NewPlaques'});
    TableVolume.NewPlaqueDensity=TableVolume.NewPlaques./TableVolume.VolumeRealUm3;   
    TableVolume(TableVolume.VolumeRealUm3==0,:)=[];
    Table=accumarray_9(TableVolume(:,{'MouseId';'Distance_Min';'Distance_Max'}),TableVolume(:,'NewPlaqueDensity'),@sum);
    Table.NewPlaqueDensity=Table.NewPlaqueDensity/(TimeRange(2)-TimeRange(1))*7*1000000000;
    Table=distributeColumnHorizontally_4(Table(:,{'MouseId';'Distance_Min';'Distance_Max';'NewPlaqueDensity'}),[],'MouseId','NewPlaqueDensity',MouseInfo.MouseId);
    [TableExport]=table2cell_2(Table);
    TableExport(1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'TreatmentType'})).';
    TableExport(end+1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'MouseId'})).';
    TableExport=[TableExport(1,:);TableExport(end,:);TableExport(2:end-1,:)];
    xlsActxWrite(TableExport,Workbook,'FormationVsDistance',[],'Delete');
end

%% plaque formation with time
DoPlaqueFormation=1;
if DoPlaqueFormation==1
    if exist('TimeBinning')~=1 || isempty(TimeBinning)
        TimeBinning=[30.42;14;7];
    end
    [BinTable]=generateBinTable([],TimeBinning,[],TimeMinMax,MouseInfo);
    Table=table;
    Table('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'Data'})={{'MouseId'},NaN,NaN,NaN,MouseInfo.MouseId.'};
    
    for Bin=1:size(BinTable,1)
        OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin'});
        % determine whether timepoint exists, otherwise produces zero results
        Selection2=MouseInfoTime(MouseInfoTime.MouseId==BinTable.MouseId(Bin)...
            & MouseInfoTime{:,XaxisType}>BinTable.TimeMin(Bin)...
            & MouseInfoTime{:,XaxisType}<=BinTable.TimeMax(Bin),:);
        if size(Selection2,1)==0
            Density=NaN;
            PlaqueFormation=NaN;
        else
            % density
            Selection=PlaqueList(PlaqueList.MouseId==BinTable.MouseId(Bin) & PlaqueList.PlBirth<=BinTable.TimeMax(Bin),:);
            PlaqueNumber=size(Selection,1);
            Volume=MouseInfo.VolumeMinMeanMax(BinTable.Mouse(Bin),2)/1000000000;
            Density=PlaqueNumber/Volume;
            
            % Formation rate
            Selection=PlaqueList(PlaqueList.MouseId==BinTable.MouseId(Bin) & PlaqueList.PlBirth>BinTable.TimeMin(Bin) & PlaqueList.PlBirth<=BinTable.TimeMax(Bin),:);
            ExactTime=0;
            if ExactTime==1
                Min=max(MouseInfo{BinTable.Mouse(Bin),XaxisType}(1),BinTable.TimeMin(Bin));
                Max=min(MouseInfo{BinTable.Mouse(Bin),XaxisType}(2),BinTable.TimeMax(Bin));
                Time=(Max-Min)/7;
            else
                Time=BinTable.TimeBin(Bin)/7;
            end
            PlaqueFormation=size(Selection,1)/Time/Volume; % new plaques per week and mm^3
        end
        
        RowId=table; RowId.Specification(:,1)={'Density'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,Density,RowId,BinTable.Mouse(Bin));
        
        RowId=table; RowId.Specification(:,1)={'Formation'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,PlaqueFormation,RowId,BinTable.Mouse(Bin));
    end
    
    TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'TimeMin';'TimeBin';'Specification'});
    xlsActxWrite(TableExport,Workbook,'Density&Formation',[],'Delete');
end
Workbook.Save;
Workbook.Close;

NewBornPlaqueList=NewBornPlaqueList(:,{'MouseId';'RoiId';'PlId';'TreatmentType';'StartTreatmentNum';'PlBirth';'Time';'ClosestPlaque';'Distance2ClosestPlaque'});