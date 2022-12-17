function interDistance()
global W;
F=W.G.T.F{W.Task}(W.File,:);
% [FctSpec]=variableExtract(F.DystrophyDetection{1},{'Do';'Plaque';'Lamp1';'Axon';'Step';'ChannelNames';'SomaSize';'Microglia';'Bace1'});
FilenameTotal=F.FilenameTotal{1};
[Fileinfo]=getFileinfo_2(FilenameTotal);
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);
[Mask]=im2Matlab_3(Application,'Blood',1,'Surface');


Skeleton=Skeleton3D(Mask);
ex2Imaris_2(Skeleton,Application,'Skeleton');

J=struct;
J.InCalc=0;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Fileinfo.Res{1};
[Out]=distanceMat_2(J,Mask);
Distance=Out.DistInOut; clear Out;
ex2Imaris_2(Distance,Application,'Distance');
