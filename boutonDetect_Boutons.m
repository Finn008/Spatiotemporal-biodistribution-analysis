function Boutons=boutonDetect_Boutons(ExactVglutGreen,FilenameTotalRatioA,Path2fileRatioA)

tic;
% IntermediateFilenameTotal=strrep(FilenameTotalRatioA,'.ims','_BoutonDetection.ims');
% IntermediatePath2file=strrep(Path2fileRatioA,'.ims','_BoutonDetection.ims');
% Path=['copy "',Path2fileRatioA,'" "',IntermediatePath2file,'"'];
% [Status,Cmdout]=dos(Path);
ex2Imaris_2(ExactVglutGreen,FilenameTotalRatioA,'Boutons'); clear ExactVglutGreen;
Application=openImaris_2(FilenameTotalRatioA);
imarisSubtractBackground(Application,'Boutons',1);
imarisSaveHDFlock(Application,Path2fileRatioA);
% Application.FileSave(Path2fileRatioA,'writer="Imaris5"');
% quitImaris(Application);
disp('Finish');
Boutons=im2Matlab_3(FilenameTotalRatioA,'Boutons');
Outside=im2Matlab_3(FilenameTotalRatioA,'Outside');
% A1=Boutons(Outside==0);
% keyboard; % get correct percentile
Threshold=prctile(Boutons(Outside==0),96); % 70-->1350, ?-->10000
% Threshold=prctile(A1,70);
% Threshold=10000;
% [Distance]=distanceMat2D(Boutons>Threshold,Res);
J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,Boutons<Threshold);
Distance=Out.DistInOut; clear Out;

% Wave1=max(Distance(:))-Distance-4;
Wave1=uint8(4)-Distance;
WatershedDistance=watershed(Wave1); clear Wave1;
WatershedDistance=single(WatershedDistance);
WatershedDistance(Distance==0)=0;
% Wave1=floor(WatershedDistance/65535);
WatershedDistance2=uint16(WatershedDistance-(floor(WatershedDistance/65535)*65535));

[Window]=generateEllipse([0.8;0.8;0.8],Res);
Wave1=smooth3(Boutons,'box',size(Window));
Wave1=max(Wave1(:))-Wave1;
WatershedIntensity=watershed(Wave1); clear Wave1;
WatershedIntensity(Distance==0)=0;
WatershedIntensity2=uint16(WatershedIntensity-(floor(WatershedIntensity/65535)*65535));

% ex2Imaris_2(Distance,FilenameTotalRatioA,'Distance');
ex2Imaris_2(WatershedDistance2,FilenameTotalRatioA,'WatershedDistance');
ex2Imaris_2(WatershedIntensity2,FilenameTotalRatioA,'WatershedIntensity');
imarisSaveHDFlock(FilenameTotalRatioA);
% Application=openImaris_2(FilenameTotalRatioA);
% Application.SetVisible(1);
% SortedBoutons=sort(Boutons(Outside==0));

keyboard;
return;
ex2Imaris_2(uint16(WatershedIntensity),FilenameTotalRatioA,'Remove');



Watershed=watershed(max(VglutGreenSmooth(:))-VglutGreenSmooth,6);
Watershed(Boutons==0)=0;





J=struct;
J.Application=Application;
J.ObjectType='Spot';
J.Channel='ExactVglutGreen';
J.SurfaceName='Boutons1';
J.RGBA=[0.5,1,0,0];
J.SurfaceFilter=['"Quality" above automatic threshold'];
J.DiaXYZ=[1,1,3];
J.Background=1;
J.RegionsFromLocalContrast=1;
J.LowerManual=30;
J.GrowingType=0;
generateSurface3(J); % 40min
[Statistics]=im2Matlab_3(Application,'Boutons1',1,'Spot');
[Statistics.ObjInfo]=spotIntensityReader(Statistics.ObjInfo,{VglutGreen;VglutRed;GRratio},{'VglutGreen';'VglutRed';'GRratio'},'Sphere',FileinfoDeFinA.Res{1});

save(PathStatistics,'Statistics');
quitImaris(Application);
pause(5);
Path=['del "',IntermediatePath2file,'"'];
[Status,Cmdout]=dos(Path);
% disp(['Boutons: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);
% disp(['Boutons: ',num2str(tic/60)),'min']);