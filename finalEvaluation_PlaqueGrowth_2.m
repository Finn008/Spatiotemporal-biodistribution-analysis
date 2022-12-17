function [MouseInfo]=finalEvaluation_PlaqueGrowth_2(MouseInfo,PlaqueListSingle)
global W;

XaxisType='Age'; %'TimeTo'
if strcmp(XaxisType,'Age')
    XaxisType='Age';
    TimeZero=30.42*4;
elseif strcmp(XaxisType,'TimeTo')
    XaxisType='Time2Treatment';
    TimeZero=0;
end

MinMax=[min(PlaqueListSingle{:,XaxisType});max(PlaqueListSingle{:,XaxisType})];

% % % MouseInfo(strcmp(MouseInfo.TreatmentType,'TauKO'),:)=[];
% % % PlaqueListSingle(strcmp(PlaqueListSingle.TreatmentType,'TauKO'),:)=[];
PlaqueListSingle.VolumeFit1=PlaqueListSingle.RadiusFit1.^3*4/3*3.1415;

MouseIds=strcat('M',num2strArray_2(MouseInfo.MouseId));
TableRadialGrowth=table;
TableVolume=table;
TableRadius=table;
TimeBinning=[999;30.42;7];
TimeBins=zeros(0,3);
for TimeBin=1:size(TimeBinning,1)
    TimeBinId=TimeBinning(TimeBin);
    MinMaxBinRange=[floor((MinMax(1)-TimeZero)/TimeBinId);ceil((MinMax(2)-TimeZero)/TimeBinId)];
    MinMaxBinRange=MinMaxBinRange*TimeBinId+TimeZero;
    Wave1=(MinMaxBinRange(1):TimeBinId:MinMaxBinRange(2)).';
    TimeBins=[TimeBins;[Wave1(1:end-1),Wave1(2:end),repmat(TimeBinning(TimeBin),[size(Wave1,1)-1,1])]];
end

% define RadiiBins
MaxRadius=ceil(max(PlaqueListSingle.Radius));
RadiiBinning=[MaxRadius;5];
RadiiBins=zeros(0,3);
for RadBin=1:size(RadiiBinning,1)
    Wave1=ceil(MaxRadius/RadiiBinning(RadBin))*RadiiBinning(RadBin);
    Wave1=(0:RadiiBinning(RadBin):Wave1).';
    RadiiBins=[RadiiBins;[Wave1(1:end-1),Wave1(2:end),repmat(RadiiBinning(RadBin),[size(Wave1,1)-1,1])]];
end

% read out the means of PlaqueGrowth
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
%     if MouseId~=314; continue; end;
    for RadBin=1:size(RadiiBins,1)
        RadBinId=RadiiBins(RadBin,:).';
        Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.RadiusFit1>RadBinId(1) & PlaqueListSingle.RadiusFit1<=RadBinId(2),:);
        for TimeBin=1:size(TimeBins,1)
            TimeBinId=TimeBins(TimeBin,:).';
            Selection2=Selection(Selection{:,XaxisType}>TimeBinId(1) & Selection{:,XaxisType}<=TimeBinId(2),:);
            RowId=['Rad',num2str(RadBin),'Time',num2str(TimeBin)];
            if Mouse==1
                TableRadialGrowth(RowId,{'RadiiBinning','RadiiRange','TimeBinning','TimeRange'})={RadBinId(3),RadBinId(1:2).',TimeBinId(3),TimeBinId(1:2).'};
                TableVolume(RowId,{'RadiiBinning','RadiiRange','TimeBinning','TimeRange'})={RadBinId(3),RadBinId(1:2).',TimeBinId(3),TimeBinId(1:2).'};
                TableRadius(RowId,{'RadiiBinning','RadiiRange','TimeBinning','TimeRange'})={RadBinId(3),RadBinId(1:2).',TimeBinId(3),TimeBinId(1:2).'};
            end
            TableRadialGrowth(RowId,MouseIds(Mouse))={trimmean(Selection2.Growth,20)*7};
            TableVolume(RowId,MouseIds(Mouse))={nanmedian(Selection2.VolumeFit1)};
            TableRadius(RowId,MouseIds(Mouse))={nanmedian(Selection2.RadiusFit1)};
        end
    end
end
% % % % make radius histogram
% % % TableRadiusCumSum=table;
% % % TableRadiusCumSum.Specification(1)={'MouseId'};Table.Data=MouseInfo.Mouse.';
% % % TableRadiusHistogram=table;
% % % TableRadiusHistogram.Specification(1)={'MouseId'};Table.Data=MouseInfo.Mouse.';
% % % for Mouse=1:size(MouseInfo,1)
% % %     MouseId=MouseInfo.Mouse(Mouse);
% % %     Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId,:);
% % %     for TimeBin=1:size(TimeBins,1)
% % %         TimeBinId=TimeBins(TimeBin,:).';
% % %         Selection2=Selection(Selection{:,XaxisType}>TimeBinId(1) & Selection{:,XaxisType}<=TimeBinId(2),:);
% % %         [CumSum,Histogram,Ranges]=cumSumGenerator(Selection2.RadiusFit1,(0.001:1:30.001).');
% % %         
% % %         RowId=table; RowId.RadiusBin=mean(Ranges,2); RowId.Specification(:,1)={'RadiusCumSum'}; RowId.TimeMin(:,1)=TimeBinId(1); RowId.TimeMax(:,1)=TimeBinId(2); RowId.TimeBin(:,1)=TimeBinId(3);
% % %         TableRadiusCumSum=addData2OutputTable(TableRadiusCumSum,CumSum,RowId,Mouse);
% % %         RowId=table; RowId.RadiusBin=mean(Ranges,2); RowId.Specification(:,1)={'RadiusHistogram'}; RowId.TimeMin(:,1)=TimeBinId(1); RowId.TimeMax(:,1)=TimeBinId(2); RowId.TimeBin(:,1)=TimeBinId(3);
% % %         TableRadiusHistogram=addData2OutputTable(TableRadiusHistogram,Histogram,RowId,Mouse);
% % %     end
% % % end

% export to excel
PathExcelExport='\\GNP90N\share\Finn\Raw data\PlaqueGrowth.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableRadialGrowth,Workbook,['RadialGrowth'],[],1);
xlsActxWrite(TableVolume,Workbook,['Volume'],[],1);
xlsActxWrite(TableRadius,Workbook,['Radius'],[],1);
% % % xlsActxWrite(TableRadiusCumSum,Workbook,['RadiusCumSum'],[],1);
% % % xlsActxWrite(TableRadiusHistogram,Workbook,['RadiusHistogram'],[],1);
Workbook.Save;
Workbook.Close;