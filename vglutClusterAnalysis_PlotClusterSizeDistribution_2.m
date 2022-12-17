function [Image]=vglutClusterAnalysis_PlotClusterSizeDistribution_2(Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,ClusterSizeBinning,Path2file,Normalize,Version)

if size(MouseIds,1)==1
    MinimalMouseNumber=1;
else
    MinimalMouseNumber=1;
end
Image=[];

Fraction=[];
Table2=Table(Table.Time2Treatment_Min==TimeMinMax(1)... % Include only selected Bins
    & Table.Time2Treatment_Max==TimeMinMax(2)...
    & Table.Time2Treatment_Bin==TimeBinning...
    & Table.PlaqueRadius_Min==RadiusMinMax(1)...
    & Table.PlaqueRadius_Max==RadiusMinMax(2)...
    & Table.PlaqueRadius_Bin==RadiiBinning...
    & Table.Distance_Min>=DistanceMinMax(1)...
    & Table.Distance_Max<=DistanceMinMax(2)...
    & Table.Distance_Bin==DistanceBinning,:);

DataAvailability=max(Table2.Fraction,[],1).';
Mice=ismember(MouseInfo.MouseId,MouseIds).';
Mice(isnan(DataAvailability))=0;
ClusterSizes=unique(Table2.Dystrophies2Radius_Min);
for Cl=1:size(ClusterSizes,1)
    ClID=ClusterSizes(Cl);
    
    Table3=Table2(Table2.Dystrophies2Radius_Max==ClID,:);
    if size(Table3,1)>0
        % NaN entries: for that plaque size at that time and cluster size no data exist
        % include mice if plaque of that size is principally there but just the cluster size is missing
        Wave1=Table3.Fraction(:,Mice);
% % %         Data2add=nansum(Wave1,2)/nansum(Mice(:));
        
        Data2add=nanmean(Wave1,2);
%         Data2add=nanmedian(Wave1,2);
        NonNanEntries=size(Wave1,2)-sum(isnan(Wave1),2); % data mus be present for at least two mice in order to be shown
        Data2add(NonNanEntries<MinimalMouseNumber)=NaN;
    else
        Data2add=NaN;
    end
    % Distance vertically (X), Clusters horizontally (Y)
    Fraction(Table3.Distance_Min-DistanceMinMax(1)+1,Cl)=Data2add;
    
end
if size(Fraction,1)==0 || max(Fraction(:))==0 return; end;

Wave1=Fraction; Wave1(isnan(Fraction))=0;
FractionCumSum=cumsum(Wave1,2);

if exist('Normalize') && Normalize==1
    FractionCumSum=FractionCumSum./repmat(FractionCumSum(:,end),[1,size(FractionCumSum,2)]);
else
%     keyboard;
    Normalize=0;
    FractionCumSum=FractionCumSum/100;
end
Yres=0.001;
Data=nan(1/Yres,size(FractionCumSum,2));
% Distance horizontally (Y), Clustersize vertically (X)
ClusterSizes=ClusterSizes/10;
for Dist=1:size(FractionCumSum,1)
    Wave1=round(FractionCumSum(Dist,:).'/Yres);
    if sum(isnan(Wave1))~=0; continue; end;
    Data(1:Wave1(1),Dist)=ClusterSizes(1);
    for Cl=2:size(ClusterSizes,1)
        Data(max([Wave1(Cl-1);1]):Wave1(Cl),Dist)=ClusterSizes(Cl);
    end
end
Data=flip(Data);
AxisDistance=(DistanceMinMax(1):1:DistanceMinMax(2)-1).';
Y=flip((Yres:Yres:1).'*100);

Figure=figure;
set(Figure,'Units','centimeters','Position',[0,0,7,5.5]);
imagesc(AxisDistance,Y,Data,[0,3]);
set(gca,'YDir','normal');
% set(gca,'xlim',[-5.5,50.5]);
set(gca,'xlim',[-12.5,30.5]);
set(gca,'ylim',[0;60]);
set(gca,'XTick',(-20:10:50));
set(gca,'YTick',(0:20:100));
set(gca,'FontSize',10);
set(gca,'LineWidth',0.5);
set(gca,'fontname','arial')  % Set it to times
ylabel('Cluster fraction [%]','FontSize',10);
xlabel({'Distance [µm]'},'FontSize',10);
box off;
set(gca,'TickDir','Out');
Colormap=colormap_2('Spectrum',1000);
Colormap(1,:)=[1,1,1];
colormap(Colormap);
Colorbar=colorbar;
set(Colorbar,'Units','centimeters','position',[5.8,1,0.3,4]);
set(Colorbar,'XTick',(0:1:20));
set(Colorbar,'TickDir','Out');
ylabel(Colorbar,'Cluster radius [µm]')

set(gca,'Units','centimeters','Position',[1.5,1,4,4]);

set(gcf,'PaperUnits','centimeters');
Path2file=[Path2file,Title];

set(Figure,'PaperPositionMode','auto');
print('-dtiff','-r1000',[Path2file,'.tif']);
Image=imread([Path2file,'.tif']);
% saveas(Figure,[Path2file,'.tif']);
close Figure 1;



PlotEachClusterSizeSeparately=0;
if PlotEachClusterSizeSeparately==1
    MaxRange=[-5;30];
    MaxRange=MaxRange-DistanceMinMax(1);
    Wave1=Fraction(MaxRange(1):MaxRange(2),:);
    
    FractionNorm=Fraction./repmat(prctile(Wave1,99,1),[size(Fraction,1),1])*100;
    FractionNorm(FractionNorm>=100)=99.9999;
    [Xmesh,Ymesh]=meshgrid(ClusterSizes,AxisDistance);
    Figure=figure;
    set(Figure,'Units','centimeters','Position',[0,0,8,5.5]);
    surf(Xmesh,Ymesh,FractionNorm,'edgecolor','none');
    Colormap=colormap('gray');
    Colorbar=colorbar;
    set(Colorbar,'TickDir','Out');
    set(Colorbar,'TickLength',0.05);
    set(Colorbar,'XTick',(0:50:100));
    set(Colorbar,'Limits',[0,100]);
    ClusterSizes2Visualize=(0.4:0.1:1.6).';
    set(gca,'xlim',[min(ClusterSizes2Visualize),max(ClusterSizes2Visualize)]);
    set(gca,'ylim',[-5;50]);
    set(gca,'zlim',[0;100]);
    set(gca,'XTick',(0.4:0.4:1.6));
    set(gca,'YTick',(0:20:100));
    set(gca,'FontSize',10);
    set(gca,'LineWidth',0.5);
    box on;
    grid off;
    hold on;
    
    
    Colormap=colormap_2('Spectrum',30);
    for ClId=ClusterSizes2Visualize.'
        Cl=find(round(ClusterSizes*10)==round(ClId*10));
        Nans=nan(size(AxisDistance,1),1);
        X2=[Nans,Xmesh(:,Cl),Nans];
        Y2=[Nans,Ymesh(:,Cl),Nans];
        Z2=[Nans,FractionNorm(:,Cl),Nans];
        surf(X2,Y2,Z2,'edgecolor',Colormap(Cl,:));
    end
    view(143,76);
    set(Colorbar,'Units','centimeters','position',[6.9,3.5,0.3,1.6]);
    
    
    set(Figure,'PaperPositionMode','auto');
    Path2file='\\Gnp42n\marvin\Finn\data\X0103 presentations\X0209 Paper1\Files\Vglut1 quantification\ClusterSizeDistribution\AllMice_PlSize10to20_Time-28to0';
    print('-dtiff','-r1000',[Path2file,'.tif']);
    close Figure 1;
end


