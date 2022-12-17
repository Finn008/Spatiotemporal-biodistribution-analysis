function [BoutonInfo]=dystrophyDetection_Boutons_b(FilenameTotal)
keyboard; % remove the program 2017.02.01
[Fileinfo]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

Vglut1=im2Matlab_3(FilenameTotal,'Vglut1');
ex2Imaris_2(Vglut1,FilenameTotal,'Vglut1Corr');
Application=openImaris_2(FilenameTotal);
imarisSubtractBackground(Application,'Vglut1Corr',1);
imarisGaussFilter(Application,'Vglut1Corr',0.104);
imarisSaveHDFlock(Application,FilenameTotal);
Vglut1=im2Matlab_3(FilenameTotal,'Vglut1Corr');
Outside=im2Matlab_3(FilenameTotal,'Outside');
Vglut1Corr2=im2Matlab_3(FilenameTotal,'Vglut1Corr2');

BoutonInfo=spotDetect3D(Vglut1,Outside,Res,90,FilenameTotal,Vglut1Corr2);