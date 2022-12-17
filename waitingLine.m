function [WaitPosition]=waitingLine(Status,StartTime,MaxTime2WaitForLocker,MaxTime2WaitForWaiter,Path2Folder,Description)
global W;
SaveVar=[];
WaitTime=(datenum(now)-StartTime)*24*60;
WaiterFilename=[W.ComputerInfo.Name,'_Waiter_',W.SlaveInstance,'_Since_',datestr(StartTime,'yyyy.mm.dd.HH.MM.SS.FFF'),'.mat'];

if strcmp(Status,'Unlock')
    keyboard; % delete the locker file
    FileList=listAllFiles(Path2Folder);
    Wave1=strfind1(FileList.FilenameTotal,[W.ComputerInfo.Name,'_Locker_',W.SlaveInstance]);
    try
        delete(FileList.Path2file{Wave1});
    end
    return;
end

if strcmp(Status,'Wait')
    
    FileList=listAllFiles(Path2Folder);
    
    if strfind1(FileList.FilenameTotal,[W.ComputerInfo.Name,'_Waiter_',W.SlaveInstance])==0
        save([Path2Folder,WaiterFilename],'SaveVar');
        cprintf('text',[W.ComputerInfo.Name,W.SlaveInstance,' waiting for ',Description,' since ',datestr(StartTime,'yyyy.mm.dd HH:MM'),' ... ']);
        FileList=listAllFiles(Path2Folder);
    end
    
    FileList=FileList(strfind1(FileList.FilenameTotal,[W.ComputerInfo.Name]),:);
    
    
    FileList.LastUpdate=(datenumNowLocal(Path2Folder)-FileList.Datenum)*24*60;
    for m=1:size(FileList,1)
        Wave1=FileList.FilenameTotal{m}(end-26:end-4);
        try
            FileList.WaitTime(m,1)=(datenum(now)-datenum(Wave1,'yyyy.mm.dd.HH.MM.SS.FFF'))*24*60;
        end
        
    end
    FileList=sortrows(FileList,'WaitTime','descend');
    
    WaitPosition=strfind1(FileList.FilenameTotal,[W.ComputerInfo.Name,'_Waiter_',W.SlaveInstance]);
%     if WaitPosition==1
%         keyboard;
%     end
    
    if (datenumNowLocal(Path2Folder)-FileList.Datenum(WaitPosition))*24*60>1 % refresh waiter file
        cprintf('text',[num2str(round(WaitTime)),',']);
        save([Path2Folder,WaiterFilename],'SaveVar');
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
    
    pause(min([WaitTime*60;600]));
end

if strcmp(Status,'Lock')
    LockerFilename=[W.ComputerInfo.Name,'_Locker_',W.SlaveInstance,'_Since_',datestr(StartTime,'yyyy.mm.dd.HH.MM.SS.FFF'),'.mat'];
    save([Path2Folder,LockerFilename],'SaveVar');
    delete([Path2Folder,WaiterFilename]);
    cprintf('text','Done!!!');
    cprintf('text','\n');
    cprintf('text',[W.ComputerInfo.Name,W.SlaveInstance,' locking ',Description,' since ',datestr(datenum(now),'yyyy.mm.dd HH:MM')]);
    cprintf('text','\n');
end