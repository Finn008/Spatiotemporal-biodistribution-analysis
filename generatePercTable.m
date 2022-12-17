function [PercTable]=generatePercTable(In,Percentiles,TargetChannel,Layer)

if exist('TargetChannel')==1 && isempty(TargetChannel)==0
    if exist('Layer')~=1
        Percentiles=Percentiles.Percentiles{TargetChannel};
    elseif exist('Layer')==1
        Percentiles=Percentiles.PercentileProfile{TargetChannel};
    end
end

if strcmp(In,'Percentiles1to100')==1
    In=[1:1:100;1:1:100].';
elseif strcmp(In,'AllPercentiles')==1
    Wave1=Percentiles.Properties.RowNames;
    Wave2=num2cell((1:size(Wave1,1)).');
    In=[Wave1,Wave2];
end
PercTable=array2table(In,'VariableNames',{'Percentile','TargetValue'});
try; PercTable.TargetValue=cell2mat(PercTable.TargetValue); end;
try; PercTable.Percentile=num2strArray_2(PercTable.Percentile); end;
if exist('Layer')~=1
    Percentiles=Percentiles{PercTable.Percentile,1};
    PercTable.SourceValue=Percentiles;
elseif exist('Layer')==1
    
    PercTable.SourceValue=Percentiles{PercTable.Percentile,Layer};
end