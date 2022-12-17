function taskExecuter(TaskID)
keyboard; % replace by taskExecuter_2
global W;
initializeAnywhere();

LastJobDatenum=datenum(now);
DisplayInterval=5;
LastDisplayNotification=-5;

Path2SlaveStatus=[W.PathProgs,'\multicore\Status\',W.ComputerInfo.Name,W.SlaveInstance,'.mat'];
Path2SlaveInput=[W.PathProgs,'\multicore\Input\',W.ComputerInfo.Name,W.SlaveInstance,'.mat'];
Path2SlaveOutput=[W.PathProgs,'\multicore\Output\',W.ComputerInfo.Name,W.SlaveInstance,'.mat'];
IniW=W;
Status=struct;
if exist('TaskID','Var')==1
    Status.TaskID=TaskID;
%     Status.SkipError=0;
end
disp([W.ComputerInfo.Name,W.SlaveInstance,' launched    ','JavaHeapMemory: ',num2str(com.mathworks.services.Prefs.getIntegerPref('JavaMemHeapMax'))]);
TestApplication=[];
TimerImarisLicence=0;
while W.Stop~=1
    Status.Occupation=1; %waiting for task
    
    % check Imaris licence
    [ImarisInstances]=trackTaskManager();
    ImarisInstances=strfind1(ImarisInstances.TaskManager.Abbildname,'Imaris.exe');
    if TimerImarisLicence<datenum(now)-(30/24/60) && ImarisInstances(1)==0
        %         In=struct; In.Path2file=W.PathImarisSample; In.TrialNumber=1;
        [TestApplication]=openImaris_2(W.PathImarisSample);
        %         mouseMoveController(0);
        if isempty(TestApplication)
            Status.Imaris=0;
        else
            Status.Imaris=1;
        end
        TimerImarisLicence=datenum(now);
    else
        ImarisInstances=size(ImarisInstances,1);
        Status.Imaris=1;
        if ImarisInstances>1 && strcmp(TestApplication,'Imaris.IApplicationPrxHelper')
            quitImaris(TestApplication);
            TestApplication=[];
        end
    end
    
    %% check for new jobs
    if exist(Path2SlaveInput)==2
        delete(Path2SlaveStatus);
        Wave1=dir(Path2SlaveInput);
        Age=(datenum(now)-Wave1.datenum+W.TimeDelay)*24*60;
        if Age>20 % 20 min
            delete(Path2SlaveInput);
        else
            disp('Loading task ...');
            Input=saveLoad_2(Path2SlaveInput);
            if Input.SkipError==2
                quit;
            end
            W.Pathi=Input.Path2W;
            if isempty(Input)==0
                I=loadProject;
                if isempty(I)==0 && isempty(I.G.T)==0
                    W=catstruct(IniW,Input,I);
                    Status.Occupation=2;
                    clear I;
                    OrigW=W;
                end
            end
        end
    end
    
    %% if received job then execute it
    if Status.Occupation==2
        rehash; % reload functions
        cprintf('cyan',[W.ComputerInfo.Name,W.SlaveInstance,'...  Function: ',W.Dofunction,', Task: ',num2str(W.Task),', Filename: ',W.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
        W.ErrorMessage=[];
        
        W.IfileChanges=table;
        
        global TimeTable; TimeTable=table;
        timeTable();
        if isfield(W,'Keyboard'); W=rmfield(W,'Keyboard'); keyboard; end;
        delete(Path2SlaveInput);
        if strcmp(class(TestApplication),'Imaris.IApplicationPrxHelper'); try; quitImaris(TestApplication); end; TestApplication=[]; end;
        if W.SkipError==0
            keyboard;
        end
        try
            eval([W.Dofunction,';']);
            global W;
        catch error
            global W;
            if isempty(W.ErrorMessage) % unknwon error
                [W.ErrorMessage]=displayError(error,0);
            end
        end
        
        for m=1:100
            try
                timeTable('ExportTimeTableAsExcelTable');
                break;
            catch
                pause(30);
            end
        end
        
        quitImaris(W.ImarisId);
        if isempty(W.ErrorMessage)
            cprintf('green',[W.ComputerInfo.Name,W.SlaveInstance,'...  Success: ',W.Dofunction,', Task: ',num2str(W.Task),', Filename: ',W.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
        else
            cprintf('err',[W.ComputerInfo.Name,W.SlaveInstance,'...  Error: ',W.Dofunction,', Task: ',num2str(W.Task),', Filename: ',W.Filename,', Time: ',datestr(now,'yyyy.mm.dd HH:MM'),'\n']);
            cprintf('err',[W.ErrorMessage,'\n']);
        end
        slaveTimer();
        Output=struct; Output.TimeStamp=W.TimeStamp; Output.ErrorMessage=W.ErrorMessage; Output.IfileChanges=W.IfileChanges;
        save(Path2SlaveOutput,'Output');
        LastJobDatenum=datenum(now);
        DisplayInterval=5;
%         Status.TaskID=[];
        if isfield(Status,'TaskID');Status=rmfield(Status,'TaskID');end;
    end
    %% decide if proceed waiting for job
    if Status.Occupation==1
        % every 5 min display that waiting for job
        Time2LastJob=(datenum(now)-LastJobDatenum)*24*60; % in min
        if Time2LastJob>60*10 % 10h
            W.Stop=1;
        elseif Time2LastJob>floor(LastDisplayNotification/DisplayInterval)*DisplayInterval+DisplayInterval
            disp(['Waiting for job since ',num2str(round(Time2LastJob)),' minutes. ImarisStatus = ',num2str(floor(Status.Imaris)),' Time: ',datestr(datenum(now),'yyyy.mm.dd HH:MM')]);
            LastDisplayNotification=Time2LastJob;
        end
        if W.Stop>1
            Status.Occupation=3; % pausing
            save(Path2SlaveStatus,'Status');
            StartClock=datenum(now)+W.Stop/3600/24;
            disp(['Pause for ', num2str(W.Stop/3600),' hours, until ',datestr(StartClock,'yy.mm.dd'),', ',datestr(StartClock,'HH.MM.AM')]);
            W.Stop=0;
        end
    end
    try; save(Path2SlaveStatus,'Status'); end;
    if isfield(W,'Keyboard'); W=rmfield(W,'Keyboard'); keyboard; end;
    pause(30);
    pause(W.Stop);
    
end
delete(Path2SlaveStatus);
