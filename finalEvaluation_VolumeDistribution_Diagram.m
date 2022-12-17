function finalEvaluation_VolumeDistribution_Diagram(Title,MouseInfoTime,MouseInfo,Groups,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Zaxis,Path2file)
global W;
DistBins=(DistanceMinMax(1):DistanceBinning:DistanceMinMax(2)-DistanceBinning).'; DistBins(:,2)=DistBins(:,1)+DistanceBinning;
DistBins(:,3)=DistanceBinning;DistBins(:,4)=mean(DistBins(:,1:2),2);
DistBins=array2table(DistBins,'VariableNames',{'DistMin','DistMax','DistBinning','DistMean'});

TimeBins=(TimeMinMax(1):TimeBinning:TimeMinMax(2)-TimeBinning).'; TimeBins(:,2)=TimeBins(:,1)+TimeBinning;
TimeBins(:,3)=TimeBinning;TimeBins(:,4)=TimeBins(:,2)/7;
TimeBins=array2table(TimeBins,'VariableNames',{'TimeMin','TimeMax','TimeBinning','TimeAxis'});
% TimeBins=1;

Table=table;
Table('MouseId',{'Specification';'Distance';'TimeMin';'TimeMax';'TimeBinning';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,MouseInfo.MouseId.'};
% Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.Mouse.';

for TimeBin=1:size(TimeBins,1)
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId...
            & MouseInfoTime.Time2Treatment>TimeBins.TimeMin(TimeBin)...
            & MouseInfoTime.Time2Treatment<=TimeBins.TimeMax(TimeBin)...
            ,:);
        
        if size(Selection,1)==0
            VolumeDistribution=nan;
        else
            VolumeDistribution=sum(Selection.VolumeDistribution,1).';
            VolumeDistribution=VolumeDistribution(DistBins.DistMin+50,1);
        end
        DistanceHistogram=VolumeDistribution/sum(VolumeDistribution)*5000;
        DistanceCumSum=cumsum(VolumeDistribution);
        DistanceCumSum=DistanceCumSum/max(DistanceCumSum)*100;
% % % % %         VolumeDistribution=cumsum(VolumeDistribution);
% % % % %         VolumeDistribution=VolumeDistribution/max(VolumeDistribution)*100;
        
        MeanDistance=find(DistanceCumSum>50,1);
        MeanDistance=DistBins.DistMin(MeanDistance);
        if isempty(MeanDistance)==0
            RowId=table; RowId.Specification(:,1)={'MeanDistance'}; RowId=[RowId,repmat(TimeBins(TimeBin,{'TimeMin';'TimeMax';'TimeBinning'}),[size(RowId,1),1])];
            Table=addData2OutputTable_2(Table,MeanDistance,RowId,Mouse);
        end
        
        
        RowId=table; RowId.Distance=DistBins.DistMin; RowId.Specification(:,1)={'Histogram'}; RowId=[RowId,repmat(TimeBins(TimeBin,{'TimeMin';'TimeMax';'TimeBinning'}),[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,DistanceHistogram,RowId,Mouse);
        
        
        RowId=table; RowId.Distance=DistBins.DistMin; RowId.Specification(:,1)={'CumSum'}; RowId=[RowId,repmat(TimeBins(TimeBin,{'TimeMin';'TimeMax';'TimeBinning'}),[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,DistanceCumSum,RowId,Mouse);
        
        CumSumTotal(TimeBin,(1:1:size(VolumeDistribution,1)).',Mouse)=DistanceCumSum;
        HistogramTotal(TimeBin,(1:1:size(VolumeDistribution,1)).',Mouse)=DistanceHistogram;
        
    end
end

% export to Excel
OutputFilename=[W.G.T.TaskName{W.Task},'_','DistanceVolumeHistogram'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
TableExport=addData2OutputTable(Table,struct(),MouseInfo);
xlsActxWrite(TableExport,Workbook,'Histogram',[],'Delete');
Workbook.Save;
Workbook.Close;

% normalize such that mean of groups become 100
NormalizeMaxOfMeanGroupsTo100=1;
if NormalizeMaxOfMeanGroupsTo100==1
    clear MaxValue;
    for Group=1:size(Groups,1)
        MouseIds=Groups.MouseIds{Group,1};
        Mice=find(ismember(MouseInfo.MouseId,MouseIds)==1);
        Wave1=nanmean(HistogramTotal(:,:,Mice),3);
        MaxValue(Group,1)=max(Wave1(:));
    end
    HistogramTotal=HistogramTotal/max(MaxValue)*100;
end


Fraction=HistogramTotal; % CumSumTotal

for Group=1:size(Groups,1)
    MouseIds=Groups.MouseIds{Group,1};
    Mice=find(ismember(MouseInfo.MouseId,MouseIds)==1);
    Groups.Xarray(Group,1)={TimeBins.TimeAxis};
    Groups.Yarray(Group,1)={DistBins.DistMean};
    Groups.Zarray(Group,1)={nanmean(Fraction(:,:,Mice),3).'};
    Groups.SeparateX(Group,1)=1;
    Groups.MarkerFaceColor(Group,1)=Groups.Color(Group,1);
    Groups.FaceColor(Group,1)=Groups.Color(Group,1);
    Groups.EdgeColor(Group,1)=Groups.Color(Group,1);
    Groups.Marker(Group,1)={'none'};
    Groups.LineStyle(Group,1)={'-'};
end

General=struct;
General.Title=Title;
General.XTick=(-4:2:10).';
General.YTick=(DistanceMinMax(1):10:DistanceMinMax(2)).';
General.ZTick=Zaxis;
General.Rotation=[147,22];
General.Xlabel='Time [weeks]';
General.Ylabel='Distance to plaque [µm]';
General.Zlabel='Cumulative fraction [%]';


plotSurf(Groups,General,Path2file);


