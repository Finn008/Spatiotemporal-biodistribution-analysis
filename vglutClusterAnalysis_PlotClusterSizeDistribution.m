function [Image]=vglutClusterAnalysis_PlotClusterSizeDistribution(Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,ClusterSizeBinning,Path2file,Normalize)
Image=[];
ClusterSizes=unique(Table.Dystrophies2Radius_Min);
Fraction=[];
for Cl=1:size(ClusterSizes,1)
    ClID=ClusterSizes(Cl);
    Selection=Table(Table.Dystrophies2Radius_Max==ClID...
        & Table.Time2Treatment_Min==TimeMinMax(1)...
        & Table.Time2Treatment_Max==TimeMinMax(2)...
        & Table.Time2Treatment_Bin==TimeBinning...
        & Table.PlaqueRadius_Min==RadiusMinMax(1)...
        & Table.PlaqueRadius_Max==RadiusMinMax(2)...
        & Table.PlaqueRadius_Bin==RadiiBinning...
        & Table.Distance_Min>=DistanceMinMax(1)...
        & Table.Distance_Max<=DistanceMinMax(2)...
        & Table.Distance_Bin==DistanceBinning,:);
    if size(Selection,1)
        % include mice if plaque of that size is principally there but just the cluster size is missing
        Wave1=Selection.Fraction(:,ismember(MouseInfo.MouseId,MouseIds));
        Data2add=nanmean(Wave1,2);
%         Data2add=nansum(Wave1,2)/size(MouseIds,1);
%         Data2add=trimmean(Wave1,10,2);
    else
        Data2add=NaN;
    end
    Fraction(Selection.Distance_Min-DistanceMinMax(1)+1,Cl)=Data2add;
    
end
if size(Fraction,1)==0 || max(Fraction(:))==0 return; end;

Wave1=Fraction; Wave1(isnan(Fraction))=0;
FractionCumSum=cumsum(Wave1,2);

% max(Fraction(:))
if exist('Normalize') && Normalize==0
    FractionCumSum=FractionCumSum./repmat(FractionCumSum(:,end),[1,size(FractionCumSum,2)]);
else
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
X=(DistanceMinMax(1):1:DistanceMinMax(2)-1).';
Y=flip((Yres:Yres:1).'*100);

Figure=figure;
set(Figure,'Units','centimeters','Position',[0,0,7,5.5]);
imagesc(X,Y,Data,[0,3]);
set(gca,'YDir','normal');
set(gca,'xlim',[-5.5,50.5]);
set(gca,'ylim',[0;60]);
set(gca,'XTick',(0:10:50));
set(gca,'YTick',(0:20:100));
set(gca,'FontSize',10);
set(gca,'LineWidth',0.5);
set(gca,'fontname','arial')  % Set it to times
ylabel('Cluster fraction [%]','FontSize',10);
xlabel({'Distance [µm]'},'FontSize',10);
box off;
set(gca,'TickDir','Out');
Colormap=colormap(jet(1000));
% Colormap(1,:)=[0,0,0];
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
% % x = linspace(-2*pi,2*pi);
% % y = linspace(0,4*pi);
% % [X,Y] = meshgrid(x,y);
% % contour(X,Y,Z);

% saveas(Figure,[Path2file,'.fig']);
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
    [Xmesh,Ymesh]=meshgrid(ClusterSizes,X);
    Figure=figure;
    set(Figure,'Units','centimeters','Position',[0,0,8,5.5]);
    surf(Xmesh,Ymesh,FractionNorm,'edgecolor','none');
%     set(Figure1,);
    Colormap=colormap('gray');
    Colorbar=colorbar;
    set(Colorbar,'TickDir','Out');
    set(Colorbar,'TickLength',0.05);
    set(Colorbar,'XTick',(0:50:100));
    set(Colorbar,'Limits',[0,100]);
    set(gca,'xlim',[0.4,1.6]);
    set(gca,'ylim',[-5;50]);
    set(gca,'zlim',[0;100]);
    set(gca,'XTick',(0.4:0.4:1.6));
    set(gca,'YTick',(0:20:100));
    set(gca,'FontSize',10);
    set(gca,'LineWidth',0.5);
    box on;
    grid off;
    
    hold on;
    Highligt=9;
    Wave1=FractionNorm;
    Wave1(:,9)=NaN;
    [X2,Y2,Z2]=surfPlotSeparateLines(ClusterSizes,X,Wave1);
    
    surf(X2,Y2,Z2);
    X2=nan(size(Xmesh)); X2(:,Highligt)=Xmesh(:,Highligt);
    Y2=nan(size(Xmesh)); Y2(:,Highligt)=Ymesh(:,Highligt);
    Z2=nan(size(Xmesh)); Z2(:,Highligt)=FractionNorm(:,Highligt);
    surf(X2,Y2,Z2,'edgecolor','r');
    view(143,76);
    set(Colorbar,'Units','centimeters','position',[6.9,3.5,0.3,1.6]);
    
    
    set(Figure,'PaperPositionMode','auto');
    Path2file='\\Gnp42n\marvin\Finn\data\X0103 presentations\X0209 Paper1\Files\Vglut1 quantification\ClusterSizeDistribution\AllMice_PlSize10to20_Time-28to0';
    print('-dtiff','-r1000',[Path2file,'.tif']);
    close Figure 1;
    
else
    
end


