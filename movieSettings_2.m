function [Out]=movieSettings_2(Xaxis,OrigYaxis,ZumRange,AllPercentiles,FitMinCenterMax)
Out=struct;
Yaxis=OrigYaxis{1,1}.';
for m=2:size(OrigYaxis,1)
    Yaxis(:,:,m)=OrigYaxis{m,1}.';
end

% Yaxis(:,:,3)=OrigYaxis{3,1}.';
% Yaxis(:,:,4)=OrigYaxis{4,1}.';
% Yaxis(:,:,5)=OrigYaxis{5,1}.';
% Yaxis(:,:,6)=OrigYaxis{6,1}.';
% Yaxis(:,:,7)=OrigYaxis{7,1}.';
% Yaxis(:,:,8)=OrigYaxis{8,1}.'; % y.
% Yaxis(:,:,9)=OrigYaxis{9,1}.'; % y-

Yaxis=permute(Yaxis,[1,3,2]);

Out.Tit=strcat({'Percentile: '},AllPercentiles,'%');
Out.Frequency=5;
Out.X=Xaxis;
Out.Y=Yaxis;
Out.Xlab='depth [µm]';
Out.Ylab='intensity [a.u.]';
Out.Xrange=ZumRange;
Out.Yrange=[0;max(OrigYaxis{1,1}(:))*1.5];
Out.Sp=OrigYaxis(:,2);
% Out.Sp={'c.';'c-';'m.';'r.';'r-';'w.';'w-';'y.';'y-'};
Out.Layout='black';
Out.AddLine=[{FitMinCenterMax(1);Out.Yrange(1);FitMinCenterMax(1);Out.Yrange(2,1);{'Color','w'}},{FitMinCenterMax(3);Out.Yrange(1);FitMinCenterMax(3);Out.Yrange(2,1);{'Color','w'}}];
