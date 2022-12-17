% [CumSum,Histogram,Ranges]=cumSumGenerator(Volume); figure; plot(mean(Ranges,2),Histogram);
function [CumSum,NormHistogram,Ranges,Histogram]=cumSumGenerator(Data,Edges)

if exist('Edges')~=1 || isempty(Edges)
    Min=double(min(Data(:)));
    Max=double(max(Data(:)));
    Edges=linspace(Min,Max,101).';
end
% Edges=(0:0.05:1).';
Histogram=histcounts(Data,Edges).';
NormHistogram=Histogram/sum(Histogram)*100;
CumSum=cumsum(NormHistogram);
Ranges=[Edges(1:end-1),Edges(2:end)];