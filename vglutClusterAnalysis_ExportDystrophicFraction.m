function vglutClusterAnalysis_ExportDystrophicFraction(Table,MouseInfo)


Table(Table.Dystrophies2Radius_Min<=9,:)=[];
% VglutArray1.Fraction=VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100;
% Wave1=accumarray_8(Table(:,{'Time2Treatment_Min';'PlaqueRadius_Min';'Distance_Min'}),VglutArray1(:,{'Fraction'}),@nansum,[],'Sparse');
% VglutArray1=fuseTable_MatchingColums_2(VglutArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});
% VglutArray1(:,{'RoiId';'PlId'})=[];
% [Table]=accumArrayBinning(VglutArray1,BinInfo,'Fraction');



TableExport=table;
PlaqueRadii=(0:2:24).';
PlaqueRadii=unique(Table{:,{'PlaqueRadius_Min';'PlaqueRadius_Max'}},'rows');
TimeRanges=unique(Table{:,{'Time2Treatment_Min';'Time2Treatment_Max'}},'rows');
for Time=1:size(TimeRanges,1)
    for Radius=1:size(PlaqueRadii,1)
%         Ind=size(TableExport,1)+1;
        Selection=Table(Table.Time2Treatment_Min==TimeRanges(Time,1) & Table.Time2Treatment_Max==TimeRanges(Time,2) & Table.PlaqueRadius_Min==PlaqueRadii(Radius,1) & Table.PlaqueRadius_Max==PlaqueRadii(Radius,2),:);
        if size(Selection,1)==0; continue; end;
        TableExport(size(TableExport,1)+1,:)=Selection(1,:);
        
        Distances=(1).';
        Fraction=nan(size(Distances,1),size(Table.Fraction,2));
        for Distance=1:size(Distances,1)
%             Selection=Table(Table.Time2Treatment_Min==TimeRanges(Time,1) & Table.Time2Treatment_Max==TimeRanges(Time,2) & Table.PlaqueRadius_Min==PlaqueRadii(Radius,1) & Table.PlaqueRadius_Max==PlaqueRadii(Radius,2) & Table.Distance_Min==1,:);
            Selection=Table(Table.Time2Treatment_Min==TimeRanges(Time,1) & Table.Time2Treatment_Max==TimeRanges(Time,2) & Table.PlaqueRadius_Min==PlaqueRadii(Radius,1) & Table.PlaqueRadius_Max==PlaqueRadii(Radius,2) & Table.Distance_Min==Distance,:);
            if size(Selection,1)==0; continue; end;
            Wave1=nansum(Selection.Fraction,1);
            NanCols=min(isnan(Selection.Fraction),[],1);
            Wave1(NanCols)=NaN;
            Fraction(Distance,:)=Wave1;
        end
        
        
        
        Wave1=max(Fraction,[],1);
        TableExport.Fraction(end,:)=Wave1;
        
    end
end
% TableExport.Fraction(TableExport.Fraction==0)=NaN;
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'DysrophicFraction2',[],'Delete');