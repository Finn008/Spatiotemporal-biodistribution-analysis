function [AllFiles]=listAllFiles(Path2file,Folders)

if exist('Folders')~=1
    Folders=0;
end

AllFiles=safeDir(Path2file);
AllFiles=struct2table(AllFiles);
AllFiles=renameFields(AllFiles); % rename to uppercase
AllFiles.Properties.VariableNames{1}='FilenameTotal';

if size(AllFiles,1)==0 % in case Path is to file
    A1=1;
end
if size(AllFiles,1)==1 % in case Path is to file
    AllFiles.FilenameTotal={AllFiles.FilenameTotal};
    AllFiles.Path2file={Path2file};
end
if size(AllFiles,1)>1 % in case Path is a folder
%     AllFiles(1:2,:)=[];
    AllFiles.Path2file=strcat(Path2file,'\',AllFiles.FilenameTotal);
end
if size(AllFiles,1)>0 % on all files
    if Folders==0
        AllFiles(AllFiles.Isdir==1,:)=[]; % remove all folders
        AllFiles.Type=cellfun(@(x) x(end-3:end),AllFiles.FilenameTotal,'UniformOutput',false);
        AllFiles.Filename=cellfun(@(x) x(1:end-4),AllFiles.FilenameTotal,'UniformOutput',false);
    elseif Folders==1
        AllFiles(AllFiles.Isdir==0,:)=[]; % remove all files
    elseif Folders==2 % Folders and Files
    end
end

AllFiles(strcmp(AllFiles.FilenameTotal,'..'),:)=[];
AllFiles(strcmp(AllFiles.FilenameTotal,'.'),:)=[];