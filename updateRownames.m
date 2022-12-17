function updateRownames()
global W;

RowNames=cellstr(num2str([1:size(W.G.Driftinfo,1)].'));
W.G.Driftinfo.Properties.RowNames=RowNames;
RowNames=cellstr(num2str([1:size(W.G.Fileinfo,1)].'));
W.G.Fileinfo.Properties.RowNames=RowNames;
RowNames=cellstr(num2str([1:size(W.G.T,1)].'));
W.G.T.Properties.RowNames=RowNames;