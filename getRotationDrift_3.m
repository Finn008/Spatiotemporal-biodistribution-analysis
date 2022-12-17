function Table=getRotationDrift_3(Filename,Timepoint)
keyboard % discontinued
[NameTable,SibInfo]=fileSiblings_3(Filename);
FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
FileinfoTrace=getFileinfo_2(FilenameTotalTrace);

MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;

Wave1=SibInfo.FileList(:,{'Filename';'TargetTimepoint'});
[~,Wave2]=unique(Wave1.TargetTimepoint);
FileList=Wave1(Wave2,:);
FitCoef=table;
Table=table;
for File=1:size(FileList,1)
    Timepoint=FileList.TargetTimepoint(File);
    NameTable=fileSiblings_3(FileList.Filename{File});
    Wave1=table;
    Wave1.FilenameTotal=NameTable.FilenameTotal;
    Wave1.Report=NameTable.Report;
    Wave1.Relation=NameTable.Properties.RowNames;
    Wave1.Time(:)=Timepoint;
    %     FitCoefTrace2B=-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs;
%     RotateTrace2B=MultiDimInfo.MetBlue{Timepoint,1}.Rotate;
    
    Wave1=[table2cell(NameTable(:,{'FilenameTotal';'Report'})),NameTable.Properties.RowNames,repmat({FileList.TargetTimepoint(File)},[size(NameTable,1),1])];
    Table(end+1:end+size(NameTable,1),{'FilenameTotal';'Report';'Relation';'Timepoint'})=Wave1;
    
    FitCoefTrace2B=-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs;
    RotateTrace2B=MultiDimInfo.MetBlue{Timepoint,1}.Rotate;
    [DriftInfoPos,Driftinfo]=searchDriftCombi(NameTable.FilenameTotal{'OriginalB'},[Filename,'.lsm']);
    try;FitCoefB2A=[];FitCoefB2A=Driftinfo.Results{1,1}.FitCoefs; end;
    
    Wave1=strfind1(W.G.T.F{W.Task}.Filename,Filename,1);
    RotateTrace2A=W.G.T.F{W.Task}.Rotate(Wave1);

    FitCoef(end+1,{'FitCoefTrace2B';'RotateTrace2B';'FitCoefB2A';'RotateTrace2A'})=[{FitCoefTrace2B},{RotateTrace2B},{FitCoefB2A},{RotateTrace2A}];
end




D2DDeFinB=[]; D2DDeFinAgreen=[]; D2DDeFinAred=[]; D2DRatioA=[]; D2DRatioB=[]; D2DTrace=[]; FitCoefTrace2B=[]; FitCoefB2A=[]; UmMinMax=[]; FileinfoRatioA=[]; FileinfoRatioB=[];
% if exist('Res','Var')~=1
%     Res=[];
% end

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
D2DDeFinB=struct('FilenameTotal',FilenameTotalDeFinB,...
    'Tpix',Pix,...
    'TumMinMax',UmMinMax,...
    'FitCoefs',FitCoefB2A,...
    'Rotate',RotateTrace2B,...
    'Interpolation','Bilinear');
