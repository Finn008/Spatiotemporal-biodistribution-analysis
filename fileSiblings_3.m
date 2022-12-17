% original:     2014.04.08_38b.lsm
% for deconvolution:       2014.04.08_38b_4decon.ims or .ids
% after deconvolution:       2014.04.08_38b_DeFin.ids
% for deconvolution calibration:        2014.04.08_38b_4deCal.ims
% after deconvolution calibration:        2014.04.08_38b_CalFin.ids
% after putting series together:        38_DriftCorr.ims
% after refining drift in series:        38_Trace.ims
function [NameTable,Out]=fileSiblings_3(Filename)
global W;
if exist('Filename')==1
    FileId=strfind1(W.G.T.F{W.Task}.Filename,Filename,1);
    F=W.G.T.F{W.Task}(FileId,:);
else
    F=W.G.T.F{W.Task}(W.File,:);
end

MouseInfo=W.G.T.F2{W.Task};
MouseInfo=MouseInfo(MouseInfo.MouseId==F.MouseId,:);
Timepoint=F.TargetTimepoint;

[FamilyName]=extractStringPart(F.Filename{1},'Separate_');
FamilyName=FamilyName{end};

Wave1=strfind1(MouseInfo.StackB,FamilyName,1);
Wave2=strfind1(MouseInfo.StackA,FamilyName,1);
if Wave1~=0
    ImageGroup='b';
    OriginalFilenameB=F.Filename{1};
elseif Wave2~=0
    ImageGroup='a';
    Wave1=Wave2;
    OriginalFilenameA=F.Filename{1};
else
    NameTable=[];
    Out=[];
    return;
end
MouseInfo=table2struct(MouseInfo(Wave1(1),:));
FileList=W.G.T.F{W.Task};
FileList=FileList(FileList.MouseId==MouseInfo.MouseId,:);
FileList=FileList(strfind1(FileList.Filename,[{['_',MouseInfo.StackB]};{['_',MouseInfo.StackA]}]),:);

if strcmp(ImageGroup,'b')
    Wave1=FileList.Filename(FileList.TargetTimepoint==Timepoint);
    OriginalFilenameA=0;
    FamilyNameB=FamilyName;
elseif strcmp(ImageGroup,'a')
    Wave1=FileList.Filename(FileList.TargetTimepoint==Timepoint);
    try
        OriginalFilenameB=Wave1{strfind1(Wave1,MouseInfo.StackB)};
    catch
        OriginalFilenameB=0;
    end
    [FamilyNameB]=extractStringPart(OriginalFilenameB,'Separate_');
    FamilyNameB=FamilyNameB{end};
end

Experiment=W.G.T.TaskName{W.Task};
NameTable=table;
if ischar(OriginalFilenameB)
    NameTable('OriginalB','Filename')={{OriginalFilenameB}};
    % get original type
    [FileType]=getFileType(OriginalFilenameB,{'.lsm';'.czi'});
    NameTable('OriginalB','Type')={{FileType}};
    [Path,A1]=getPathRaw([OriginalFilenameB,FileType]);
    SizeOriginal=dir(Path);SizeOriginal=SizeOriginal.bytes/1000000000;
    [~,Report]=getPathRaw([OriginalFilenameB,'_4decon.ids']); % or if 4decon file already exists
    if strcmp(FileType,'.lsm') && SizeOriginal<4 && Report==0
        NameTable('ForDeconB',:)=NameTable('OriginalB',:);
    else
        NameTable('ForDeconB',{'Filename';'Type'})={{[OriginalFilenameB,'_4decon']},{'.ids'}};
%         NameTable('ForDeconB','Type')={{'.ids'}};
    end
    
    NameTable('DeFinB',{'Filename';'Type'})={{[OriginalFilenameB,'_DeFin']},{'.ids'}};
    NameTable('RatioB',{'Filename';'Type'})={{[OriginalFilenameB,'_Ratio']},{'.ims'}};
    Wave1=[Experiment,'_M',num2str(MouseInfo.MouseId),'_',strrep(FamilyNameB,'a','b')];
    NameTable('DriftCorr',{'Filename';'Type'})={{[Wave1,'_DriftCorr']},{'.ims'}};
    NameTable('Trace',{'Filename';'Type'})={{[Wave1,'_Trace']},{'.ims'}};
end
if ischar(OriginalFilenameA)
    NameTable('OriginalA','Filename')={{OriginalFilenameA}};
    % get original type
    [FileType]=getFileType(OriginalFilenameA,{'.lsm';'.czi'});
    NameTable('OriginalA','Type')={{FileType}};
    [Path,A1]=getPathRaw([OriginalFilenameA,FileType]);
    SizeOriginal=dir(Path);SizeOriginal=SizeOriginal.bytes/1000000000;
    [~,Report]=getPathRaw([OriginalFilenameA,'_4decon.ids']); % or if 4decon file already exists
    if strcmp(FileType,'.lsm') && SizeOriginal<4 && Report==0
        NameTable('ForDeconA',:)=NameTable('OriginalA',:);
    else
        NameTable('ForDeconA','Filename')={{[OriginalFilenameA,'_4decon']}};
        NameTable('ForDeconA','Type')={{'.ids'}};
    end
    
    NameTable('DeFinA','Filename')={{[OriginalFilenameA,'_DeFin']}};
    NameTable('DeFinA','Type')={{'.ids'}};
    
    NameTable('RatioA','Filename')={{[OriginalFilenameA,'_Ratio']}};
    NameTable('RatioA','Type')={{'.ims'}};
end
%% to all
NameTable.FilenameTotal=strcat(NameTable.Filename,NameTable.Type);

for m=1:size(NameTable,1)
    [Wave1,Wave2,Wave3]=getPathRaw(NameTable.FilenameTotal{m,1});
    if strcmp(NameTable.Type{m,1},'.ids')
        [~,Wave2(2)]=getPathRaw([NameTable.Filename{m,1},'.ics']);
        Wave2=min(Wave2(:));
    end
    NameTable.Path2file{m,1}=Wave1;
    NameTable.Report(m,1)=Wave2;
    NameTable.Datenum(m,1)=Wave3;
end
Out=struct;
Out.ImageGroup=ImageGroup;
Out.FamilyName=FamilyName;
Out.MouseInfo=MouseInfo;
Out.FileList=FileList;
Out.Timepoint=Timepoint;
Out.FamilyNameB=FamilyNameB;
Out.Experiment=Experiment;
