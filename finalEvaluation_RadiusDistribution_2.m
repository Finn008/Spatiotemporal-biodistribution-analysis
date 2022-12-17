function finalEvaluation_RadiusDistribution_2(MouseInfo,PlaqueListSingle,MouseInfoTime)
global W;
ExcelFilename=['PlaqueSizeDistribution'];
OutputFilename=[W.G.T.TaskName{W.Task},'_',ExcelFilename,'.xlsx'];
PathExcelExport=getPathRaw(OutputFilename);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

TimeMinMax=[min(MouseInfoTime{:,W.XaxisType});max(MouseInfoTime{:,W.XaxisType})];
PlaqueListSingle(PlaqueListSingle.RadiusFit1<=0|isnan(PlaqueListSingle.RadiusFit1),:)=[];
%% calculate mean radius
BinInfo={'MouseId',0,0,0;
    W.XaxisType,7,TimeMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;

Table=accumArrayBinning(PlaqueListSingle,BinInfo,'RadiusFit1',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','RadiusFit1',MouseInfo.MouseId);
[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'TreatmentType'})).';
TableExport(end+1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'MouseId'})).';
TableExport=[TableExport(1,:);TableExport(end,:);TableExport(2:end-1,:)];
xlsActxWrite(TableExport,Workbook,'MeanRadius',[],'Delete');


%% calculate radius distribution

PlaqueListSingle=fuseTable_MatchingColums_2(PlaqueListSingle,MouseInfoTime,{'MouseId';'Age'},{'TotalVolume'});
PlaqueListSingle.PlaqueDensity=ones(size(PlaqueListSingle,1),1)./PlaqueListSingle.TotalVolume*1000000000;

RadiusMinMax=[0;ceil(max(PlaqueListSingle.RadiusFit1))];
BinInfo={'MouseId',0,0,0;
    W.XaxisType,7,TimeMinMax,0;
    'RadiusFit1',2,RadiusMinMax,0;
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
% PlaqueListSingle.Count(:,1)=1;
Table=accumArrayBinning(PlaqueListSingle,BinInfo,'PlaqueDensity',[],@sum);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','PlaqueDensity',MouseInfo.MouseId);
[TableExport]=table2cell_2(Table);
TableExport(1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'TreatmentType'})).';
TableExport(end+1,end-size(MouseInfo,1)+1:end)=table2cell(MouseInfo(:,{'MouseId'})).';
TableExport=[TableExport(1,:);TableExport(end,:);TableExport(2:end-1,:)];
xlsActxWrite(TableExport,Workbook,'RadiusDistribution',[],'Delete');

Workbook.Save;
Workbook.Close;