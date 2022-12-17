% BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueList,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2
% function [PlaqueHistograms,VglutArray1,VglutArray2,BoutonList2,PlaqueListSingle,PlaqueArray1]=redistributeTime2Treatment_3(PlaqueHistograms,VglutArray1,VglutArray2,BoutonList2,PlaqueListSingle,PlaqueArray1,MouseInfo)
function [BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2]=redistributeTime2Treatment_4(MouseInfo,BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2)
global XaxisType;
PathExcelExport=getPathRaw('RedistributeTime2Treatment.xlsx');

% PathExcelExport=['\\GNP90N\share\Finn\Raw data\RedistributeTime2Treatment.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

XaxisType='Age'; %'TimeTo'
if strcmp(XaxisType,'Age')
    AgeAdjustments=xlsActxGet(Workbook,'AgeAdjustments',1);
    AgeAdjustments(AgeAdjustments.Difference==0,:)=[];
    AgeAdjustments=AgeAdjustments(:,{'MouseId';'Original';'Target'});
end
%%
if strcmp(XaxisType,'TimeTo')
    keyboard; % compensate for changes in CaseOutliars
    AdaptTime2Treatment=[275,-7,-8];
    AdaptTime2Treatment(end+1,1:3)=[275,31,27];
    AdaptTime2Treatment(end+1,1:3)=[279,-7,-8];
    AdaptTime2Treatment(end+1,1:3)=[280,42,41];
    AdaptTime2Treatment(end+1,1:3)=[307,-28,-29];
    AdaptTime2Treatment(end+1,1:3)=[314,6,8];
    AdaptTime2Treatment(end+1,1:3)=[314,13,15];
    AdaptTime2Treatment(end+1,1:3)=[314,20,22];
    AdaptTime2Treatment(end+1,1:3)=[318,0,-1]; %
    AdaptTime2Treatment(end+1,1:3)=[331,6,7];
    AdaptTime2Treatment(end+1,1:3)=[331,34,35];
    AdaptTime2Treatment(end+1,1:3)=[336,6,7];
    AdaptTime2Treatment(end+1,1:3)=[336,20,21];
    AdaptTime2Treatment(end+1,1:3)=[341,35,34];
    AdaptTime2Treatment(end+1,1:3)=[341,49,48];
    AdaptTime2Treatment(end+1,1:3)=[347,0,-1];
    AdaptTime2Treatment(end+1,1:3)=[347,35,34]; %
    AdaptTime2Treatment(end+1,1:3)=[347,63,61];
    AdaptTime2Treatment(end+1,1:3)=[349,0,-1];
    AdaptTime2Treatment(end+1,1:3)=[349,42,41];
    AdaptTime2Treatment(end+1,1:3)=[352,0,-1];
    AdaptTime2Treatment(end+1,1:3)=[371,0,-1];
    AdaptTime2Treatment(end+1,1:3)=[371,14,13];
    AdaptTime2Treatment(end+1,1:3)=[371,21,20];
    AdaptTime2Treatment(end+1,1:3)=[371,49,48];
    AdaptTime2Treatment(end+1,1:3)=[375,0,-1];
    AdaptTime2Treatment(end+1,1:3)=[375,14,13];
    AdaptTime2Treatment(end+1,1:3)=[375,27,28];
    AdaptTime2Treatment(end+1,1:3)=[375,62,63];
    
    AdaptTime2Treatment(end+1,1:3)=[481,-1,0];
    AdaptTime2Treatment(end+1,1:3)=[481,6,7];
    AdaptTime2Treatment(end+1,1:3)=[481,13,14];
    AdaptTime2Treatment(end+1,1:3)=[483,-1,0];
    AdaptTime2Treatment(end+1,1:3)=[483,6,7];
    AdaptTime2Treatment(end+1,1:3)=[483,13,14];
    AdaptTime2Treatment=array2table(AdaptTime2Treatment,'VariableNames',{'MouseId';'Original';'Target'});
end
%%
if exist('AgeAdjustments','Var')==1
    
    
    for Row=1:size(AgeAdjustments,1)
        % BoutonList2,MouseInfoTime,PlaqueArray1,PlaqueHistograms,PlaqueListSingle,SingleStacks,VglutArray1,VglutArray2
%         BoutonList2.Time2Treatment(BoutonList2.MouseId==AgeAdjustments.MouseId(Row) & BoutonList2.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
%         PlaqueArray1.Time2Treatment(PlaqueArray1.MouseId==AgeAdjustments.MouseId(Row) & PlaqueArray1.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
%         PlaqueListSingle.Time2Treatment(PlaqueListSingle.MouseId==AgeAdjustments.MouseId(Row) & PlaqueListSingle.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
%         PlaqueHistograms.Time2Treatment(PlaqueHistograms.MouseId==AgeAdjustments.MouseId(Row) & PlaqueHistograms.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
%         PlaqueHistograms.Time2Treatment(PlaqueHistograms.MouseId==AgeAdjustments.MouseId(Row) & PlaqueHistograms{:,XaxisType}==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
        BoutonList2{BoutonList2.MouseId==AgeAdjustments.MouseId(Row) & BoutonList2{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        MouseInfoTime{MouseInfoTime.MouseId==AgeAdjustments.MouseId(Row) & MouseInfoTime{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        PlaqueArray1{PlaqueArray1.MouseId==AgeAdjustments.MouseId(Row) & PlaqueArray1{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        PlaqueHistograms{PlaqueHistograms.MouseId==AgeAdjustments.MouseId(Row) & PlaqueHistograms{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        PlaqueListSingle{PlaqueListSingle.MouseId==AgeAdjustments.MouseId(Row) & PlaqueListSingle{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        SingleStacks{SingleStacks.MouseId==AgeAdjustments.MouseId(Row) & SingleStacks{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        VglutArray1{VglutArray1.MouseId==AgeAdjustments.MouseId(Row) & VglutArray1{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
        VglutArray2{VglutArray2.MouseId==AgeAdjustments.MouseId(Row) & VglutArray2{:,XaxisType}==AgeAdjustments.Original(Row),XaxisType}=AgeAdjustments.Target(Row);
%         VglutArray1.Time2Treatment(VglutArray1.MouseId==AgeAdjustments.MouseId(Row) & VglutArray1.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
%         VglutArray2.Time2Treatment(VglutArray2.MouseId==AgeAdjustments.MouseId(Row) & VglutArray2.Time2Treatment==AgeAdjustments.Original(Row))=AgeAdjustments.Target(Row);
        
        
        
    end
end
%%

BinInfo={'MouseId',0,0,0;
    'RoiId',0,0,0;
    'Age',[7],[60;270],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
Table=accumarray_9(PlaqueHistograms(:,{'MouseId';'RoiId';'Age';}),[],@sum);
Table.Calc(:,1)=1;

[Table2]=accumArrayBinning(Table,BinInfo,'Calc',[],@sum);
AgeMin=unique(Table2.Age_Min);
Table2=distributeColumnHorizontally_4(Table2(:,{'MouseId';'RoiId';'Age_Min';'Calc'}),[],'Age_Min','Calc',AgeMin);
Table2.TreatmentType=MouseInfo.TreatmentType(ismember2(Table2.MouseId,MouseInfo.MouseId),1);
Table2=sortrows(Table2,{'TreatmentType';'MouseId';'RoiId'});
Table2=Table2(:,{'MouseId','RoiId','TreatmentType','Calc'});

for Row=1:size(Table2,1)
    for Col=1:size(Table2.Calc,2)
        Ind=find(Table.MouseId==Table2.MouseId(Row) & Table.RoiId==Table2.RoiId(Row) & Table.Age>=AgeMin(Col) & Table.Age<AgeMin(Col)+7);
        Table2.Timepoints(Row,Col)={num2str(Table.Age(Ind).')};
    end
end

[TableExport]=table2cell_2(Table2);
TableExport=[repmat(TableExport(1,:),[2,1]);TableExport];
TableExport(1,end-2*size(AgeMin,1)+1:end)=num2cell(repmat(AgeMin.',[1,2]));
TableExport(2,end-2*size(AgeMin,1)+1:end)=num2cell(repmat(AgeMin.'+7,[1,2]));
TableExport(3,end-2*size(AgeMin,1)+1:end)=num2cell(repmat(AgeMin.'/30.42,[1,2]));

xlsActxWrite(TableExport,Workbook,'AgeDistribution',[],'Delete');
Wave1=accumarray_9(PlaqueHistograms(:,{'MouseId';'Age';}),[],@sum);

xlsActxWrite(Wave1,Workbook,'Ages',[],'Delete');
Workbook.Save;
Workbook.Close;

