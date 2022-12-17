function dystrophyDetection_finalMicroglia(MouseInfo,SingleStacks)
global W;
MicrogliaList=table;
for m=1:size(SingleStacks,1)
    if isempty(SingleStacks.MicrogliaInfo{m})
        continue;
    end
    
    Data2Add=SingleStacks.MicrogliaInfo{m}.Somata;
    VariableNames={'Filename';'MouseId';'Roi';'TreatmentType'};
    Data2Add(:,VariableNames)=repmat(SingleStacks(m,VariableNames),[size(Data2Add,1),1]);
    Wave1=Data2Add.SomaCoverage; Wave1(:,end:max(size(Wave1,2),300))=NaN; Wave1=Wave1(:,1:300); Data2Add.SomaCoverage=Wave1;
    MicrogliaList=[MicrogliaList;Data2Add];
    
end

Table=table;
% OrigRowId=BinTable(Bin,{'Percentile'});
Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.MouseId.';

Settings={'Volume';'Diameter';'Iba1Mean';'Iba1CorrMean'};
CumSumEdges=table;
CumSumEdges.Volume={(100:5:1300).'};
CumSumEdges.Diameter={(5:0.05:15).'};
CumSumEdges.Iba1Mean={(3000:200:50000).'};
CumSumEdges.Iba1CorrMean={(300:50:15000).'};

Settings={'Volume';'Diameter';'Iba1Mean';'Iba1CorrMean'};
HistogramEdges=table;
HistogramEdges.Volume={(100:50:1300).'};
HistogramEdges.Diameter={(5:0.1:15).'};
HistogramEdges.Iba1Mean={(3000:2000:50000).'};
HistogramEdges.Iba1CorrMean={(300:500:15000).'};

% MouseIds=unique(MicrogliaList.MouseId);
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=MicrogliaList(MicrogliaList.MouseId==MouseId,:);
    if size(Selection,1)==0; continue; end;
    
    for Setting=Settings.'
        Percentiles=prctile_2(Selection{:,Setting},1:100);
        RowId=table; RowId.Percentile=(1:100).'; RowId.Specification(:,1)={[Setting{1},'Percentiles']};
        Table=addData2OutputTable(Table,Percentiles,RowId,Mouse);
        
        [CumSum,~,Ranges]=cumSumGenerator(Selection{:,Setting},CumSumEdges{1,Setting}{1});
        RowId=table; RowId.Value=Ranges(:,2); RowId.Specification(:,1)={[Setting{1},'CumSum']};
        Table=addData2OutputTable(Table,CumSum,RowId,Mouse);
        
        [~,Histogram,Ranges]=cumSumGenerator(Selection{:,Setting},HistogramEdges{1,Setting}{1});
        RowId=table; RowId.Value=Ranges(:,2); RowId.Specification(:,1)={[Setting{1},'Histogram']};
        Table=addData2OutputTable(Table,Histogram,RowId,Mouse);
        
        Mean=mean(Selection{:,Setting});
        RowId=table; RowId.Specification={[Setting{1},'Mean']};
        Table=addData2OutputTable(Table,Mean,RowId,Mouse);
        
        Median=median(Selection{:,Setting});
        RowId=table; RowId.Specification={[Setting{1},'Median']};
        Table=addData2OutputTable(Table,Median,RowId,Mouse);
    end
    
    % SomaNumber
%     Mean=nanmean(Selection.SomaCoverage.',2);
    RowId=table; RowId.Specification={'SomaNumber'};
    Table=addData2OutputTable(Table,size(Selection,1),RowId,Mouse);
    
    % SomaCoverage
    Mean=nanmean(Selection.SomaCoverage.',2);
    RowId=table; RowId.Distance=(0.1:0.1:30).'; RowId.Specification(:,1)={'SomaCoverageMean'};
    Table=addData2OutputTable(Table,Mean,RowId,Mouse);
    
    Median=nanmedian(Selection.SomaCoverage.',2);
    RowId=table; RowId.Distance=(0.1:0.1:30).'; RowId.Specification(:,1)={'SomaCoverageMedian'};
    Table=addData2OutputTable(Table,Median,RowId,Mouse);
    
    % Density
    Volume=sum(SingleStacks.TotalVolume(SingleStacks.MouseId==MouseId));
    
    Density=size(Selection,1)/Volume;
    RowId=table; RowId.Specification={'Density'};
    Table=addData2OutputTable(Table,Density,RowId,Mouse);
    
    VolumeSphereRadius=(3/4/3.1415*(Volume/size(Selection,1)))^(1/3);   
    RowId=table; RowId.Specification={'VolumeSphereRadius'};
    Table=addData2OutputTable(Table,VolumeSphereRadius,RowId,Mouse);
end


% OrigTable=Table;
% Table(:,{'MouseId','Id'})=[];
TableExport=Table(:,{'Specification','Percentile','Distance','Value','Data'});
for m=size(TableExport,2)-1:-1:1
    TableExport=sortrows(TableExport,m);
end
Ind=strfind1(TableExport.Specification,'MouseId',1);
TableExport=[TableExport(Ind,:);TableExport(1:Ind-1,:);TableExport(Ind+1:end,:)];
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';
% % % % TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Mouse.');

ExcelFilename=[W.G.T.TaskName{W.Task},'_MicrogliaInfo','.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);
% PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

% ExcelFilename='MicrogliaInfo';
xlsActxWrite(TableExport,Workbook,ExcelFilename,[],'Delete');
Workbook.Save;
Workbook.Close;
% keyboard;
