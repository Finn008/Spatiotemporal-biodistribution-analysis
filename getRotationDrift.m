function [D2DDeFinAgreen,D2DDeFinAred,D2DRatioA,D2DRatioB,D2DTrace,FitCoefTrace2B,FitCoefB2A,Res,UmMinMax,FileinfoRatioA,FileinfoRatioB]=getRotationDrift(Filename,Timepoint,Res)
D2DDeFinAgreen=[]; D2DDeFinAred=[]; D2DRatioA=[]; D2DRatioB=[]; D2DTrace=[]; FitCoefTrace2B=[]; FitCoefB2A=[]; UmMinMax=[]; FileinfoRatioA=[]; FileinfoRatioB=[];
if exist('Res','Var')~=1
    Res=[];
end
[NameTable,SibInfo]=fileSiblings_3(Filename);
FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
FilenameTotalRatioB=NameTable.FilenameTotal{'RatioB'};
FilenameTotalDeFinB=NameTable.FilenameTotal{'DeFinB'};
FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
FileinfoDeFinB=getFileinfo_2(FilenameTotalDeFinB);
FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
try
    MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;
    FitCoefTrace2B=-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs;
    RotateTrace2B=MultiDimInfo.MetBlue{Timepoint,1}.Rotate;
catch
    FitCoefTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.U.FitCoefs;
    RotateTrace2B=FileinfoRatioB.Results{1}.MultiDimInfo.DistInOut{1}.Rotate;
end
[DriftInfoPos,Driftinfo]=searchDriftCombi(NameTable.FilenameTotal{'OriginalB'},[Filename,'.lsm']);
try
    FitCoefB2A=Driftinfo.Results{1,1}.FitCoefs;
catch
    return;
end
% A1=find(strcmp(W.G.T.F{W.Task}.Filename,Filename) & W.G.T.F{W.Task}.TargetTimepoint==Timepoint)
Wave1=strfind1(W.G.T.F{W.Task}.Filename,Filename,1);
RotateTrace2A=W.G.T.F{W.Task}.Rotate(Wave1);
% RotateTrace2A=W.G.T.F{W.Task}.Rotate(W.File);
FilenameTotalDeFinA=NameTable.FilenameTotal{'DeFinA'};
FileinfoDeFinA=getFileinfo_2(FilenameTotalDeFinA);
FilenameTotalRatioA=NameTable.FilenameTotal{'RatioA'};
FileinfoRatioA=getFileinfo_2(FilenameTotalRatioA);

if isempty(Res)
    Res=FileinfoRatioA.Res{1};
end
Pix=uint16(FileinfoDeFinA.Um{1}./Res);
UmMinMax=[FileinfoDeFinA.UmStart{1},FileinfoDeFinA.UmEnd{1}];

D2DRatioA=struct('FilenameTotal',FilenameTotalRatioA,...
    'Tpix',Pix,...
    'Rotate',RotateTrace2A);
D2DDeFinAgreen=struct('FilenameTotal',FilenameTotalDeFinA,...
    'Tpix',Pix,...
    'Interpolation','Bilinear',...
    'Rotate',RotateTrace2A,...
    'DepthCorrectionInfo',struct('DataOutput',{{'Normalize2Percentile',{'50',40},['uint8']}}));
D2DDeFinAred=D2DDeFinAgreen;
D2DDeFinAred.DepthCorrectionInfo.DataOutput={'Normalize2Percentile',{'50',20},['uint8']};

D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
    'Tpix',Pix,...
    'SourceTimepoint',Timepoint,...
    'TumMinMax',UmMinMax,...
    'FitCoefs',FitCoefB2A+FitCoefTrace2B);
D2DRatioB=struct('FilenameTotal',FilenameTotalRatioB,...
    'Tpix',Pix,...
    'TumMinMax',UmMinMax,...
    'FitCoefs',FitCoefB2A,...
    'Rotate',RotateTrace2B,...
    'Interpolation','Bilinear');
