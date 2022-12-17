function [J]=movieSettings1(Xaxis,NormPercentileProfile,FitTotal,OpticsCorr,FitOptics,LinAdjustCorr,FitLinAdjust,TotalCorr,FitSignal,NormFitTotal,ZumRange,AllPercentiles,FitMinCenterMax)
J=struct;
Yaxis=LinAdjustCorr.'; % cyan.
Yaxis(:,:,2)=FitLinAdjust.'*100; % cyan-
Yaxis(:,:,3)=NormFitTotal.'*100; % magenta
Yaxis(:,:,4)=OpticsCorr.'; % r.
Yaxis(:,:,5)=FitOptics.'*100; % r-
Yaxis(:,:,6)=TotalCorr.'; % white.
Yaxis(:,:,7)=FitSignal.'; % white-
Yaxis(:,:,8)=NormPercentileProfile.'; % y.
Yaxis(:,:,9)=FitTotal.'*100; % y-

Yaxis=permute(Yaxis,[1,3,2]);

J.Tit=strcat({'Percentile: '},AllPercentiles,'%');
J.Frequency=5;
J.X=Xaxis;
J.Y=Yaxis;
J.Xlab='depth [µm]';
J.Ylab='intensity [a.u.]';
J.Xrange=ZumRange;

J.Yrange=[0;300]; % J.Yrange=[0;max(NormPercentileProfile(:))*1.5];
J.Sp={'c.';'c-';'m.';'r.';'r-';'w.';'w-';'y.';'y-'};
J.Layout='black';
J.AddLine=[{FitMinCenterMax(1);J.Yrange(1);FitMinCenterMax(1);J.Yrange(2,1);{'Color','w'}},{FitMinCenterMax(3);J.Yrange(1);FitMinCenterMax(3);J.Yrange(2,1);{'Color','w'}}];
