function finalEvaluation_VisualizeSinglePlaquesDistRelTrace(PlaqueListSingle)

Selection=PlaqueListSingle;
Selection(isnan(Selection.RadiusFit1),:)=[];
Wave1=find(nansum(Selection.Boutons1(:,50:52),2)==0);
Selection(Wave1,:)=[];

Path2Folder='\\GNP90N\share\Finn\Analysis\output\SinglePlaqueDistRelTraces';

for Pl=1:size(PlaqueListSingle,1)
    
    figure;
    hold on;
    Path=['M',num2str(BinInfo.MouseId),',Id',num2str(BinInfo.Id),',T',BinInfo.TimeBin{1},',Rad',num2str(BinInfo.RadMin),'-',num2str(BinInfo.RadMax)];
    title([Path,', Y0: ',num2str(round(Coefs(1),3)),', Top: ',num2str(round(Coefs(2),3)),', K: ',num2str(round(Coefs(3),2))]);
    plot(X,Data,'.k');
    plot(Fit,'-k');
    Range=[-10,100,0,0.05];
    axis(Range);
    FolderPath=['\\GNP90N\share\Finn\Analysis\output\Boutons2\M',num2str(BinInfo.MouseId)];
    if exist(FolderPath)~=7
        mkdir(FolderPath);
    end
    saveas(gcf,[FolderPath,'\',Path,'.png'])
    close Figure 1;
    
end