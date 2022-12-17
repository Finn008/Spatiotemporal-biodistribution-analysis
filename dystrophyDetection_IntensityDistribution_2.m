function dystrophyDetection_IntensityDistribution_2(MouseInfo,SingleStacks)
global W;
TableExport=table;
DataTypes=SingleStacks.IntDistribution{1}.Properties.VariableNames.';
DataTypes(strfind1(DataTypes,'Percentile'),:)=[];
Percentile=(1:0.5:100).';
DataArray=table;
for Row=1:size(SingleStacks,1)
    Wave1=SingleStacks.IntDistribution{Row};
    Wave1(:,{'MouseId';'RoiId';'TreatmentType'})=repmat(SingleStacks(Row,{'MouseId';'RoiId';'TreatmentType'}),[size(Wave1,1),1]);
    DataArray=[DataArray;Wave1];
end

DataArray2=accumarray_9(DataArray(:,{'MouseId';'Percentile'}),DataArray(:,DataTypes.'),@nanmean);
for Ch=1:size(DataTypes,1)
    Table1=distributeColumnHorizontally_4(DataArray2(:,{'Percentile','MouseId',DataTypes{Ch}}),[],'MouseId',DataTypes{Ch},MouseInfo.MouseId,'Data');
    Table1.Specification(:,1)={'MeanIntensity'};
    Table1.DataType(:,1)=DataTypes(Ch);
    TableExport(end+1:end+size(Table1,1),Table1.Properties.VariableNames)=Table1;
end

% convert X to Y Percentile


OutputFilename=[W.G.T.TaskName{W.Task},'_IntensityDistribution'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
Wave1=findIntersection_2({'Specification';'DataType';'RoiId';'Percentile';'Data'},TableExport.Properties.VariableNames.');
TableExport=TableExport(:,Wave1);
[TableExport]=table2cell_2(TableExport);

TableExport=[TableExport(1,:);TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);

keyboard;
xlsActxWrite(TableExport,Workbook,'IntensityDistribution',[],'Delete');
xlsActxWrite(MouseInfo,Workbook,'MouseInfo',[],'Delete');
Workbook.Save;
Workbook.Close;