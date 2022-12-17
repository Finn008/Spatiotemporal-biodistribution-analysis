function [BoutonInfo]=dystrophyDetection_Boutons(FilenameTotal)
[Fileinfo]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Vglut1=im2Matlab_3(FilenameTotal,'Vglut1');
[~,Vglut1Corr2]=sparseFilter(Vglut1,[],Res,10000,[100;100;1],[2;2;Res(3)],50,'Multiply100');
J=struct('DataOutput','AllPercentiles');
Vglut1Perc=percentiler(Vglut1Corr2,[],J);

Outside=Vglut1Perc<=21;
[Outside]=removeIslands_3(Outside,4,[0;1],prod(Res(:)));
Outside=imerode(Outside,ones(3,3,3));

BW=bwconncomp(Outside,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>80,:);
Outside=zeros(Pix.','uint8');
Outside(cell2mat(Table.IdxList))=1;

ex2Imaris_2(Outside,FilenameTotal,'Outside');
ex2Imaris_2(Vglut1Corr2,FilenameTotal,'Vglut1Corr');
ex2Imaris_2(Vglut1Corr2,FilenameTotal,'Vglut1Corr2');

Application=openImaris_2(FilenameTotal);
imarisSubtractBackground(Application,'Vglut1Corr',1);
imarisGaussFilter(Application,'Vglut1Corr',0.104);

J=struct;
J.Application=Application;
J.ObjectType='Spot';
J.Channel='Vglut1';
J.SurfaceName='Boutons1';
% J.RGBA=[0.5,1,0,0];
J.DiaXYZ=[1,1,3];
J.Background=1;
J.RegionsFromLocalContrast=1;
J.LowerManual=30;
J.GrowingType=0;
generateSurface3(J);
[Boutons1]=getObjectInfo_2('Boutons1',[],Application,1);

J.SurfaceName='Boutons2';
J.DiaXYZ=[0.5,0.5,1.5];
generateSurface3(J);
[Boutons2]=getObjectInfo_2('Boutons2',[],Application,1);
imarisSaveHDFlock(Application,FilenameTotal);

Vglut1Corr=im2Matlab_3(FilenameTotal,'Vglut1Corr');

Boutons3=spotDetect3D(Vglut1Corr,Outside,Res,90,FilenameTotal,Vglut1Corr2);

BoutonInfo=struct;
BoutonInfo.Boutons1=Boutons1;
BoutonInfo.Boutons2=Boutons2;
BoutonInfo.Boutons3=Boutons3;
BoutonInfo.OutsideVolume=sum(Outside(:))*prod(Res);
BoutonInfo.InsideVolume=prod(Pix(:))*prod(Res)-BoutonInfo.OutsideVolume;
