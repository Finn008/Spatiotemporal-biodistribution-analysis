function finalEvaluation_VolumeDistribution_3(MouseInfo,PlaqueHistograms)
global W;
XaxisType='Age';
PlaqueHistograms=accumarray_9(PlaqueHistograms(:,{'MouseId';'Age';'Time2Treatment';'Distance'}),PlaqueHistograms(:,'VolumeRealUm3'),@sum);
TableExport=table;
if strcmp(XaxisType,'Age')
    AgeMinMax=[min(PlaqueHistograms.Age);max(PlaqueHistograms.Age)];
    BinInfo={'MouseId',0,0,0;
        'Age',7,[70;245],0;
        'Distance',[1],[-20;200],0;
        };
elseif strcmp(XaxisType,'TimeToTreatment')
    BinInfo={'MouseId',0,0,0;
        'Time2Treatment',7,[-28;70],0;
        'Distance',[1],[-20;200],0;
        };
end
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(PlaqueHistograms,BinInfo,'VolumeRealUm3');

% normalize such that unique MouseId, Time2Treatment_Min, Time2Treatment_Max, Time2Treatment_Bin always are 100 percent
CalculationStyle='Total100Percent'; %'NormalizeMaxTo100Percent';
if strcmp(CalculationStyle,'NormalizeMaxTo100Percent')
    Wave1=accumarray_9(Table(:,{'MouseId',[XaxisType,'_Min'],[XaxisType,'_Max'],[XaxisType,'_Bin']}),Table(:,'VolumeRealUm3'),@max);
elseif strcmp(CalculationStyle,'Total100Percent')
    Wave1=accumarray_9(Table(:,{'MouseId',[XaxisType,'_Min'],[XaxisType,'_Max'],[XaxisType,'_Bin']}),Table(:,'VolumeRealUm3'),@sum);
end
Table.Properties.VariableNames{'VolumeRealUm3'}='Data';
Table=fuseTable_MatchingColums_2(Table,Wave1,{'MouseId',[XaxisType,'_Min'],[XaxisType,'_Max'],[XaxisType,'_Bin']},{'VolumeRealUm3'});
Table.Data=Table.Data./Table.VolumeRealUm3*100;
Table(:,'VolumeRealUm3')=[];
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);

Table.Specification(:,1)={['NormalizedVolumeDistribution']};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;

% mean distance
PlaqueHistograms2=PlaqueHistograms;
PlaqueHistograms2.Product=PlaqueHistograms2.VolumeRealUm3.*PlaqueHistograms2.Distance;
PlaqueHistograms2=accumarray_9(PlaqueHistograms2(:,{'MouseId',XaxisType}),PlaqueHistograms2(:,{'VolumeRealUm3';'Product'}),@sum);
PlaqueHistograms2.Data=PlaqueHistograms2.Product./PlaqueHistograms2.VolumeRealUm3;
PlaqueHistograms2(:,{'VolumeRealUm3','Product'})=[];

if strcmp(XaxisType,'Age')
    BinInfo={'MouseId',0,0,0;
        'Age',7,[70;245],0;
        };
elseif strcmp(XaxisType,'TimeToTreatment')
    BinInfo={'MouseId',0,0,0;
        'Time2Treatment',7,[-28;70],0;
        };
end
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(PlaqueHistograms2,BinInfo,'Data');
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Data',MouseInfo.MouseId);
Table.Specification(:,1)={['MeanDistance']};
TableExport(end+1:end+size(Table,1),Table.Properties.VariableNames)=Table;

TableExport=TableExport(:,{'Specification';[XaxisType,'_Min'];[XaxisType,'_Max'];[XaxisType,'_Bin'];'Distance_Min';'Distance_Max';'Distance_Bin';'Data'});
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;

OutputFilename=[W.G.T.TaskName{W.Task},'_','DistanceVolumeHistogram.xlsx'];
PathExcelExport=getPathRaw(OutputFilename);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

xlsActxWrite(TableExport,Workbook,'Histogram',[],'Delete');
Workbook.Save;
Workbook.Close;