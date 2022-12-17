function backupMatlab()
global W;
Path2BackupFolder=[W.PathExp,'\Backup\Matlab\',datestr(now,'yyyy.mm.dd,HH.MM')];
% Path2BackupFolder=[W.PathExp,'\Backup\Programs\',datestr(now,'yyyy.mm.dd,HH.MM')];
% Path2BackupFolder=['\\fs-mu.dzne.de\petersf\data\Matlab\Backup\',datestr(now,'yyyy.mm.dd,HH.MM')];
% Path2BackupFolder=['\\fs-mu.dzne.de\ag-herms\Finn Peters\data\Matlab\Backup\',datestr(now,'yyyy.mm.dd,HH.MM')];
% Path2BackupFolder=['\\GNP90N\share\Finn\Marvin\data\Matlab\Backup\',datestr(now,'yyyy.mm.dd,HH.MM')];
% Path2BackupFolder=['\\Gnp42n\marvin\Finn\data\Matlab\backup\',datestr(now,'yyyy.mm.dd,HH.MM')];
mkdir(Path2BackupFolder);
AllFiles=table;
AllFiles.MatlabFiles={listAllFiles([W.PathProgs])};
AllFiles.InfoFiles={listAllFiles([W.PathSlaveDriver,'\Communication\Info'])};
% AllFiles.DefaultFiles={listAllFiles([W.PathExp,'\default'])};
AllFiles.ExcelFiles={listAllFiles([W.PathSlaveDriver,'\Excel'])};

for SuperPath=AllFiles.Properties.VariableNames
    FileList=AllFiles{1,SuperPath{1}}{1};
    SubFolderPath=[Path2BackupFolder,'\',SuperPath{1}];
    mkdir(SubFolderPath);
    for File=1:size(FileList,1)
        TargetPath=[SubFolderPath,'\',FileList.FilenameTotal{File}];
        try % if file Iloading file is removed inbetween
            copyfile(FileList.Path2file{File},TargetPath,'f');
        end
    end
end
disp('Matlab successfully saved');




