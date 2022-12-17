function saveProject_2(SaveInterval,BackupInterval)
global W;
% generate backup for l.mat
if exist('SaveInterval','Var')==0; SaveInterval=0; end;
if exist('BackupInterval','Var')==0; BackupInterval=9999999; end;

%% save
if (datenum(now)-W.TimerSave)*24 > SaveInterval
    statusNotifyer(['Saving I.mat... ',datestr(now,'yy.mm.dd HH:MM:SS')]);
    Info=struct;
    Info.G=W.G;
    save([W.PathSlaveDriver,'\Communication\Info\Info~.mat'],'Info');
    Path=['rename "',[W.PathSlaveDriver,'\Communication\Info\Info~.mat'],'" "','Info_',datestr(datenum(now),'yyyymmddHHMMSS'),'.mat','"'];
    [Status,Cmdout]=dos(Path);
    W.TimerSave=datenum(now);
    statusNotifyer(['Finished saving ',datestr(now,'yy.mm.dd HH:MM:SS')]);
end
% remove old files
FileList=listAllFiles([W.PathSlaveDriver,'\Communication\Info']);
FileList2=sortrows(FileList(strfind1(FileList.Filename,'Info'),:),'Datenum');
for File=1:size(FileList2,1)-1
    Wave1=regexprep(FileList2.Filename{File},'Info_','');
    if strfind1(FileList.Filename,['Loading_',Wave1],1)==0 || FileList2.Datenum(File)<datenum(now)-1/24/60*10
        delete(FileList2.Path2file{File});
    end
end

if (datenum(now)-W.TimerBackup)*24 > BackupInterval
    Path2Backup=[W.PathExp,'\Backup\Info'];
    if exist(Path2Backup,'dir')==0
        mkdir(Path2Backup);
    end
    Path=['copy "',FileList2.Path2file{end},'" "',Path2Backup,'"'];
    [Status,Cmdout]=dos(Path);
    W.TimerBackup=datenum(now);
end
