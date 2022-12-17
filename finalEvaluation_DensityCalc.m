function [SingleStacks]=finalEvaluation_DensityCalc(SingleStacks)
tic;
global W; global WQ;

for File=1:size(SingleStacks,1)
    SingleStacks.DistRelation{File}.Density=SingleStacks.DistRelation{File}.Data;
    Res3D=SingleStacks.Res3D(File);
    PlaqueIDs=SingleStacks.DistRelation{File}.Properties.RowNames;
    for PlId=PlaqueIDs.'
        for Sub=1:size(SingleStacks.DistRelation{File}.Data,2)
            Original=SingleStacks.DistRelation{File}.Data{PlId,Sub};
            Final=Original;
            
            Modifications=Original.Properties.VariableNames.';
            Modifications(strfind1(Modifications,{'Distance';'Volume';'Boutons1Histogram'},1),:)=[];
            
            for Mod=Modifications.'
                Final{:,Mod}=Original{:,Mod}./Final.Volume;
            end
            Final.Volume=Original.Volume*Res3D;
            SingleStacks.DistRelation{File}.Density{PlId,Sub}=Final;
        end
    end
    
%     if ceil(File/50)==File/50; disp(round(toc/60)); end;
end
disp(['finalEvaluation_DensityCalc: ',num2str(round(toc/60)),'min']);