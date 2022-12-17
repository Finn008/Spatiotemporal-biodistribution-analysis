function taskExecuter_2(TaskID)
global W;
initializeAnywhere_2();
W.Stop=0;
TimerLastJob=datenum(now);
TimerUpdateStatus=0;
Wave1=[W.PathSlaveDriver,'\Communication\'];
Wave2=[W.ComputerName,'_',W.SlaveInstance,'.mat'];
Path2SlaveStatus=[Wave1,'\Status\',Wave2];
Path2SlaveInput=[Wave1,'Input\',Wave2];
Path2SlaveOutput=[Wave1,'Output\',Wave2];

Status=struct;
if exist('TaskID','Var')==1
    Status.TaskID=TaskID;
end
disp([W.ComputerName,'_',W.SlaveInstance,' launched']); %    ','JavaHeapMemory: ',num2str(com.mathworks.services.Prefs.getIntegerPref('JavaMemHeapMax'))]);
while W.Stop~=1
    Status.Available=1; %waiting for task
    
    %% check for new jobs
    if exist(Path2SlaveInput,'file')==2
        Wave1=dir(Path2SlaveInput);
        if (datenum(now)-Wave1.datenum)*24*60>20 % 10 min
            delete(Path2SlaveInput);
        else
            delete(Path2SlaveStatus);
            disp('Loading task ...');
            Input=saveLoad_2(Path2SlaveInput);
            if isfield(Input,'Quit') && Input.Quit==1
                quit;
            end
            Wave1=loadProject_2;
            W.G=Wave1.G;
            W.Task=Input.Task;
            W.File=Input.File;
            Status.Available=2;
        end
    end
    
    %% if received job then execute it
    if Status.Available==2
        rehash; % reload functions
        cprintf('cyan',[W.ComputerName,'_',W.SlaveInstance,',  TaskID: ',num2str(Input.TaskID),', Filename: ',Input.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
        W.ErrorMessage=[];
        W.IfileChanges=table;
                
        global TimeTable; TimeTable=table;
        timeTable();
        delete(Path2SlaveInput);
        if Input.SkipError==0; keyboard; end;
        try
            eval([Input.Dofunction,';']);
            global W;
        catch error
            global W;
            if isempty(W.ErrorMessage) % unknwon error
                [W.ErrorMessage]=displayError(error,0);
            end
        end
        
% %         timeTable('ExportTimeTableAsExcelTable');
        
        quitImaris(W.Imaris.Instances);
        if isempty(W.ErrorMessage)
            cprintf('green',[W.ComputerName,W.SlaveInstance,'...  Success: Task: ',num2str(W.Task),', Filename: ',Input.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
        else
            cprintf('err',[W.ComputerName,W.SlaveInstance,'...  Error: Task: ',num2str(W.Task),', Filename: ',Input.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
            cprintf('err',[W.ErrorMessage,'\n']);
        end
        slaveTimer();
        Output=struct; Output.TimeStamp=Input.TimeStamp; Output.ErrorMessage=W.ErrorMessage; Output.IfileChanges=W.IfileChanges;
        save(Path2SlaveOutput,'Output');
        TimerLastJob=datenum(now);
        if isfield(Status,'TaskID');Status=rmfield(Status,'TaskID');end;
        disp(['Waiting for job ...']);
        Status.Available=1;
    end
    %% decide if proceed waiting for job
    % every 5 min display that waiting for job
    if (datenum(now)-TimerLastJob)*24*60>60*24 % after 24h stop the slave
        W.Stop=1;
    end
    % update Status
    if (datenum(now)-TimerUpdateStatus)*24*60>5 % update every 5 min
        save(Path2SlaveStatus,'Status');
        TimerUpdateStatus=datenum(now);
    end
    
    pause(2);
end
disp('Stopped');
delete(Path2SlaveStatus);
