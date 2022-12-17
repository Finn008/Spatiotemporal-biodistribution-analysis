% pathInitialFile,pix,res,channels,timepoints,umStart,umEnd
% FA: filename, type, SourceChannel, SourceTimepoint, sumCoef, coefRange, TargetChannel, TargetTimepoint
function [Application]=merge3D_3(II)
global W;
cprintf('text','merge3D: ');
v2struct(II);

if exist('Overwrite')~=1
    Overwrite=0;
end

if strcmp(FA.Properties.VariableNames,'SumCoef')==0
    [FA]=addEmptyVar2Table(FA,{zeros(3,3)},{'SumCoef'});
end
if strcmp(FA.Properties.VariableNames,'Range')==0
    [FA]=addEmptyVar2Table(FA,{[]},{'Range'});
end
if strcmp(FA.Properties.VariableNames,'TargetTimepoint')==0
    FA.TargetTimepoint=repmat(1,[size(FA,1),1]);
end
if strcmp(FA.Properties.VariableNames,'SourceTimepoint')==0
    FA.SourceTimepoint=repmat(1,[size(FA,1),1]);
end

FileNumber=size(FA,1);
if exist('PathInitialFile')==1
    FilenameTotal=strfind(PathInitialFile,'\');
    FilenameTotal=PathInitialFile(FilenameTotal(end)+1:end);
else
    PathInitialFile=getPathRaw(FilenameTotal);
end

if exist('Application')==1 && isempty(Application)==0
    [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application);
    try % if Pix and Res are preset then compare with one of existing file
        if abs(sum(Fileinfo.Pix{1}-II.Pix))>0.001 || abs(sum(Fileinfo.Res{1}-II.Res))>0.001 % existing file has different size
%             W.ErrorMessage='Error in merge3D_3: existing file has different pix size';
            A1=asdf; % 'Error in merge3D_3: existing file has different pix size'
        end
    end
    
    setVisible(Application);
    DataExporter='Imaris';
else
    
    if exist(PathInitialFile,'file')==0 || Overwrite==1 % file is not present, produce new framework
        J=struct;
        J.PixMax=[Pix(1,1);Pix(2,1);Pix(3,1);0;1];
        J.UmMinMax=[UmStart,UmEnd];
        try; J.BitType=BitType; end;
        J.Path2file=W.PathImarisSample;
        Application=openImaris_2(J);
        Application.FileSave(PathInitialFile,'writer="Imaris5"');
        [Fileinfo,FileinfoInd,Path2file]=getFileinfo_2(FilenameTotal,Application);
    else
        [Fileinfo,FileinfoInd,Path2file]=getFileinfo_2(FilenameTotal);
    end
end

if exist('DataExporter')~=1
    if exist('Application')==1
        quitImaris(Application);
    end
    Application=FilenameTotal;
elseif strcmp(DataExporter,'Imaris')
    
else
    keyboard;
end

Pix=Fileinfo.Pix{1};
Res=Fileinfo.Res{1};
UmStart=Fileinfo.UmStart{1};
UmEnd=Fileinfo.UmEnd{1};

try
    if istable(W.G.Fileinfo.Results{FileinfoInd}.MultiDimInfo)==0
        A1=asdf;
    end
catch
    iFileChanger('W.G.Fileinfo.Results{Q1}.MultiDimInfo',table,{'Q1',FileinfoInd});
end

for m=1:FileNumber
    cprintf('text',num2str(m));
    J=struct;
    J.FilenameTotal=FA.FilenameTotal{m};
    [Fileinfo,Ind,J.Path2file]=getFileinfo_2(FA.FilenameTotal{m});
    J.SourceChannel=FA.SourceChannel{m,1};
    J.SourceTimepoint=FA.SourceTimepoint(m,1);
    J.FitCoefs=FA.SumCoef{m};
    try; J.FitCoefRange=FA.Range{m}; end;
    try; J.DepthCorrectionInfo=FA.DepthCorrectionInfo{m}; end
    if strfind1(FA.Properties.VariableNames,'IndividualUmMinMax')
        J.TumMinMax=FA.IndividualUmMinMax{m};
    else
        J.TumMinMax=[UmStart,UmEnd];
    end
    J.Tres=Res;
    J.Tpix=Pix;
    try; J.Rotate=FA.Rotate{m}; end;
    try; J.InterCalc=InterCalc; end;
    try; J.OnlyMultiDimInfo=OnlyMultiDimInfo; end;
    
    [DataOut,~,Out1]=applyDrift2Data_4(J);
    
    if exist('OnlyMultiDimInfo')==1
        keyboard;
    end
    TargetTimepoint=FA.TargetTimepoint(m);
    
    for m2=size(FA.TargetChannel{m},1):-1:1
        try
            TargetChannel=FA.TargetChannel{m}{m2,1};
        catch
            TargetChannel=FA.TargetChannel{m};
        end
        ex2Imaris_2(DataOut(:,:,:,m2),Application,TargetChannel,TargetTimepoint);
        DataOut(:,:,:,m2)=[];
        MultiDimInfo=Out1;
        MultiDimInfo.FilenameTotal=FA.FilenameTotal{m};
        MultiDimInfo.Fileinfo=Fileinfo(:,{'Date','Datenum'});
        iFileChanger('W.G.Fileinfo.Results{Q1}.MultiDimInfo{Q2,Q3}',{MultiDimInfo},{'Q1',FileinfoInd;'Q2',TargetTimepoint;'Q3',TargetChannel});
    end
    clear DataOut;
end
if exist('SaveFile') && SaveFile==1
    cprintf('text',' Saving...');
    Application.FileSave(PathInitialFile,'writer="Imaris5"');
end
cprintf('text','\n');
evalin('caller','global W;');