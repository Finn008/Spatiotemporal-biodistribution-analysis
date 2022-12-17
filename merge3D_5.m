function merge3D_5(FilenameTrace,FileList,Res,UmMinMax)
global W;
% dataInspector3D(interpolate3D(uint16(single(MetBlue)./single(Threshold)*100),Res,Res2),Res2,'MetBlueBackgroundRatio',1,FilenameTotalCrude,0);
PixMinMax=round(UmMinMax./[Res,Res]);
Pix=PixMinMax(:,2)-PixMinMax(:,1)+1;

% J=struct;J.PixMax=[Pix;0;1]; J.Resolution=Res; J.Path2file=W.PathImarisSample;
% Application=openImaris_2(J);
[PathRaw,Report]=getPathRaw(FilenameTrace);
Application=openImaris_3(Pix,Res);
Application.FileSave(PathRaw,'writer="Imaris5"');
quitImaris(Application);
for File=1:size(FileList,1)
    J=struct;
    J.FitCoefs=FileList.SumCoef{File};
    J.TumMinMax=UmMinMax;
    J.Tres=Res;
    J.Tpix=Pix;
    try; J.Rotate=FA.Rotate{m}; end;
    Data3D=applyDrift2Data_4(J,Data3D.Channel{m,1});
end


% try; J.FitCoefRange=FA.Range{m}; end;
% try; J.DepthCorrectionInfo=FA.DepthCorrectionInfo{m}; end
if strfind1(FA.Properties.VariableNames,'IndividualUmMinMax')
    J.TumMinMax=FA.IndividualUmMinMax{m};
else
    J.TumMinMax=[UmStart,UmEnd];
end
J.Tres=Res;
J.Tpix=Pix;
try; J.Rotate=FA.Rotate{m}; end;
try; J.InterCalc=FA.InterCalc{m}; end;

Data3D.Data(m,1)={applyDrift2Data_4(Wave1,Data3D.Channel{m,1})};


Application=openImaris_2(FilenameTrace);
Application.FileSave(PathRaw,'writer="Imaris5"');
quitImaris(Application);

imarisSaveHDFlock(FilenameTrace);