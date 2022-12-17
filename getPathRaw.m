function [Path2file,Report,AllFiles]=getPathRaw(FilenameTotal)
global W;

if iscell(FilenameTotal)
    FilenameTotal=FilenameTotal{1};
end
Drives=W.G.ComputerInfo.Path2RawData(strcmp(W.G.ComputerInfo.Name,W.ComputerName),:).';
Path2file={[]};
AllFiles=table;
for Drive=1:size(Drives,1)
    Path=[Drives{Drive},'\',FilenameTotal];
    if exist(Path,'file')==2
        AllFiles=[AllFiles;listAllFiles(Path)];
    end
end
if size(AllFiles,1)==0
    Path2file=[Drives{1},'\',FilenameTotal];
    Report=0;
elseif size(AllFiles,1)>1
    disp(['File present more than once: ',strjoin(AllFiles.Path2file.')]);
    AllFiles=sortrows(AllFiles,'Datenum');
    Path2file=AllFiles.Path2file{end,1};
    Report=table;
    Report.FilenameTotal=FilenameTotal;
    Report.CurrentPath{1}=Path2file;
    Report.RemovePath{1}=AllFiles.Path2file{1,1};
    Report.Datenum=datenum(now);
    if isfield(W.G.Error,'FileDuplications')==0
        iFileChanger('W.G.Error.FileDuplications',Report);
    else
        iFileChanger('W.G.Error.FileDuplications=fuseTable(W.G.Error.FileDuplications,Q1);','ExecuteTarget',{'Q1',Report});
    end
    
    Report=1;
elseif size(AllFiles,1)==1
    Path2file=AllFiles.Path2file{1};
    Report=1;
end
