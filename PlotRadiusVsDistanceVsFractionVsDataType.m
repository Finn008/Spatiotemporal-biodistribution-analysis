function PlotRadiusVsDistanceVsFractionVsDataType(DataTypes,Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file)

% % Table=Table(Table.Time2Treatment_Min==TimeMinMax(1)...
% %     & Table.Time2Treatment_Max==TimeMinMax(2)...
% %     & Table.Time2Treatment_Bin==TimeBinning...
% %     & Table.Distance_Min>=DistanceMinMax(1)...
% %     & Table.Distance_Max<=DistanceMinMax(2)...
% %     & Table.PlaqueRadius_Bin==RadiiBinning...
% %     ,:);

for DataType=1:size(DataTypes,1)
    Tables{DataType,1}=distributeColumnHorizontally_4(Table,{'Time2Treatment_Min';'Time2Treatment_Max';'Time2Treatment_Bin';'PlaqueRadius_Min';'PlaqueRadius_Max';'PlaqueRadius_Bin';'Distance_Min';'Distance_Max';'Distance_Bin'},'MouseId',DataTypes{DataType},MouseInfo.MouseId);
end



Distances=(DistanceMinMax(1):1:DistanceMinMax(2)).';
PlaqueRadii=(RadiusMinMax(1):RadiiBinning:RadiusMinMax(2)-RadiiBinning).'; PlaqueRadii(:,2)=PlaqueRadii+RadiiBinning;
Array=nan(size(Distances,1),size(PlaqueRadii,1),size(DataTypes,1));
% X=(1:(DistanceMinMax(2)-DistanceMinMax(1)+1)).'; % 21 beeing DistanceBin 1 µm (DistanceMinMax(1))
ExcelTable=table;
ExcelTable('MouseId',{'Specification';'PlRad';'Data'})={{'MouseId'},NaN,MouseInfo.MouseId.'};

for Tr=1:size(MouseIds,1)
    for PlRad=1:size(PlaqueRadii,1)
        [~,Mice]=ismember(MouseIds{Tr},MouseInfo.MouseId);
        
        for DataType=1:size(DataTypes,1)
            Table=Tables{DataType};
            Selection=Table(Table.PlaqueRadius_Min==PlaqueRadii(PlRad,1)...
                & Table.PlaqueRadius_Max==PlaqueRadii(PlRad,2)...
                ,:);
            Data2add=Selection{:,DataTypes{DataType}}(:,Mice);
            MeanData=nanmean(Data2add,2);
            Nans=sum(isnan(Data2add),2)==size(Data2add,2); % find all NaN Rows
            MeanData(Nans)=NaN;
            Array(Selection.Distance_Min-DistanceMinMax(1)+1,PlRad,DataType)=MeanData;
        end
%                 Data2add=Selection.BoutonDensity(:,Mice);
        
    end
end

GenerateExcelTable=0;
if GenerateExcelTable==1
    [TableExport]=table2cell_2(ExcelTable);
    TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
    PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
    xlsActxWrite(TableExport,Workbook,'BoutonLossSlopes',[],'Delete');
end

close all;
Figure=figure;
if isequal(DataTypes,{'MetRed';'MetBlueCorr'})
    for m=1:2
        Wave1=Array(:,:,m);
        Array(:,:,m)=Wave1/prctile(Wave1(:),98.5)*100;
    end
%     MetBlueMean=Array(:,:,2);
    MetBlueMean=nanmean(Array(20-DistanceMinMax:end,:,2),1);
    MetRedMean=nanmean(Array(20-DistanceMinMax:end,:,1),1);
    
    Array(:,:,1)=Array(:,:,1)./repmat(MetRedMean./MetBlueMean,[size(Array,1),1]);
%     Array(:,:,m)=Wave1/prctile(Wave1(:),98.5)*100;
    
    set(Figure,'Units','centimeters','Position',[55,33,8,5.5]);
    hold on
    [X,Y,Z]=surfPlotSeparateLines_2(Distances,mean(PlaqueRadii,2),Array,'Vertical');
    surf(X,Y,Z(:,:,1),'EdgeColor','magenta');
    surf(X,Y,Z(:,:,2),'EdgeColor','cyan');
    view(-37,40); % [A1,A2]=view();
    grid off;
    box on;
    set(gca,'xlim',[0;20]);
    set(gca,'XTick',(0:4:20));
%     set(gca,'ylim',[-5;4]);
    set(gca,'ylim',[-5;10]);
    set(gca,'YTick',(-5:5:10));
    set(gca,'YDir','reverse');
    set(gca,'zlim',[0;100]);
    set(gca,'ZTick',(0:50:100));
    set(gca,'FontSize',9);
    set(gca,'LineWidth',0.5);
%     A1=1;
    Title=[DataTypes{1},'Vs',DataTypes{2},'_',Title];
    
    % % % [TableExport]=table2cell_2(ExcelTable);
    % % % TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
    % % % PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
    % % % [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
    % % % xlsActxWrite(TableExport,Workbook,'ClDistrDist2Pl',[],'Delete');
elseif strcmp(DataTypes,'MetBlueCorr')
    Array=Array/prctile(Array(:),98.5)*100;
    set(Figure,'Units','centimeters','Position',[55,33,8,5.5]);
    hold on
    [X,Y,Z]=surfPlotSeparateLines_2(Distances,mean(PlaqueRadii,2),Array,'Vertical');
    surf(X,Y,Z(:,:,1),'EdgeColor','black');
    surf(X,Y,Z(:,:,2),'EdgeColor','red');
    view(-37,40); % [A1,A2]=view();
    grid off;
    box on;
    set(gca,'xlim',[0;20]);
    set(gca,'XTick',(0:4:20));
    set(gca,'ylim',[-5;4]);
    set(gca,'YTick',(-8:2:4));
    set(gca,'YDir','reverse');
    set(gca,'zlim',[0;100]);
    set(gca,'ZTick',(0:50:100));
    set(gca,'FontSize',9);
    set(gca,'LineWidth',0.5);
else
    keyboard;
end

set(Figure,'PaperPositionMode','auto');
Path2file=[Path2file,Title];
print('-dtiff','-r1000',[Path2file,'.tif']);
savefig(gcf,[Path2file,'.fig']);
close Figure 1;