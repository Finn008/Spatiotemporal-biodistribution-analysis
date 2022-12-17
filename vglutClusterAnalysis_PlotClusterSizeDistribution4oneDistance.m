function vglutClusterAnalysis_PlotClusterSizeDistribution4oneDistance(Title,Table,MouseInfo,MouseIds,TimeBinning,TimeMinMax,ClusterSizeBinning,Path2file)


Table=Table(Table.Time2Treatment_Min>=TimeMinMax(1) & Table.Time2Treatment_Max<=TimeMinMax(2),:); %  & Table.Time2Treatment_Bin==TimeBinning

ExcelTable=table;
ClusterSizes=unique(Table.Dystrophies2Radius_Min);
AxisClusterSize=(1:1:max(ClusterSizes(:))).'/10;
Fraction=nan((TimeMinMax(2)-TimeMinMax(1))/TimeBinning,max(ClusterSizes(:)));
Time2Treatment_Min=unique(Table.Time2Treatment_Min);
TreatmentTypes={'Control';'NB360Vehicle';'NB360'};
for Time=1:size(Time2Treatment_Min,1)
    TimeMinID=Time2Treatment_Min(Time);
    Table2=Table(Table.Time2Treatment_Min==TimeMinID,:);
    Data2add=table;
    Data2add.Time2Treatment_Min(1:max(ClusterSizes),1)=Table2.Time2Treatment_Min(1);
    Data2add.Time2Treatment_Max(:,1)=Table2.Time2Treatment_Max(1);
    Data2add.ClusterSize=AxisClusterSize;
    Data2add.Fraction(Table2.Dystrophies2Radius_Min,1:size(Table2.Fraction,2))=Table2.Fraction;
    Data2add.Fraction(isnan(Data2add.Fraction))=0;
    Data2add.Fraction=cumsum(Data2add.Fraction,1);
    Data2add.Fraction=Data2add.Fraction./repmat(Data2add.Fraction(end,:),[size(Data2add,1),1])*100; % turn off if no normalization
    ExcelTable=[ExcelTable;Data2add];
    
    if size(Table2,1)==0; continue; end
    
    for Tr=1:size(TreatmentTypes,1)
        Mice=strcmp(MouseInfo.TreatmentType,TreatmentTypes{Tr}) & ismember(MouseInfo.MouseId,MouseIds);
        Wave1=Data2add.Fraction(:,Mice);
        if min(nansum(Wave1,1))==0; continue; end; % exclude completely if timepoint is completely missing in one mouse
        Wave1=nansum(Wave1,2)/sum(Mice(:));
        %%%% Wave1=nanmean(Wave1,2); 
        
        % Time vertically (X), Clusters horizontally (Y), TreatmentType (Z)
        Fraction(Time,:,Tr)=Wave1;
    end
end
AxisTime=(TimeMinMax(1)+TimeBinning/2:TimeBinning:TimeMinMax(2)-TimeBinning/2).'/7;
[Xmesh,Ymesh]=meshgrid(AxisClusterSize,AxisTime);
Figure=figure; hold on;
% % % set(Figure,'Units','centimeters','Position',[0,0,8,5.5]);

[X,Y,Z]=surfPlotSeparateLines_2(AxisTime,AxisClusterSize,Fraction,'Horizontal');
surf(X,Y,Z(:,:,1),'edgecolor','cyan');
surf(X,Y,Z(:,:,2),'edgecolor','black');
surf(X,Y,Z(:,:,3),'edgecolor','red');

grid off;
box on;
set(gca,'xlim',[0.4;1]);
set(gca,'XTick',(0.4:0.2:1));
set(gca,'ylim',[-4;10]);
set(gca,'YTick',(-4:2:10));
set(gca,'zlim',[0;100]);
set(gca,'ZTick',(0:20:100));
set(gca,'FontSize',9);
set(gca,'LineWidth',0.5);
view(-37,40);

% details
set(gca,'xlim',[1;3]);
set(gca,'XTick',(1:0.5:3));
set(gca,'ylim',[-4;10]);
set(gca,'YTick',(-4:2:10));
set(gca,'zlim',[94;100]);
set(gca,'ZTick',(94:1:100));


set(Figure,'PaperPositionMode','auto');
Path2file=[W.G.PathOut,'\Vglut Clusters\ClusterDistributionDistantFromPlaque\',Title];
print('-dtiff','-r1000',[Path2file,'.tif']);
savefig(gcf,[Path2file,'.fig']);
close Figure 1;

% TableExport=table2array(ExcelTable);
[TableExport]=table2cell_2(ExcelTable);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'ClDistrDist2Pl',[],'Delete');





