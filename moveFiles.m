function moveFiles()

SourceFolder='\\GNP90N\share\Finn\Raw data';
DestinationFolder='\\GNP91N\share2\Finn\Raw data';

FileList=listAllFiles(SourceFolder);
FileList=FileList(strcmp(FileList.Type,'.czi'),:);

for m=1:size(FileList,1)
    Path=['robocopy "',SourceFolder,'" "',DestinationFolder,'" "',FileList.FilenameTotal{m,1},'" /ipg:465'];
    [Status,Cmdout]=dos(Path);
%     if isempty(Cmdout)==0
%         keyboard;
%     end
end
keyboard;