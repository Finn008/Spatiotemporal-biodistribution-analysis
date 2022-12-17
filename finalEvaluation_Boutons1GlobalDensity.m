function [MouseInfo]=finalEvaluation_Boutons1GlobalDensity(SingleStacks,MouseInfo)


for File=1:size(SingleStacks,1)
    try
        BoutonDensity=SingleStacks.Statistics{File,1}.Boutons1.BoutonDensity;
    catch
        continue;
    end
    Mouse=find(MouseInfo.MouseId==SingleStacks.MouseId(File));
%     FileNumber=strfind1(MouseInfo.RoiInfo{Mouse,1}.Files{SingleStacks.Roi(File),1}.Filenames(:,2),SingleStacks.Filename{File});
    OrigBoutonDensity=NaN;
    try
        OrigBoutonDensity=MouseInfo.RoiInfo{Mouse,1}.Files{SingleStacks.Roi(File),1}.BoutonDensity(SingleStacks.TargetTimepoint(File));
        
%         keyboard;
        OrigBoutonDensity(OrigBoutonDensity==0)=NaN;
    end
    BoutonDensity=nanmean([BoutonDensity;OrigBoutonDensity]);
    MouseInfo.RoiInfo{Mouse,1}.Files{SingleStacks.Roi(File),1}.BoutonDensity(SingleStacks.TargetTimepoint(File),1)=BoutonDensity;
%     keyboard;
end

for Mouse=1:16 % size(MouseInfo,1)
    try
        BoutonDensity=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.BoutonDensity;
    catch
        continue;
    end
    BoutonDensity(BoutonDensity==0)=NaN;
    TimeAxis=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Age-MouseInfo.StartTreatmentNum(Mouse);
    TimeAxis=round(TimeAxis/7)+10;
    BoutonDensityTemplate=nan(40,1);
    BoutonDensityTemplate(TimeAxis,1)=BoutonDensity;
    MouseInfo.BoutonDensity(Mouse,1:40)=BoutonDensityTemplate.';
    
end

Baseline=nanmean(MouseInfo.BoutonDensity(:,1:9),2);
MouseInfo.BoutonDensity=repmat(Baseline,[1,40])./MouseInfo.BoutonDensity*100;

keyboard;