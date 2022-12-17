function vglutClusterAnalysis_PlotClusterSizeDistributionSeparately(Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,ClusterSizeBinning,Path2file)
keyboard; % delete
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
        Wave1=Selection.Fraction(:,ismember(MouseInfo.MouseId,MouseIds));
        Data2add=trimmean(Wave1,10,2);
%         Data2add=nanmean(Selection.Fraction(:,ismember(MouseInfo.MouseId,MouseIds)),2);
    else
        Data2add=NaN;
    end
    Fraction(Selection.Distance_Min-DistanceMinMax(1)+1,Cl)=Data2add;
    
end
if size(Fraction,1)==0 || max(Fraction(:))==0 return; end;
Fraction(isnan(Fraction))=0;
Fraction=cumsum(Fraction,2);

% max(Fraction(:))
if exist('Normalize') && Normalize==0
    Fraction=Fraction./repmat(Fraction(:,end),[1,size(Fraction,2)]);
else
    Fraction=Fraction/100;
end
Yres=0.001;
Data=nan(1/Yres,size(Fraction,2));
% Distance horizontally (Y), Clustersize vertically (X)
ClusterSizes=ClusterSizes/10;
for Dist=1:size(Fraction,1)
    Wave1=round(Fraction(Dist,:).'/Yres);
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
Colormap(1,:)=[0,0,0];
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


