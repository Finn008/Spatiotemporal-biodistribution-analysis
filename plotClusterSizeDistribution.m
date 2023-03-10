function [Image]=plotClusterSizeDistribution(Fraction,Path2file,DistanceMinMax,ClusterSizeMinMax,Normalize,PercentMax)

% Distance vertically (X), Clusters horizontally (Y)
Wave1=Fraction; Wave1(isnan(Fraction))=0;
FractionCumSum=cumsum(Wave1,1);


if exist('Normalize','Var') && Normalize==1
    FractionCumSum=FractionCumSum./repmat(FractionCumSum(end,:),[size(FractionCumSum,1),1]);
else
    Normalize=0;
    FractionCumSum=FractionCumSum/100;
end
Yres=1000; % FractionResolution
FractionCumSum=round(FractionCumSum.*Yres);
Data=zeros(Yres,size(FractionCumSum,2));
ClusterSizes=linspace(ClusterSizeMinMax(1),ClusterSizeMinMax(2),size(FractionCumSum,1)).';
for Dist=1:size(FractionCumSum,2)
    if nansum(FractionCumSum(:,Dist))==0; continue; end;
    Data(1:FractionCumSum(1,Dist),Dist)=ClusterSizes(1);
    for Cl=2:size(FractionCumSum,1)
        if FractionCumSum(Cl-1,Dist)==Yres; break; end;
        if FractionCumSum(Cl-1,Dist)==FractionCumSum(Cl,Dist); continue; end;
        Data(FractionCumSum(Cl-1,Dist)+1:FractionCumSum(Cl,Dist),Dist)=ClusterSizes(Cl);
    end
end
% flip data
Wave1=flip(Data);
for Dist=1:size(FractionCumSum,2)
    Ind=find(Wave1(:,Dist)==0,1)-1;
    Data(end-Ind+1:end,Dist)=Wave1(1:Ind,Dist);
end

AxisDistance=(DistanceMinMax(1):1:DistanceMinMax(2)-1).';
Y=flip((1:Yres).'/Yres*100);

Figure=figure;
set(Figure,'Units','centimeters','Position',[0,0,7,5.5]);
imagesc(AxisDistance,Y,Data,[ClusterSizes(1),ClusterSizes(end)]);
set(gca,'YDir','normal');
set(gca,'xlim',[-12.5,30.5]);
set(gca,'ylim',[0;PercentMax]);
set(gca,'XTick',(-20:10:50));
set(gca,'YTick',(0:10:100));
set(gca,'FontSize',10);
set(gca,'LineWidth',0.5);
set(gca,'fontname','arial')  % Set it to times
ylabel('Cluster fraction [%]','FontSize',10);
xlabel({'Distance [?m]'},'FontSize',10);
box off;
set(gca,'TickDir','Out');
Colormap=colormap_2('Spectrum',1000);
Colormap(1,:)=[1,1,1]; % Colormap(1,:)=[0,0,0];
colormap(Colormap);
Colorbar=colorbar;
set(Colorbar,'Units','centimeters','position',[5.8,1,0.3,4]);
set(Colorbar,'XTick',(0:1:20));
set(Colorbar,'TickDir','Out');
ylabel(Colorbar,'Cluster radius [?m]')
set(gca,'Units','centimeters','Position',[1.5,1,4,4]);
set(gcf,'PaperUnits','centimeters');

set(Figure,'PaperPositionMode','auto');
print('-dtiff','-r1000',[Path2file,'.tif']);
Image=imread([Path2file,'.tif']);
close Figure 1;
