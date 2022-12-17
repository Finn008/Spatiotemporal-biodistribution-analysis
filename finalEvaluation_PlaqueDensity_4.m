function [NewBornPlaqueList]=finalEvaluation_PlaqueDensity_4(MouseInfo,PlaqueListSingle,PlaqueList,MouseInfoTime,PlaqueHistograms,TimeBinning)

MouseInfo=MouseInfo(ismember(MouseInfo.TreatmentType,{'NB360';'NB360Vehicle'}),:);
for Mouse=1:size(MouseInfo,1)
    Wave1=PlaqueListSingle.Time2Treatment(PlaqueListSingle.MouseId==MouseInfo.MouseId(Mouse));
    MouseInfo.Time2Treatment(Mouse,1:2)=[min(Wave1),max(Wave1)];
end
% calculate real volume at each distance
Wave1=accumarray_8(PlaqueHistograms(:,{'MouseId';'Time2Treatment';'Distance'}),PlaqueHistograms(:,'VolumeRealUm3'),@sum,[],'Sparse');
Wave1=distributeColumnHorizontally_2(Wave1,{'MouseId';'Time2Treatment'},'Distance','VolumeRealUm3',[0;255]);
MouseInfoTime=fuseTable_MatchingColums(MouseInfoTime,Wave1,{'MouseId';'Time2Treatment'});
MouseInfoTime.Properties.VariableNames{end}='VolumeRealPerDistance';
% return;
PlaqueDetectionLimit=4;

PlaqueListSingle.RadiusFit1(PlaqueListSingle.RadiusFit1<PlaqueDetectionLimit)=0;

PlaqueListSingle2=table;
NewBornPlaqueList=PlaqueList(isnan(PlaqueList.PlBirth)==0,:);
for Pl=1:size(NewBornPlaqueList,1)
    try
        Age=NewBornPlaqueList.PlaqueListSingle{Pl,1}.Age(find(NewBornPlaqueList.PlaqueListSingle{Pl,1}.RadiusFit1>4,1));
        NewBornPlaqueList.PlBirth(Pl,1)=Age;
        Ind=size(PlaqueListSingle2,1)+1;
        
        PlaqueListSingle2(Ind,:)=PlaqueListSingle(find(PlaqueListSingle.MouseId==NewBornPlaqueList.MouseId(Pl) & PlaqueListSingle.PlId==NewBornPlaqueList.PlId(Pl) & PlaqueListSingle.Age==Age),:);
    catch
        NewBornPlaqueList.PlBirth(Pl,1)=NaN;
    end
end
NewBornPlaqueList=NewBornPlaqueList(isnan(NewBornPlaqueList.PlBirth)==0,:);
% return;
TimeMinMax=[min(PlaqueListSingle.Time2Treatment);max(PlaqueListSingle.Time2Treatment)];
% plaque formation in regards to plaque distance

% MiceIds={[314;336;341;353;375];[318;331;346;347;371]};
MiceIds=[num2cell(MouseInfo.MouseId);{[314;336;341;353;375];[279;318;346;347;371]}];
TableFormation=table;
TableFormation('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'DistMin';'DistMax';'DistBin';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,NaN,NaN,[MouseInfo.MouseId.',1,2]};

% Plaque formation with regards to closest plaque distance
[BinTable]=generateBinTable_2([7;28;56],[],[999;20;10],[-28;56],[],[0;160]);
for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin','DistMin','DistMax','DistBin'});
    for MiceGroup=1:size(MiceIds,1)
        Selection=PlaqueListSingle2(PlaqueListSingle2.Time2Treatment>BinTable.TimeMin(Bin)...
            & PlaqueListSingle2.Time2Treatment<=BinTable.TimeMax(Bin)...
            & PlaqueListSingle2.Distance2ClosestPlaque>BinTable.DistMin(Bin)...
            & PlaqueListSingle2.Distance2ClosestPlaque<=BinTable.DistMax(Bin)...
            & ismember(PlaqueListSingle2.MouseId,MiceIds{MiceGroup})...
            & PlaqueListSingle2.RadiusFit1~=0,:);
            
        if size(Selection,1)>0
            MouseInfoTimeSel=MouseInfoTime(MouseInfoTime.Time2Treatment>BinTable.TimeMin(Bin)...
                & MouseInfoTime.Time2Treatment<=BinTable.TimeMax(Bin)...
                & ismember(MouseInfoTime.MouseId,MiceIds{MiceGroup}),:);
            % each Mouse counted only once
            Volume=[];
            for MouseId=unique(MouseInfoTimeSel.MouseId).'
                Volume=[Volume;nanmean(MouseInfoTimeSel.VolumeRealPerDistance,1)];
            end
%             if BinTable.DistMin(Bin)==150 && BinTable.DistMax(Bin)==160
%                 keyboard;
%             end
            DistIds=(BinTable.DistMin(Bin):min([BinTable.DistMax(Bin);206])).'+50;
            Volume=Volume(:,DistIds);
            Volume=nansum(Volume(:))/1000000000;
            if Volume==0
                keyboard;
            end
            Time=BinTable.TimeBin(Bin)/7;
            PlaqueFormation=size(Selection,1)/Time/Volume; % new plaques per week and mm^3
            RowId=table; RowId.Specification(:,1)={'Formation'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
            TableFormation=addData2OutputTable_2(TableFormation,PlaqueFormation,RowId,MiceGroup);
        end
    end
end

ExcelFilename=['PlaqueDensity_3'];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',ExcelFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
TableExport=addData2OutputTable_2(TableFormation,struct(),table([MouseInfo.TreatmentType;{'Vehicle';'NB360'}],'VariableNames',{'TreatmentType'}),{'DistMin';'DistBin';'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'FormationVsDistance',[],'Delete');


% % % PlaqueListSingle2Veh=PlaqueListSingle2(ismember(PlaqueListSingle2.MouseId,MiceIds{1}),:);
% % % PlaqueListSingle2NB360=PlaqueListSingle2(ismember(PlaqueListSingle2.MouseId,MiceIds{2}),:);
% % % PlaqueListSingle2NB360After=PlaqueListSingle2(ismember(PlaqueListSingle2.MouseId,MiceIds{2}) & PlaqueListSingle2.Time2Treatment>14,:);
% % % 
% % % [CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(PlaqueListSingle2NB360After.Distance2ClosestPlaque,(0:5:200).');
% % % figure; plot(mean(Ranges,2),Histogram);    



keyboard; % redo density




% Binning
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[30.42;14;7];
end

[BinTable]=generateBinTable([],TimeBinning,[],TimeMinMax,MouseInfo(1:18,:));

Table=table;
Table('MouseId',{'Specification';'TimeMin';'TimeMax';'TimeBin';'Data'})={{'MouseId'},NaN,NaN,NaN,NaN,NaN,NaN,MouseInfo.MouseId.'};

for Bin=1:size(BinTable,1)
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
    
    Volume=size(Selection2,1)*MouseInfo.VolumeMinMeanMax(BinTable.Mouse(Bin),2)/1000000000;
    keyboard; % why size(Selection2,1)?, volume should be counted only once
    Volume=MouseInfo.VolumeMinMeanMax(BinTable.Mouse(Bin),2)/1000000000;
    
    Density=size(Selection,1)/Volume;
    RowId=table; RowId.Specification(:,1)={'Density'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
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
    RowId=table; RowId.Specification(:,1)={'Formation'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable_2(Table,PlaqueFormation,RowId,BinTable.Mouse(Bin));
end

TableExport=addData2OutputTable_2(Table,struct(),MouseInfo,{'TimeMin';'TimeBin';'Specification'});
xlsActxWrite(TableExport,Workbook,'Formation',[],'Delete');

Workbook.Save;
Workbook.Close;