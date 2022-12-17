function backupRawData()
global W;


TargetDrives={'Finn001';'finn002';'finn004';'finn005';'finn006';'finn007';'finn008'};
TargetDrives=array2table(TargetDrives,'VariableNames',{'Path2folder'});
TargetDrives.BackupFolder=[3;1;1;1;1;1;1];

for m=1:size(TargetDrives,1)
    TargetDrives.Path2folder{m,1}=['\\gnp454n\',TargetDrives.Path2folder{m,1},'\BackupRawData'];
    Files2add=listAllFiles(TargetDrives.Path2folder{m});
    if m==1
        TargetFiles=Files2add;
    else
        TargetFiles=[TargetFiles;Files2add];
    end
    
end

SourceDrives={'\\GNP90N\share\Finn\Raw data';'\\GNP91N\share2\Finn\Raw data'};

SourceDrives=array2table(SourceDrives,'VariableNames',{'Path2folder'});
for m=1:size(SourceDrives,1)
    Files2add=listAllFiles(SourceDrives.Path2folder{m});
    if m==1
        SourceFiles=Files2add;
    else
        SourceFiles=[SourceFiles;Files2add];
    end
end
SourceFiles(SourceFiles.Datenum>datenum(now)-1,:)=[];

for File=1:size(SourceFiles,1)
    if max(TargetDrives.BackupFolder(:))==0; keyboard; end;
    [~,CurrentBackupFolder]=max(TargetDrives.BackupFolder(:));
    
    Path2folderTarget=TargetDrives.Path2folder{CurrentBackupFolder};
    Wave1=strfind1(TargetFiles.FilenameTotal,SourceFiles.FilenameTotal{File});
    
    if Wave1==0
        Pat2fileTarget=[Path2folderTarget,'\',SourceFiles.FilenameTotal{File}];
        Path=['copy "',SourceFiles.Path2file{File},'" "',Pat2fileTarget,'"'];
        [Status,Cmdout]=dos(Path);
        
        if Status~=0
%             TargetDrives.BackupFolder(CurrentBackupFolder,1)=0;
            if strfind1(Cmdout,'Es steht nicht genug Speicherplatz auf dem Datentr„ger zur')
                TargetDrives.BackupFolder(CurrentBackupFolder,1)=0;
            end
        elseif Status==0
            if strfind1(Cmdout,'1 Datei(en) kopiert.')==0
                keyboard;
            end
        end
        
        
        disp(Path);
    end
end