function [PlaqueHistograms,VglutArray1,VglutArray2,BoutonList2,PlaqueListSingle,PlaqueArray1]=redistributeTime2Treatment(PlaqueHistograms,VglutArray1,VglutArray2,BoutonList2,PlaqueListSingle,PlaqueArray1)

keyboard; % compensate for changes in CaseOutliars

XaxisType='Age'; %'TimeTo'
if strcmp(XaxisType,'Age')
    keyboard;
elseif strcmp(XaxisType,'TimeTo')
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
    
end
AdaptTime2Treatment=array2table(AdaptTime2Treatment,'VariableNames',{'MouseId';'Original';'Target'});

for Row=1:size(AdaptTime2Treatment,1)
    VglutArray2.Time2Treatment(VglutArray2.MouseId==AdaptTime2Treatment.MouseId(Row) & VglutArray2.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
    VglutArray1.Time2Treatment(VglutArray1.MouseId==AdaptTime2Treatment.MouseId(Row) & VglutArray1.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
    BoutonList2.Time2Treatment(BoutonList2.MouseId==AdaptTime2Treatment.MouseId(Row) & BoutonList2.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
    PlaqueHistograms.Time2Treatment(PlaqueHistograms.MouseId==AdaptTime2Treatment.MouseId(Row) & PlaqueHistograms.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
    PlaqueListSingle.Time2Treatment(PlaqueListSingle.MouseId==AdaptTime2Treatment.MouseId(Row) & PlaqueListSingle.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
    PlaqueArray1.Time2Treatment(PlaqueArray1.MouseId==AdaptTime2Treatment.MouseId(Row) & PlaqueArray1.Time2Treatment==AdaptTime2Treatment.Original(Row))=AdaptTime2Treatment.Target(Row);
end
RedistributeTime2Treatment=0;
if RedistributeTime2Treatment==1
    BinInfo={'MouseId',0,0,0; % no binning
        'Time2Treatment',[7],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
    retrieveDataPerBin(PlaqueHistograms,BinInfo,'Time2Treatment');
end