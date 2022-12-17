function vglutClusterAnalysis(PlaqueListSingle,VglutArray1,VglutArray2,VglutArray3,MouseInfo)

% plot fraction of each cluster size with regards to plaque distance

% Wave1=accumarray_7(PlaqueListSingle(:,{'MouseId';'Time2Treatment';'RoiId';'PlId'}),[],@sum,[],'Sparse');

Wave1=fuseTable_MatchingColums_2(VglutArray2,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'});
VglutArray2.PlaqueRadius=Wave1.RadiusFit1;

TimeMinMax=[min(VglutArray1.Time2Treatment);max(VglutArray1.Time2Treatment)];
BinInfo={   'Time',7,TimeMinMax;
            'Rad',999,[0;999];
            'Dist',1,[30;100];
            'Dia',0,[0,5;5,10;10,15;15,20;20,999]};
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax'});

[BinTable,Table]=generateBinTable_3(BinInfo,MouseInfo);

for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,:);
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        
        Selection=VglutArray2(VglutArray2.MouseId==MouseId...
            & VglutArray2.Time2Treatment>BinTable.TimeMin(Bin)...
            & VglutArray2.Time2Treatment<=BinTable.TimeMax(Bin)...
            & VglutArray2.PlaqueRadius>BinTable.RadMin(Bin)...
            & VglutArray2.PlaqueRadius<=BinTable.RadMax(Bin)...
            & VglutArray2.Distance>BinTable.DistMin(Bin)...
            & VglutArray2.Distance<=BinTable.DistMax(Bin)...
            & VglutArray2.Dystrophies2Radius>BinTable.DiaMin(Bin)...
            & VglutArray2.Dystrophies2Radius<=BinTable.DiaMax(Bin)...
            ,:);
        if size(Selection,1)==0; continue; end;
        MeanRadius=nanmean(Selection.RadiusFit1);
        RowId=table; RowId.Specification(:,1)={'MeanRadius'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable_2(Table,MeanRadius,RowId,Mouse);
    end
end

keyboard;            
            
ExcelFilename=['PlaqueSizeDistribution_2'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'RadMin';'RadBin';'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'Radius',[],'Delete');






return;

VglutArray1Sel=VglutArray1(ismember(VglutArray1.Relationship,[1;2;3;4;5]),:);
VglutArray2Sel=VglutArray2(ismember(VglutArray2.Relationship,[1;2;3;4;5]),:);

keyboard; % what to do with RoiIds 1.1 etc.? or why is there none of them?
VglutArray1Sel.RoiId=floor(VglutArray1Sel.RoiId);
VglutArray2Sel.RoiId=floor(VglutArray2Sel.RoiId);

Volume4DistBins=accumarray_4(VglutArray1Sel(:,{'MouseId';'RoiId';'PlId';'Time';'Distance'}),VglutArray1Sel(:,{'VolumeUm3'}),@sum,[],'Sparse');
Volume4DistBins=sortrows_2(Volume4DistBins);


[CumSum,Histogram,Ranges]=cumSumGenerator(VglutArray2Sel.Volume); figure; plot(mean(Ranges,2),Histogram);

BinTable=accumarray_8(VglutArray2Sel(:,{'MouseId';'RoiId';'PlId';'Time';'Distance';'Volume'}),VglutArray1Sel(:,{'VolumeUm3'}),@sum,[],'Sparse');

BinTable=finalEvaluation_Distance4PlaqueListSingle(PlaqueListSingle,VglutArray1,'VolumeUm3',[1;2;3;4;5],[50;100]);

Output=dataBinning(BinTable,BinningInfo);