function [Image]=plotClusterSizeDistribution_2(Fraction,Path2file,DistanceMinMax,ClusterSizeMinMax,Normalize)

% Distance vertically (X), Clusters horizontally (Y)
% Fraction=Fraction.';
Wave1=Fraction; Wave1(isnan(Fraction))=0;
FractionCumSum=cumsum(Wave1,1);


if exist('Normalize','Var') && Normalize==1
    FractionCumSum=FractionCumSum./repmat(FractionCumSum(end,:),[size(FractionCumSum,1),1]);
else
%     keyboard;
    Normalize=0;
    FractionCumSum=FractionCumSum/100;
end
Yres=1000; % FractionResolution
FractionCumSum=round(FractionCumSum.*Yres);
Data=zeros(Yres,size(FractionCumSum,2));
ClusterSizes=linspace(ClusterSizeMinMax(1),ClusterSizeMinMax(2),size(FractionCumSum,1)).';
% ClusterSizes=(1:size(FractionCumSum,2)).';
for Dist=1:size(FractionCumSum,2)
%     Wave1=round(FractionCumSum(Dist,:).'/Yres);
    if nansum(FractionCumSum(:,Dist))==0; continue; end;
    Data(1:FractionCumSum(1,Dist),Dist)=ClusterSizes(1);
    for Cl=2:size(FractionCumSum,1)
        if FractionCumSum(Cl-1,Dist)==Yres; break; end;
        if FractionCumSum(Cl-1,Dist)==FractionCumSum(Cl,Dist); continue; end;
        Data(FractionCumSum(Cl-1,Dist)+1:FractionCumSum(Cl,Dist),Dist)=ClusterSizes(Cl);
%         Data(max([FractionCumSum(Cl-1);1]):FractionCumSum(Cl),Dist)=ClusterSizes(Cl);
    end
end
% flip data
Wave1=flip(Data);
for Dist=1:size(FractionCumSum,2)
    Ind=find(Wave1(:,Dist)==0,1)-1;
    Data(end-Ind+1:end,Dist)=Wave1(1:Ind,Dist);
end

% ClusterSizes=(1:size(Data,2)).';
% Data=flip(Data);
AxisDistance=(DistanceMinMax(1):1:DistanceMinMax(2)-1).';
% Y=flip((Yres:Yres:1).'*100);
Y=flip((1:Yres).'/Yres*100);

Figure=figure;
set(Figure,'Units','centimeters','Position',[0,0,7,5.5]);
imagesc(AxisDistance,Y,Data,[ClusterSizes(1),ClusterSizes(end)]);
set(gca,'YDir','normal');
set(gca,'xlim',[-12.5,30.5]);
set(gca,'ylim',[0;30]);
set(gca,'XTick',(-20:10:50));
set(gca,'YTick',(0:10:100));
set(gca,'FontSize',10);
set(gca,'LineWidth',0.5);
set(gca,'fontname','arial')  % Set it to times
ylabel('Cluster fraction [%]','FontSize',10);
xlabel({'Distance [µm]'},'FontSize',10);
box off;
set(gca,'TickDir','Out');
Colormap=colormap_2('Spectrum',1000);
Colormap(1,:)=[1,1,1]; % Colormap(1,:)=[0,0,0];
colormap(Colormap);
Colorbar=colorbar;
set(Colorbar,'Units','centimeters','position',[5.8,1,0.3,4]);
set(Colorbar,'XTick',(0:1:20));
set(Colorbar,'TickDir','Out');
ylabel(Colorbar,'Cluster radius [µm]')
set(gca,'Units','centimeters','Position',[1.5,1,4,4]);
set(gcf,'PaperUnits','centimeters');


% Path2file=[Path2file,Title];
set(Figure,'PaperPositionMode','auto');
print('-dtiff','-r1000',[Path2file,'.tif']);
Image=imread([Path2file,'.tif']);
% saveas(Figure,[Path2file,'.tif']);
close Figure 1;












return;

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


