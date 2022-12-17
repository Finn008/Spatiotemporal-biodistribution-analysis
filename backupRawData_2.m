function backupRawData_2()
% global W;

Path2Excel=['\\Gnp42n\marvin\Finn\Alphabetisch\backup\BackupRawData\',datestr(datenum(now),'yyyy.mm.dd_HH.MM'),'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2Excel);
TargetDrives={'\\gnp454n\Finn001\BackupRawData',100;...
    '\\gnp454n\Finn002\BackupRawData',99;...
    '\\gnp454n\Finn004\BackupRawData',98;...
    '\\gnp454n\Finn005\BackupRawData',97;...
    '\\gnp454n\Finn006\BackupRawData',96;...
    '\\gnp454n\Finn007\BackupRawData',95;...
    '\\gnp454n\Finn008\BackupRawData',94;...
    '\\gnp454n\Finn009\BackupRawData',93;...
    '\\gnp454n\Finn010\BackupRawData',92};
TargetDrives=array2table(TargetDrives,'VariableNames',{'Path2folder','BackupFolder'});
TargetDrives.BackupFolder=cell2mat(TargetDrives.BackupFolder);

TargetFiles=listAllFilesWithSubfolders(TargetDrives);


SourceDrives={'\\GNP90N\share\Finn';...
    '\\GNP91N\share2\Finn'};
SourceDrives=array2table(SourceDrives,'VariableNames',{'Path2folder'});
SourceFiles=listAllFilesWithSubfolders(SourceDrives);
TotalTB=sum(SourceFiles.Bytes)/10^12;


try; xlsActxWrite(TargetFiles,Workbook,'TargetFiles',[],1); end;
try; xlsActxWrite(SourceFiles,Workbook,'SourceFiles',[],1); end;


DeletedFiles=table;
% remove non-present files
% % % % % % for File=1:size(TargetFiles,1)
% % % % % %
% % % % % %     Ind=strfind1(SourceFiles.Path2file,['\\',TargetFiles.Path2file2{File}],1);
% % % % % %     if size(Ind,1)>1
% % % % % %         keyboard; % File duplication
% % % % % %     elseif Ind(1)==0 % || TargetFiles.Bytes(File)~=SourceFiles.Bytes(Ind) || TargetFiles.Datenum(File)~=SourceFiles.Datenum(Ind)
% % % % % %         if TargetFiles.Datenum(File)>datenum(now)-1 % jump over files that are younger than a day
% % % % % %             continue;
% % % % % %         end
% % % % % %         Path=['del "',TargetFiles.Path2file{File},'"'];
% % % % % %         if strfind(Path,'\\GNP9'); keyboard; end; % something is removed in Sourcedata?
% % % % % %         [Status,Cmdout]=dos(Path);
% % % % % %         if Status~=0 || isempty(Cmdout)~=1
% % % % % %             keyboard;
% % % % % %         end
% % % % % %         TargetFiles.Deleted(File,1)={datestr(datenum(now),'yyyy.mm.dd HH:MM')};
% % % % % %         disp(Path);
% % % % % %         DeletedFiles=[DeletedFiles;TargetFiles(File,:)];
% % % % % %     end
% % % % % % end
% % % % % % try; xlsActxWrite(DeletedFiles,Workbook,'DeletedFiles',[],1); end;

% % % % % % Ind=find(cellfun('isempty',TargetFiles.Deleted)==0);
% % % % % % TargetFiles(Ind,:)=[];

% keyboard;
Time4Storage=1;
CopiedFiles=table;
% copy new files
File=1;
while File<=size(SourceFiles,1)
    if max(TargetDrives.BackupFolder(:))==0;
        keyboard; %% all TargetDrives are full
    end
    [~,CurrentBackupFolder]=max(TargetDrives.BackupFolder(:));
    
    Path2folderTarget=TargetDrives.Path2folder{CurrentBackupFolder};
    Ind=strfind1(TargetFiles.Path2file2,SourceFiles.Path2file{File}(3:end),1);
    
    IndDelete=0;
    if size(Ind,1)>1 % file duplication
        [~,Wave1]=min(TargetFiles.Datenum(Ind));
        IndDelete=Ind(Wave1);
    end
    if size(Ind,1)==1 && Ind~=0 && TargetFiles.Datenum(Ind)~=SourceFiles.Datenum(File) % older version
        CurrentInfo=listAllFiles(SourceFiles.Path2file{File});
        if CurrentInfo.Datenum<datenum(now)-Time4Storage % jump over files that are younger than a day
            IndDelete=Ind;
        end
    end
    if IndDelete~=0
%         keyboard;
        
        Path=['del "',TargetFiles.Path2file{IndDelete},'"'];
        if strfind(Path,'\\GNP9'); keyboard; end; % something is removed in Sourcedata?
        [Status,Cmdout]=dos(Path);
        if Status~=0 || isempty(Cmdout)~=1
            if strfind1(Cmdout,'Zugriff verweigert')
            else
                keyboard;
            end
        end
        TargetFiles(IndDelete,:)=[];
        continue;
    end
    
%     if Ind~=0 && TargetFiles.Datenum(Ind)~=SourceFiles.Datenum(File) % (TargetFiles.Bytes(Ind)~=SourceFiles.Bytes(File) || TargetFiles.Datenum(Ind)~=SourceFiles.Datenum(File))
% %         keyboard;
%         Ind=0;
%     end
    
    if Ind==0 % start copy process
        CurrentInfo=listAllFiles(SourceFiles.Path2file{File});
        if CurrentInfo.Datenum>datenum(now)-Time4Storage % jump over files that are younger than a day
            File=File+1;
            continue;
        end
        Pat2fileTarget=[Path2folderTarget,'\',SourceFiles.Path2file{File}(3:end)];
        Path=Pat2fileTarget(1:end-size(SourceFiles.FilenameTotal{File},2));
        if exist(Path,'dir')==0
            mkdir(Path);
        end
        
        Path=['copy "',SourceFiles.Path2file{File},'" "',Pat2fileTarget,'"'];
        disp(Path);
        [Status,Cmdout]=dos(Path);
        
        if Status~=0
            if strfind1(Cmdout,'Es steht nicht genug Speicherplatz auf dem Datentr„ger zur')
                TargetDrives.BackupFolder(CurrentBackupFolder,1)=0;
                continue; % File=File-1;
            elseif strfind1(Cmdout,'Das System kann die angegebene Datei nicht finden')
                
            elseif strfind1(Cmdout,'Zugriff verweigert')
                
            else
                keyboard;
            end
            
        elseif Status==0
            if strfind1(Cmdout,'1 Datei(en) kopiert.')==0
                keyboard;
            end
            
            SourceFiles.Copied(File,1)={datestr(datenum(now),'yyyy.mm.dd HH:MM')};
            SourceFiles.BackupPath(File,1)={Pat2fileTarget};
            CopiedFiles=[CopiedFiles;SourceFiles(File,:)];
            try; xlsActxWrite(CopiedFiles,Workbook,'CopiedFiles',[],1); end
        end
    end
    File=File+1;
    
end

% Ind=find(cellfun('isempty',SourceFiles.Copied)==0);
% CopiedFiles=SourceFiles(Ind,:);

TargetFiles=listAllFilesWithSubfolders(TargetDrives);
try; xlsActxWrite(TargetFiles,Workbook,'TargetFiles',[],1); end;
Workbook.Save;
keyboard;




