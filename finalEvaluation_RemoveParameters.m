function [SingleStacks]=finalEvaluation_RemoveParameters(SingleStacks)
tic;
global W; global WQ;

for File=1:size(SingleStacks,1)
    if strcmp(SingleStacks.Filename{File}(end),'b')
        Type=1;
    elseif strcmp(SingleStacks.Filename{File}(end),'a')
        Type=2;
    else
        keyboard;
    end
    SingleStacks.DistRelation{File}.Data=SingleStacks.DistRelation{File}.Data(:,WQ.SubRegions);
%     SubRemove=find((1:size(SingleStacks.DistRelation{File}.Data,2)).'~=WQ.SubRegions);
    PlaqueIDs=SingleStacks.DistRelation{File}.Properties.RowNames;
    for Sub=1:size(SingleStacks.DistRelation{File}.Data,2)
        for PlId=PlaqueIDs.'
            DistRelation=SingleStacks.DistRelation{File}.Data{PlId,Sub};
            Parameters=DistRelation.Properties.VariableNames.';
            Parameters=findIntersection([{Parameters};{WQ.Parameters{Type}}]);
            SingleStacks.DistRelation{File}.Data{PlId,Sub}=DistRelation(:,Parameters);
        end
    end
end
disp(['finalEvaluation_RemoveParameters: ',num2str(round(toc/60)),'min']);