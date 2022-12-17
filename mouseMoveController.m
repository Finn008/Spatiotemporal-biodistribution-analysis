function mouseMoveController(Status)
global W;
Path2Folder=[W.PathProgs,'\multicore\MouseMove\'];

MaxTime2WaitForLocker=60*3; % in minutes
MaxTime2WaitForWaiter=10; % in minutes
if Status==0
    FileList=listAllFiles(Path2Folder);
    Wave1=strfind1(FileList.FilenameTotal,[W.ComputerName,'_Locker_',W.SlaveInstance]);
    try
        delete(FileList.Path2file{Wave1});
    end
    return;
end
StartTime=datenum(now);
WaitTime=0;
MouseStatus=[];

WaiterFilename=[W.ComputerName,'_Waiter_',W.SlaveInstance,'_Since_',datestr(StartTime,'yyyy.mm.dd.HH.MM.SS.FFF'),'.mat'];
while WaitTime<999999999999
    FileList=listAllFiles(Path2Folder);
    FileList.LastUpdate=(datenum(now)-FileList.Datenum)*24*60;
    for m=1:size(FileList,1)
        Wave1=FileList.FilenameTotal{m}(end-26:end-4);
        try
            FileList.WaitTime(m,1)=(datenum(now)-datenum(Wave1,'yyyy.mm.dd.HH.MM.SS.FFF'))*24*60;
        end
    end
    
    % first check for Waiters in the row
    IndWaiter=strfind1(FileList.FilenameTotal,[W.ComputerName,'_Waiter']);
    
    AllowLockerCheck=0;
    if IndWaiter==0
        AllowLockerCheck=1;
    else
        try
            if WaitTime~=0 && FileList.WaitTime(strfind1(FileList.FilenameTotal,WaiterFilename))==max(FileList.WaitTime(IndWaiter))
                AllowLockerCheck=1;
            end
        catch
            keyboard;
        end
    end
    
    if AllowLockerCheck==1
        IndLocker=strfind1(FileList.FilenameTotal,[W.ComputerName,'_Locker']);
        if IndLocker==0
            break;
        end
    end
    
    if WaitTime==0
        save([Path2Folder,WaiterFilename],'MouseStatus');
        cprintf('text',[W.ComputerName,W.SlaveInstance,' waiting for mouseMove since ',datestr(StartTime,'yyyy.mm.dd HH:MM'),' ... ']);
        LastDisplayTime=datenum(now);
    end
    pause(2);
    WaitTime=(datenum(now)-StartTime)*24*60;
    if (datenum(now)-LastDisplayTime)*24*60>1
        cprintf('text',[num2str(round(WaitTime)),',']);
        LastDisplayTime=datenum(now);
        save([Path2Folder,WaiterFilename],'MouseStatus'); % renew
    end
    
    for m=1:size(FileList,1)
        % delete Waiters that are not updated since 10min and Lockers not updated since 3 hours
        if (strfind1(FileList.FilenameTotal{m},'Waiter') && FileList.LastUpdate(m)>MaxTime2WaitForWaiter) || (strfind1(FileList.FilenameTotal{m},'Locker') && FileList.LastUpdate(m)>MaxTime2WaitForLocker)
            delete(FileList.Path2file{m});
        end
        % delete Waiters and Lockers of the same slave
        if strfind1(FileList.FilenameTotal{m},W.SlaveInstance) && strcmp(FileList.FilenameTotal{m},WaiterFilename)==0
            delete(FileList.Path2file{m});
        end
    end
end

LockerFilename=[W.ComputerName,'_Locker_',W.SlaveInstance,'_Since_',datestr(datenum(now),'dd.mmmHH.MM'),'.mat'];
if exist(Path2Folder,'dir')==0
    mkdir(Path2Folder);
end
save([Path2Folder,LockerFilename],'MouseStatus');

if WaitTime~=0
    delete([Path2Folder,WaiterFilename]);
    cprintf('text','Done!!!');
    cprintf('text','\n');
end
cprintf('text',[W.ComputerName,W.SlaveInstance,' locking mouseMove since ',datestr(datenum(now),'yyyy.mm.dd HH:MM')]);
cprintf('text','\n');
