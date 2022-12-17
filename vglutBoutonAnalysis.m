function vglutBoutonAnalysis(PlaqueListSingle,VglutArray1,BoutonList2,PlaqueArray1,MouseInfo,Version)

RelationshipIDs=[1;2;3];
TimeMinMax=[min(VglutArray1.Time2Treatment);max(VglutArray1.Time2Treatment)];

VglutArray1=VglutArray1(ismember(VglutArray1.Relationship,RelationshipIDs),:);
VglutArray1(:,{'Relationship'})=[];
VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray1(:,{'VolumeUm3'}),@nansum,[],'Sparse');


% A1=BoutonList2(1:100,:);
BoutonList2=BoutonList2(ismember(BoutonList2.Relationship,RelationshipIDs),:);
BoutonList2(:,{'Relationship'})=[];
BoutonList2=BoutonList2(BoutonList2.DistInMax>=3 & BoutonList2.DistInMax<=7,:);
BoutonList2.Distance=int16(BoutonList2.Distance)-50;
Version='Normal';
if strcmp(Version,'Normal');
    BinInfo={'MouseId',0,0,0;
        'Time2Treatment',-2,0,[48;70];
        'PlaqueRadius',[2],[0;999],0
        'Distance',[1],[-20;51],0;
        };
end
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;


% VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray1(:,{'Fraction'}),@nansum,[],'Sparse');
% VglutArray1=fuseTable_MatchingColums_2(VglutArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});
BoutonList2Sel=BoutonList2(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance';});

BoutonList2Sel=fuseTable_MatchingColums_2(BoutonList2Sel,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});

[Table]=accumArrayBinning(BoutonList2Sel,BinInfo,[],[],@sum);


'VolumeUm3'    'MouseId'    'Time2Treatment'    'RoiId'    'PlId'    'Distance'




[Volume]=accumArrayBinning(BoutonList2Sel,BinInfo,[],[],@sum);

Table=fuseTable_MatchingColums_2(Table,VglutArray1,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});


% VglutArray1=VglutArray1(ismember(VglutArray1.Relationship,RelationshipIDs),:);
% VglutArray1(:,{'Relationship'})=[];
% VglutArray1=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'}),VglutArray1(:,{'VolumeUm3'}),@nansum,[],'Sparse');


Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);

[CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(BoutonList2.RadiusHWI,(0:1:200).');
plot(mean(Ranges,2),Histogram);

[CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(BoutonList2.VglutGreenHWI*2,(0:100:40000).');
plot(mean(Ranges,2),Histogram);




%% calculate total bouton densities
BoutonList2(:,{'DistInMax';'Distance'})=[];
BoutonList2(:,{'AreaXYHWI';'VglutGreenHWI';'Radius'})=[];


TotalBoutonDensity=accumarray_8(BoutonList2(:,{'MouseId';'Time2Treatment'}),[],@nansum,[],'Sparse');
TotalVolume=accumarray_8(VglutArray1(:,{'MouseId';'Time2Treatment'}),VglutArray1(:,{'VolumeUm3'}),@nansum,[],'Sparse');

TotalBoutonDensity=fuseTable_MatchingColums_2(TotalBoutonDensity,TotalVolume,{'MouseId';'Time2Treatment'},{'VolumeUm3'});
TotalBoutonDensity.Density=TotalBoutonDensity.Count./TotalBoutonDensity.VolumeUm3;
TotalBoutonDensity(:,{'Count';'VolumeUm3'})=[];

if strcmp(Version,'TotalBoutonDensity')
    BinInfo={'MouseId',0,0,0; % no binning
        'Time2Treatment',[7;14;28],[-28;70],0;
        };
end
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;

[Table]=accumArrayBinning(TotalBoutonDensity,BinInfo,'Density');

Table=distributeColumnHorizontally_4(Table,[],'MouseId','Density',MouseInfo.MouseId);




if strcmp(Version,'TotalBoutonDensity')
    [TableExport]=table2cell_2(Table);
    TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
    PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
    xlsActxWrite(TableExport,Workbook,'TotalBoutonDensity',[],'Delete');
end