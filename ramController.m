function ramController(CurrentLimit,PeriodLimit,Period)
global W;

% keyboard;
[Out]=trackTaskManager();
RunningMatlabInstance=size(strfind1(Out.TaskManager.Abbildname,'MATLAB.exe'),1);
if RunningMatlabInstance==1
    return;
end

Path2Folder=[W.PathProgs,'\multicore\RamUsage\'];

MaxTime2WaitForLocker=Period; % in minutes
MaxTime2WaitForWaiter=5; % in minutes

StartTime=datenum(now);
% WaitTime=0;
% AvailableRAM=0;

while exist('asdf')~=1
    [Wave1,Wave2]=memory; AvailableRAM=Wave2.PhysicalMemory.Available/1000000000; % provides complete free space including the standby RAM
    [WaitPosition]=waitingLine('Wait',StartTime,MaxTime2WaitForLocker,MaxTime2WaitForWaiter,Path2Folder,'RamUsage');
    
    if AvailableRAM>CurrentLimit
        break;
    end
    if AvailableRAM>PeriodLimit && WaitPosition==1
        break;
    end
end

waitingLine('Lock',StartTime,MaxTime2WaitForLocker,MaxTime2WaitForWaiter,Path2Folder,'RamUsage');
