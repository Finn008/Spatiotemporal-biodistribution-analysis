function finalEvaluation_RadiusDistribution(MouseInfo,PlaqueListSingle,MouseInfoTime,RadiiBinning,TimeBinning)

MouseInfo=MouseInfo(ismember(MouseInfo.TreatmentType,{'NB360';'NB360Vehicle'}),:);
TimeMinMax=[min(PlaqueListSingle.Time2Treatment);max(PlaqueListSingle.Time2Treatment)];

[BinTable]=generateBinTable_2(7,[],[],TimeMinMax);

Table=table;
Table('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,NaN,NaN,MouseInfo.MouseId.'};
for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin'});
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId...
            & PlaqueListSingle.Time2Treatment>BinTable.TimeMin(Bin)...
            & PlaqueListSingle.Time2Treatment<=BinTable.TimeMax(Bin)...
            & PlaqueListSingle.RadiusFit1>0 & isnan(PlaqueListSingle.RadiusFit1)==0 & PlaqueListSingle.BorderTouch==0,:);
        MeanRadius=nanmean(Selection.RadiusFit1);
        RowId=table; RowId.Specification(:,1)={'MeanRadius'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,MeanRadius,RowId,Mouse);
    end
end

ExcelFilename=['PlaqueSizeDistribution_2'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'RadMin';'RadBin';'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'Radius',[],'Delete');

% Binning
if exist('RadiiBinning')~=1 || isempty(RadiiBinning)
    RadiiBinning=[1];
end
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[30.42;14];
end
RadiusMinMax=[-0.01;ceil(max(PlaqueListSingle.RadiusFit1))];


[BinTable]=generateBinTable(RadiiBinning,TimeBinning,RadiusMinMax,TimeMinMax,MouseInfo(1:18,:));

for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin','RadMin','RadMax','RadBin'});
    
    Selection=PlaqueListSingle(PlaqueListSingle.MouseId==BinTable.MouseId(Bin)...
        & PlaqueListSingle.Time2Treatment>BinTable.TimeMin(Bin)...
        & PlaqueListSingle.Time2Treatment<=BinTable.TimeMax(Bin)...
        & PlaqueListSingle.RadiusFit1>BinTable.RadMin(Bin)...
        & PlaqueListSingle.RadiusFit1<=BinTable.RadMax(Bin)...
        & PlaqueListSingle.BorderTouch==0,:);
    
    Selection2=MouseInfoTime(MouseInfoTime.MouseId==BinTable.MouseId(Bin)...
        & MouseInfoTime.Time2Treatment>BinTable.TimeMin(Bin)...
        & MouseInfoTime.Time2Treatment<=BinTable.TimeMax(Bin),:);
       
    Volume=sum(Selection2.TotalVolume)/1000000000; % mm^3
    Density=size(Selection,1)/Volume;
    RowId=table; RowId.Specification(:,1)={'Density'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable_2(Table,Density,RowId,BinTable.Mouse(Bin));
end

Wave1=findIntersection_2({'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'Data'},Table.Properties.VariableNames.');
TableExport=Table(:,Wave1);
for m=size(TableExport,2)-1:-1:1
    TableExport=sortrows(TableExport,m);
end
Ind=strfind1(TableExport.Specification,'MouseId',1);
TableExport=[TableExport(Ind,:);TableExport(1:Ind-1,:);TableExport(Ind+1:end,:)];


[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';


xlsActxWrite(TableExport,Workbook,'Radius',[],'Delete');
Workbook.Save;
Workbook.Close;