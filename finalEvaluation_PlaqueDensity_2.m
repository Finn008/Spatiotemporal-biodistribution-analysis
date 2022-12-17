function [NewBornPlaqueList]=finalEvaluation_PlaqueDensity_2(MouseInfo,PlaqueListSingle,PlaqueList,MouseInfoTime,TimeBinning)

for Mouse=1:size(MouseInfo,1)
    Wave1=PlaqueListSingle.Time2Treatment(PlaqueListSingle.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.Time2Treatment(Mouse,1:2)=[min(Wave1),max(Wave1)];
end


PlaqueDetectionLimit=4;

PlaqueListSingle.RadiusFit1(PlaqueListSingle.RadiusFit1<PlaqueDetectionLimit)=0;

PlaqueListSingle2=table;
NewBornPlaqueList=PlaqueList(isnan(PlaqueList.PlBirth)==0,:);
for Pl=1:size(NewBornPlaqueList,1)
    try
        Age=NewBornPlaqueList.PlaqueListSingle{Pl,1}.Age(find(NewBornPlaqueList.PlaqueListSingle{Pl,1}.RadiusFit1>4,1));
        NewBornPlaqueList.PlBirth(Pl,1)=Age;
        Ind=size(PlaqueListSingle2,1)+1;
        
        PlaqueListSingle2(Ind,:)=PlaqueListSingle(find(PlaqueListSingle.MouseId==NewBornPlaqueList.MouseId(Pl) & PlaqueListSingle.Pl==NewBornPlaqueList.Pl(Pl) & PlaqueListSingle.Age==Age),:);
    catch
        NewBornPlaqueList.PlBirth(Pl,1)=NaN;
    end
end
NewBornPlaqueList=NewBornPlaqueList(isnan(NewBornPlaqueList.PlBirth)==0,:);


% Binning
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[30.42;14;7];
end
TimeMinMax=[min(PlaqueListSingle.Time2Treatment);max(PlaqueListSingle.Time2Treatment)];
[BinTable]=generateBinTable([],TimeBinning,[],TimeMinMax,MouseInfo(1:18,:));



% Plaque formation with regards to closest plaque distance
[BinTable]=generateBinTable_2(TimeBinning,[],10,TimeMinMax,[],[0;200]);
for Bin=1:size(BinTable,1)
    Selection=PlaqueListSingle2(PlaqueListSingle2.Time2Treatment>BinTable.TimeMin(Bin)...
        & PlaqueListSingle2.Time2Treatment<=BinTable.TimeMax(Bin)...
%         & PlaqueListSingle2.RadiusFit1~=0...
        & PlaqueListSingle2.Distance2ClosestPlaque>BinTable.DistMin(Bin)...
        & PlaqueListSingle2.Distance2ClosestPlaque<=BinTable.DistMax(Bin),:);
    if size(Selection,1)>0
        keyboard;
    end

end


% TableDensity=table;
% TableDensity('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'Data'})={{'MouseId'},NaN,NaN,NaN,MouseInfo.Mouse.'};
% TableDensity.Specification(1)={'MouseId'};TableDensity.Data=MouseInfo.Mouse.';

Table=table;
Table('MouseId',{'Specification';'Distance';'TimeMin';'TimeMax';'TimeBin';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,MouseInfo.MouseId.'};
for Bin=1:size(BinTable,1)
%     MouseId=MouseInfo.Mouse(BinTable.Mouse(Bin));
    OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin'});
    
    Selection=PlaqueListSingle(PlaqueListSingle.MouseId==BinTable.MouseId(Bin)...
        & PlaqueListSingle.Time2Treatment>BinTable.TimeMin(Bin)...
        & PlaqueListSingle.Time2Treatment<=BinTable.TimeMax(Bin)...
        & PlaqueListSingle.RadiusFit1~=0,:);
    
    Selection2=MouseInfoTime(MouseInfoTime.MouseId==BinTable.MouseId(Bin)...
        & MouseInfoTime.Time2Treatment>BinTable.TimeMin(Bin)...
        & MouseInfoTime.Time2Treatment<=BinTable.TimeMax(Bin),:);
    
    if size(Selection2,1)==0
        continue;
    end
    
    Volume=sum(Selection2.TotalVolume)/1000000000; % mm^3
    if Volume==0
        keyboard;
    end
    Volume=size(Selection2,1)*MouseInfo.VolumeMinMeanMax(BinTable.Mouse(Bin),2)/1000000000;
    
    Density=size(Selection,1)/Volume;
    RowId=table; RowId.Specification(:,1)={'Density'}; RowId.Distance(:,1)=NaN; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable_2(Table,Density,RowId,BinTable.Mouse(Bin));
    
    % Formation rate
    Selection3=PlaqueListSingle2(PlaqueListSingle2.MouseId==BinTable.MouseId(Bin)...
        & PlaqueListSingle2.Time2Treatment>BinTable.TimeMin(Bin)...
        & PlaqueListSingle2.Time2Treatment<=BinTable.TimeMax(Bin)...
        & PlaqueListSingle2.RadiusFit1~=0,:);
    
    Min=max(MouseInfo.Time2Treatment(BinTable.Mouse(Bin),1),BinTable.TimeMin(Bin));
    Max=min(MouseInfo.Time2Treatment(BinTable.Mouse(Bin),2),BinTable.TimeMax(Bin));
    Time=(Max-Min)/7;
    PlaqueFormation=size(Selection3,1)/Time/Volume; % new plaques per week and mm^3
    RowId=table; RowId.Specification(:,1)={'Formation'}; RowId.Distance(:,1)=NaN; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable_2(Table,PlaqueFormation,RowId,BinTable.Mouse(Bin));
end



   



ExcelFilename=['PlaqueDensity'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

% TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'TimeMin';'TimeBin';'Specification'});
% xlsActxWrite(TableExport,Workbook,'Density',[],'Delete');
TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'Formation',[],'Delete');

Workbook.Save;
Workbook.Close;