function [SingleStacks]=finalEvaluation_PoolSubRegions(SingleStacks)
tic
global WQ;

% Sub1: quadrants
% Sub2: lateral
% Sub3: above
% Sub4: below
% Sub5: blood
% Sub6: Outside





% PoolSubRegions={[1;2];[2]}; % PoolSubRegions={[1;2];[2];[3];[4];[1;2;3;4];[5]};
for File=1:size(SingleStacks,1)
    DistRelation=SingleStacks.DistRelation{File};
    PlaqueNumber=size(DistRelation,1);
    DistRelation2=DistRelation(:,'RoiId');
    for Pl=1:PlaqueNumber
        for Sub=1:size(WQ.PoolSubRegions,1)
            try
                Wave1=DistRelation.Data(Pl,WQ.PoolSubRegions{Sub}).';
                [Wave1]=tableArythemtics(Wave1); % consumes most of the time
                Wave2=DistTimeTable;
                Wave2(Wave1.Properties.RowNames,Wave1.Properties.VariableNames)=Wave1;
                Wave2.Distance=Distance;
                DistRelation2.Data(Pl,Sub)={Wave2};
            end
        end
    end
    SingleStacks.DistRelation{File}=DistRelation2;
    SingleStacks.Toc2(File,1)=toc;
end
disp(['finalEvaluation_PoolSubRegions: ',num2str(round(toc/60)),'min']);