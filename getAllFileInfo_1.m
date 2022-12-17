function getAllFileInfo_1()
keyboard; % still in use? 2015.10.09
global W;

% W.Task=strfind1(W.G.T.TaskName,'GetFileInfo',1);

%% get info on all files present
% Fileinfo=[];
% Ind=[];
for m=1:size(W.G.PathRaw,1)
    [Wave1]=listAllFiles(W.G.PathRaw.Path{m});
%     Wave1=struct2table(dir([W.G.PathRaw.Path{m}]));
%     Wave1(1:2,:)=[];
    W.G.PathRaw.SpaceUsed(m)=sum(Wave1.Bytes)/1000000000000;
    W.G.PathRaw.SpaceFree(m)=W.G.PathRaw.SpaceTotal(m)-W.G.PathRaw.SpaceUsed(m);
%     Wave1.Path2file=cellfun(@(x) [W.G.PathRaw.Path{m},'\',x],Wave1.name,'uni',false);
    if m==1
        AllFiles=Wave1;
    else
        AllFiles=[AllFiles;Wave1];
    end
end
% AllFiles=renameFields(AllFiles); % rename to uppercase
% AllFiles.Properties.VariableNames{1}='Filename';
% AllFiles(AllFiles.Isdir==1,:)=[]; % remove all folders
% AllFiles.Type=cellfun(@(x) x(end-3:end),AllFiles.Filename,'UniformOutput',false);
% AllFiles.Filename=cellfun(@(x) x(1:end-4),AllFiles.Filename,'UniformOutput',false);
% AllFiles.Filename.FilenameTotal=strcat(AllFiles.Filename,
% restrict to lsm, ids and ims files
IncludedFiles={'.lsm';'.ids';'.ims';'.czi'};
[Wave1,Wave2]=strfind1(AllFiles.Type,IncludedFiles);
AllFiles(Wave2==0,:)=[];
% AllFiles.GetFileinfo(1)={''};
% W.G.Fileinfo.

% remove all Files that are already present in W.G.Fileinfo

IncludedFiles=W.G.Fileinfo.FilenameTotal;
[Wave1,Wave2]=strfind1(AllFiles.FilenameTotal,IncludedFiles);
AllFiles(Wave2==1,:)=[];
FileNumber=size(AllFiles,1);

Fileinfo2add=emptyRow(W.G.Fileinfo(1,:));
Fileinfo2add.FilenameTotal(1:FileNumber,1)=AllFiles.FilenameTotal;
Fileinfo2add.MB(1:FileNumber,1)=AllFiles.Bytes/1000000;
Fileinfo2add.Type(1:FileNumber,1)=AllFiles.Type;
Fileinfo2add.Filename(1:FileNumber,1)=AllFiles.Filename;
W.G.Fileinfo=[W.G.Fileinfo;Fileinfo2add];
% W.G.T.F{W.Task,1}=AllFiles;