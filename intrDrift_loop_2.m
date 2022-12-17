function [Xcenter,Ycenter,Zcenter]=intrDrift_loop_2(FitCoef,FilenameTotalA,FilenameTotalB,FileinfoA,FileinfoB,NameTable,FilenameTotalTL,MaxDistance,Rotate,Loop)
global W;


% set the data
FA=table;

FA.FilenameTotal={FilenameTotalB;FilenameTotalA}; % first timepoint contains MetRed and the second VglutRed
FA.RefFilename={FilenameTotalA;{''}};
FA.SourceChannel={'MetRed';'VglutRed'};
FA.SourceTimepoint=[1;1];
FA.TargetChannel={1;1};
FA.TargetTimepoint=[1;2];
FA.Rotate=Rotate;
FA.SumCoef{1}=FitCoef;
FA.InterCalc(:,1)={{4,99,200}};


[PathRawTL,Report]=getPathRaw(FilenameTotalTL);
if Loop>1 && Report==1
    FA(2,:)=[];
end

J=struct;
Pix=round(FileinfoA.Pix{1}.*[0.5;0.5;1]);
Res=FileinfoA.Um{1}./Pix;

J.Pix=Pix;
J.Res=Res;
J.UmStart=FileinfoA.UmStart{1};
J.UmEnd=FileinfoA.UmEnd{1};
J.Channels=2;
J.Timepoints=1;
J.PathInitialFile=PathRawTL;

J.FA=FA;
J.BitType='uint8';
merge3D_4(J);

Application=openImaris_2(PathRawTL);
try
    AutofluoLowerManual=IntrDriftAutofluoLowerManual;
catch
    AutofluoLowerManual=100; %2000; 50 up to 2017.02.06;
end

% determine autofluorescent stuff
J = struct;
J.Application=Application;
J.SurfaceName='Autofluo';
J.Channel=1;
J.Smooth=0.3;
J.Background=3;
J.LowerManual=AutofluoLowerManual;
J.Gap=0;
J.MaxDist=MaxDistance;
% J.SurfaceInfo=1;
J.TrackAlgorythm='BrownianMotion';
J.SurfaceFilter=['"Volume" above 5.0 um^3'];
generateSurface3(J);

[Statistics]=getObjectInfo_2('Autofluo',[],Application);
imarisSaveHDFlock(Application,PathRawTL);

Xcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassX;
Ycenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassY;
Zcenter=Statistics.Obj2trackInfo.CenterofHomogeneousMassZ;

