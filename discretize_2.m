% Data >= LowerBound && Data < UpperBound except last Edge Data <= UpperBound
function Data=discretize_2(Data,Edges)

[~,~,Data]=histcounts(Data,Edges);

% Data=