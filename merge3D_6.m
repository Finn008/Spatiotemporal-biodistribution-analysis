% pathInitialFile,pix,res,channels,timepoints,umStart,umEnd
% FileList: filename, type, SourceChannel, SourceTimepoint, sumCoef, coefRange, TargetChannel, TargetTimepoint
% Version 4: allow to just get the data, not set it into file; remove Imaris data export
function [FileList]=merge3D_6(FilenameTotal,FileList,Res,UmMinMax)
global W;
% v2struct(II);
UmStart=UmMinMax(:,1);
UmEnd=UmMinMax(:,2);
if exist('Overwrite')~=1
    Overwrite=0;
end
VariableNames=FileList.Properties.VariableNames;
if strcmp(FileList.Properties.VariableNames,'SumCoef')==0
    [FileList]=addEmptyVar2Table(FileList,{zeros(3,3)},{'SumCoef'});
end
if strcmp(FileList.Properties.VariableNames,'Range')==0
    [FileList]=addEmptyVar2Table(FileList,{[]},{'Range'});
end
if strcmp(FileList.Properties.VariableNames,'TargetTimepoint')==0
    FileList.TargetTimepoint=repmat(1,[size(FileList,1),1]);
end
if strcmp(FileList.Properties.VariableNames,'SourceTimepoint')==0
    FileList.SourceTimepoint=repmat(1,[size(FileList,1),1]);
end
if strcmp(FileList.Properties.VariableNames,'TargetChannel')==0
    FileList.TargetChannel=FileList.SourceChannel;
end

FileNumber=size(FileList,1);
if exist('PathInitialFile')==1
    FilenameTotal=strfind(PathInitialFile,'\');
    FilenameTotal=PathInitialFile(FilenameTotal(end)+1:end);
else
    PathInitialFile=getPathRaw(FilenameTotal);
end


if exist(PathInitialFile,'file')==0 || Overwrite==1 % file is not present, produce new framework
    if exist('Pix')~=1
        Pix=uint16((UmEnd-UmStart)./Res);
    end
    J=struct;
    J.PixMax=[Pix;0;1];
    J.UmMinMax=[UmStart,UmEnd];
    try; J.BitType=BitType; end;
    J.Path2file=W.PathImarisSample;
    Application=openImaris_2(J);
    Application.FileSave(PathInitialFile,'writer="Imaris5"');
    [Fileinfo,FileinfoInd,Path2file]=getFileinfo_2(FilenameTotal,Application);
    quitImaris(Application);
else
    [Fileinfo,FileinfoInd,Path2file]=getFileinfo_2(FilenameTotal);
end

Pix=Fileinfo.Pix{1};
Res=Fileinfo.Res{1};
UmStart=Fileinfo.UmStart{1};
UmEnd=Fileinfo.UmEnd{1};

try
    if istable(W.G.Fileinfo.Results{FileinfoInd}.MultiDimInfo)==0
        A1=asdf; % not needed since 2016.09.06
    end
catch
    iFileChanger('W.G.Fileinfo.Results{Q1}.MultiDimInfo',table,{'Q1',FileinfoInd});
end

for m=1:FileNumber
    cprintf('text',num2str(m));
    J=struct;
    if strfind1(FileList.Properties.VariableNames,'FilenameTotal',1)
        J.FilenameTotal=FileList.FilenameTotal{m};
        [Fileinfo,Ind,J.Path2file]=getFileinfo_2(FileList.FilenameTotal{m});
        J.SourceChannel=FileList.SourceChannel{m,1};
        J.SourceTimepoint=FileList.SourceTimepoint(m,1);
    else
        J.DataIn=FileList.Data3D{m,1};
        J.Fileinfo=FileList.Fileinfo{m,1};
    end
    J.FitCoefs=FileList.SumCoef{m};
    try; J.FitCoefRange=FileList.Range{m}; end;
    try; J.DepthCorrectionInfo=FileList.DepthCorrectionInfo{m}; end
    if strfind1(FileList.Properties.VariableNames,'IndividualUmMinMax')
        J.TumMinMax=FileList.IndividualUmMinMax{m};
    else
        J.TumMinMax=[UmStart,UmEnd];
    end
    J.Tres=Res;
    J.Tpix=Pix;
    try; J.Rotate=FileList.Rotate{m}; end;
    try; J.InterCalc=FileList.InterCalc{m}; end;
    [DataOut,~,Out1]=applyDrift2Data_5(J);
    
    if exist('OnlyMultiDimInfo')==1
        keyboard;
    end
    TargetTimepoint=FileList.TargetTimepoint(m);
    
    for m2=size(FileList.TargetChannel{m,1},1):-1:1
        try
            TargetChannel=FileList.TargetChannel{m}{m2,1};
        catch
            TargetChannel=FileList.TargetChannel{m};
        end
        ex2Imaris_2(DataOut(:,:,:,m2),FilenameTotal,TargetChannel,TargetTimepoint);
        DataOut(:,:,:,m2)=[];
        MultiDimInfo=Out1;
        try; MultiDimInfo.FilenameTotal=FileList.FilenameTotal{m}; end;
        MultiDimInfo.Fileinfo=Fileinfo(:,{'Date','Datenum'});
        iFileChanger('W.G.Fileinfo.Results{Q1}.MultiDimInfo{Q2,Q3}',{MultiDimInfo},{'Q1',FileinfoInd;'Q2',TargetTimepoint;'Q3',TargetChannel});
    end
    if isempty(FileList.TargetChannel{m,1})
        FileList.TargetChannel{m,1}=DataOut;
    end
    
    clear DataOut;
end
cprintf('text','\n');
evalin('caller','global W;');