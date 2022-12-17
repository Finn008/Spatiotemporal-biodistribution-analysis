function vglutClusterAnalysis_PlotDystrophicFractionWithPlaqueSizeAndAge(Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,TimeBinning,TimeMinMax,DistanceMinMax,Path2file)


Table=Table(Table.Time2Treatment_Min>=TimeMinMax(1) & Table.Time2Treatment_Max<=TimeMinMax(2) & Table.Time2Treatment_Bin==TimeBinning...
    & Table.Distance_Min==DistanceMinMax(1) & Table.Distance_Max==DistanceMinMax(2),:);
AxisPlaqueSize=(RadiusMinMax(1):RadiiBinning:RadiusMinMax(2)).';
Fraction=nan((TimeMinMax(2)-TimeMinMax(1))/TimeBinning,size(AxisPlaqueSize,1));
Time2Treatment_Min=unique(Table.Time2Treatment_Min);
TreatmentTypes={'NB360Vehicle';'NB360'};
for Time=1:size(Time2Treatment_Min,1)
    TimeMinID=Time2Treatment_Min(Time);
    Table2=Table(Table.Time2Treatment_Min==TimeMinID,:);
    
    if size(Table2,1)==0; continue; end
    
    for Tr=1:size(TreatmentTypes,1)
        Mice=strcmp(MouseInfo.TreatmentType,TreatmentTypes{Tr}) & ismember(MouseInfo.MouseId,MouseIds);
        Wave1=Table2.Fraction(:,Mice);
% % %         if min(nansum(Wave1,1))==0; continue; end; % exclude completely if timepoint is completely missing in one mouse
%         Data2add=mean(Wave1,2);
        Data2add=nanmean(Wave1,2);
        Data2add(Data2add==0)=NaN;
        % Time vertically (X), plaque size horizontally (Y), TreatmentType (Z)
        [~,Wave1]=ismember(Table2.PlaqueRadius_Min,AxisPlaqueSize);
        Fraction(Time,Wave1,Tr)=Data2add;
    end
end

AxisTime=(TimeMinMax(1)+TimeBinning:TimeBinning:TimeMinMax(2)).'/7;

[Xmesh,Ymesh]=meshgrid(AxisPlaqueSize,AxisTime);
Figure=figure; hold on;
% % % set(Figure,'Units','centimeters','Position',[0,0,8,5.5]);

[X,Y,Z]=surfPlotSeparateLines_2(AxisTime,AxisPlaqueSize,Fraction,'Vertical');
surf(X,Y,Z(:,:,1),'edgecolor','red');
surf(X,Y,Z(:,:,2),'edgecolor','black');

grid off;
box on;
set(gca,'xlim',[0;24]);
set(gca,'XTick',(0:4:40));
set(gca,'ylim',[-4;10]);
set(gca,'YTick',(-4:2:10));
set(gca,'zlim',[0;50]);
set(gca,'ZTick',(0:10:100));
set(gca,'FontSize',9);
set(gca,'LineWidth',0.5);
view(-37,40);

keyboard;
set(Figure,'PaperPositionMode','auto');
Path2file=[W.G.PathOut,'\Vglut Clusters\DystrophicFractionWithPlaqueSizeAndTime\',Title];
print('-dtiff','-r1000',[Path2file,'.tif']);
savefig(gcf,[Path2file,'.fig']);
close Figure 1;

% % % % TableExport=table2array(ExcelTable);
% % % [TableExport]=table2cell_2(ExcelTable);
% % % TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
% % % PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
% % % [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
% % % xlsActxWrite(TableExport,Workbook,'ClDistrDist2Pl',[],'Delete');




