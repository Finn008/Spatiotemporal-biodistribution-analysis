function taskCaller_5(Task,handles)
global W;
TimerGoogleDrive=0;
TimerShowPipeline=datenum(now);

while W.Stop~=1
    
    %% integrate "Integrate.xlsx"
    Path2Integrate=[W.PathGoogleDrive,'\TaskList\Integrate.xlsx'];
    if exist(Path2Integrate)==2
        try
            % close and delete Pipeline
            Path2Pipeline=[W.PathExp,'\default\Excel\Pipeline_2.xlsx'];
            [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2Pipeline);
            Workbook.Close;
            delete(Path2Pipeline);
            % rename "Integrate" to "Pipeline" and move it to default
            Path=['move "',Path2Integrate,'" "',Path2Pipeline,'"'];
            [Status,Cmdout]=dos(Path);
            showPipeline();
        end
    end
    %% place Pipeline to GoogleDrive
    if TimerGoogleDrive<datenum(now)-(10/24/60)
        % Show tasklist on GoogleDrive
        Path2TaskList=[W.PathGoogleDrive,'\TaskList\TaskList.xlsx'];
        try
            copyfile([W.PathExp,'\default\Excel\Pipeline_2.xlsx'],[W.PathGoogleDrive,'\TaskList\Pipeline_2.xlsx']);
            copyfile([W.PathProgs,'\multicore\AutoquantStatus.xlsx'],[W.PathGoogleDrive,'\TaskList\AutoquantStatus.xlsx']);
            CDpath=['cd(''C:\Program Files (x86)\Google\Drive'');']; eval(CDpath);
        end
        inputemu('move',[100;100]); pause(0.5); inputemu('move',[200;200]);
        TimerGoogleDrive=datenum(now);
    end
    
    
    %% check through Input data, if job not taken within 10min then reset TaskID to 1
    InputFiles=listAllFiles([W.PathProgs,'\multicore\Input']);
    for m=1:size(InputFiles,1)
        if InputFiles.Datenum(m)+W.TimeDelay<datenum(now)-1/24/60*20 % delete after 20min
            Input=saveLoad_2(InputFiles.Path2file{m});
            try
                delete(InputFiles.Path2file{m});
                W.G.TaskList.Status(Input.TimeStamp)=1;
            end
        end
    end
    
    %% check for Output data
    OutputFiles=listAllFiles([W.PathProgs,'\multicore\Output']);
    OutputFiles(OutputFiles.Bytes>1e+9|OutputFiles.Bytes==0,:)=[];
    for m=1:size(OutputFiles,1)
        clear Report;
        Output=saveLoad_2(OutputFiles.Path2file{m});
        TaskID=strfind1(W.G.TaskList.Properties.RowNames,Output.TimeStamp);
        if TaskID~=0
            if isempty(Output.ErrorMessage) % successfully finished, iFile successfully integrated
                Report=1;
                W.G.TaskList.Error{Output.TimeStamp}='Success!';
                W.G.TaskList.Status(Output.TimeStamp)=0;
                cprintf('green',['Success. Slave: ',OutputFiles.FilenameTotal{m},', Filename: ',W.G.TaskList.Filename{Output.TimeStamp},', Time: ',datestr(datenum(now),'yyyy.mm.dd HH:MM'),', TaskID: ',num2str(TaskID),'\n']);
            else % finished with error, but iFile successfully integrated
                Report=2;
                cprintf('err',['ERROR: Slave: ',OutputFiles.FilenameTotal{m},', Filename: ',W.G.TaskList.Filename{Output.TimeStamp},', Time: ',datestr(datenum(now),'yyyy.mm.dd HH:MM'),', TaskID: ',num2str(TaskID),'\n']);
                cprintf('err',[Output.ErrorMessage,'\n']);
                W.G.TaskList.Error{Output.TimeStamp}=Output.ErrorMessage;
                W.G.TaskList.Status(Output.TimeStamp)=3;
            end
            [Wave1]=incorporateIdata(Output.IfileChanges);
            if Wave1==0 % Task was found but iFile could not be integrated
                Report=3;
                W.G.TaskList.Status(Output.TimeStamp)=999;
                W.G.TaskList.Error{Output.TimeStamp}='Error Ifile!';
                cprintf('err','Error Ifile!\n');
            end
            W.G.TaskList.Duration(Output.TimeStamp)=round((datenum(now)-W.G.TaskList.Datenum(Output.TimeStamp))*24*10)/10;
        else % Task was not found in Tasklist
            Report=0;
            cprintf('err','Task was not found among Tasklist!\n');
        end
        if Report==1 || Report==2
            BackupPath=[W.PathProgs,'\multicore\backup\Output\',OutputFiles.FilenameTotal{m}];
        elseif Report==0 || Report==3
            BackupPath=[W.PathProgs,'\multicore\backup\ErrorIfile\',OutputFiles.FilenameTotal{m}];
        end
        movefile(OutputFiles.Path2file{m},BackupPath,'f'); % delete(OutputFiles.Path2file{m});
    end
    %     showPipeline('Matlab2Excel');
    %% check which MatlabCores are available to receive new task
    % slaveStatus has to be present, Occupation must be 1, no InputFiles should be present, no Outputfile should be present
    SlaveStatus=listAllFiles([W.PathProgs,'\multicore\Status']);
    InputFiles=listAllFiles([W.PathProgs,'\multicore\Input']);
    OutputFiles=listAllFiles([W.PathProgs,'\multicore\Output']);
    
    for m=1:size(SlaveStatus,1)
        SlaveStatus.Command(m,1)={'Continue'};
        SlaveStatus.Command2(m,1)={[' ']};
        clear Status;
        Slave=SlaveStatus.FilenameTotal{m};
        SlaveStatus.InputReport(m)=strfind1(InputFiles.FilenameTotal,Slave);
        SlaveStatus.OutputReport(m)=strfind1(OutputFiles.FilenameTotal,Slave);
        SlaveStatus.Recency(m)=(datenum(now)-SlaveStatus.Datenum(m,1))*24*60;
        
        if SlaveStatus.InputReport(m)==0 && SlaveStatus.OutputReport(m)==0
            if SlaveStatus.Recency(m)<60    % switch back to 10!!!
                %                     keyboard;
                Status=saveLoad_2(SlaveStatus.Path2file{m,1});
            else
                delete(SlaveStatus.Path2file{m,1});
            end
        end
        if exist('Status')~=1 || isempty(Status)
            Status=struct; Status.Occupation=0;
        end
        SlaveStatus=fuseTable_3(SlaveStatus,struct2table(Status,'AsArray',1),[1,m]);
        
        Wave1=strfind1(W.G.SlaveList.Slave,SlaveStatus.FilenameTotal(m),1);
        if Wave1~=0
            SlaveStatus.Command(m,1)=W.G.SlaveList.Command(Wave1);
            try;
                SlaveStatus.Command2(m,1)=W.G.SlaveList.Command2(Wave1);
            catch
                SlaveStatus.Command2(m,1)={''};
            end
        end
    end
    
    if isempty(SlaveStatus)==0
        SlaveStatus=SlaveStatus(SlaveStatus.Occupation==1,:);
    end
    %% distribute tasks to slaves waiting for task
    if size(SlaveStatus,1)==0
        SlaveIDs=[];
    else
        SlaveIDs=find(SlaveStatus.Occupation==1).';
    end
    for SlaveID=SlaveIDs
        if strcmp(SlaveStatus.Command{SlaveID},'Pause')
            continue;
        end
        % set tasks of that computer still set to Status 2 to 3
        Wave1=find(W.G.TaskList.Status==2 & strcmp(W.G.TaskList.Slave,SlaveStatus.FilenameTotal{SlaveID}));
        if isempty(Wave1)==0
            W.G.TaskList.Status(Wave1,1)=4;
        end
        
        TaskID=[];
        Undone=table;
        Undone.TaskID=find(floor(W.G.TaskList.Status)==1);
        Undone.Status=W.G.TaskList.Status(Undone.TaskID);
        Undone=sortrows(Undone,'Status');
        
        
        if strfind1(SlaveStatus.Command{SlaveID},'TaskID')
            TaskID=str2num(SlaveStatus.Command{SlaveID}(7:end));
            W.G.SlaveList.Command(strfind1(W.G.SlaveList.Slave,SlaveStatus.FilenameTotal{SlaveID}),1)={'SetContinue'};
        end
        if strfind1(SlaveStatus.Properties.VariableNames.','TaskID',1)~=0 && SlaveStatus.TaskID(SlaveID)~=0
            TaskID=SlaveStatus.TaskID(SlaveID);
        end
        if isempty(TaskID) && (W.SkipError==0 || strcmp(SlaveStatus.Command{SlaveID},'Stop'))
            showPipeline('Matlab2Excel');
            disp(['Slave: ',SlaveStatus.Filename{SlaveID},', TaskID: ']);
            keyboard;
        end
        Path2SlaveInput=[W.PathProgs,'\multicore\Input\',SlaveStatus.FilenameTotal{SlaveID}];
        if strcmp(SlaveStatus.Command{SlaveID},'Quit')
            Input=struct; Input.SkipError=2; % Quit
            save(Path2SlaveInput,'Input');
            cprintf('cyan',['Quitting ',SlaveStatus.FilenameTotal{SlaveID},'\n']);
            continue;
        end
        
        if isempty(Undone) && isempty(TaskID) % currently no task available
            continue;
        end
        if strfind1(SlaveStatus.Command2{SlaveID},'Random')
            [~,Wave1]=sort(rand(size(Undone,1),1));
            Undone=Undone(Wave1,:);
        end
        
        if isempty(TaskID)
            for Row=Undone.TaskID.'
                % ComputerName
                try
                    Wave1=W.G.TaskList.Restriction{Row,1}.ComputerName.Only;
                    if strfind1(SlaveStatus.Filename{SlaveID},Wave1.')==0
                        continue;
                    end
                end
                % ImarisStatus
                if SlaveStatus.Imaris(SlaveID)==0
                    try
                        Wave1=W.G.TaskList.Restriction{Row,1}.ImarisStatus.Also;
                    catch
                        continue;
                    end
                end
                TaskID=Row;
                break;
            end
        end
        
        if isempty(TaskID)
            continue;
        end
        try; delete(SlaveStatus.Path2file{SlaveID,1}); end;
        
        W.G.TaskList.Datenum(TaskID,1)=datenum(now);
        W.G.TaskList.Error{TaskID}='';
        W.G.TaskList.Clock{TaskID}=datestr(now,'mmm.dd HH:MM');
        Input=table2struct(W.G.TaskList(TaskID,:));
        Input.TimeStamp=W.G.TaskList.Properties.RowNames{TaskID,1};
        Input.TaskID=TaskID;
        Input.PathExp=W.PathExp;
        if strfind1(SlaveStatus.Command{SlaveID},'TaskID') || (strfind1(SlaveStatus.Properties.VariableNames.','TaskID',1)~=0 && SlaveStatus.TaskID(SlaveID)~=0)
            Input.SkipError=0;
        else
            Input.SkipError=W.SkipError; % 0 if has to stop, 1 to continue
        end
        Input.InputDrive=W.InputDrive;
        Input.Path2W=W.Pathi;
        Input.SingularImarisInstance=W.SingularImarisInstance;
        W.G.TaskList.Status(TaskID)=2;
        W.G.TaskList.Slave(TaskID)=SlaveStatus.FilenameTotal(SlaveID);
        cprintf('cyan',['Slave: ',SlaveStatus.FilenameTotal{SlaveID},', Function: ',W.G.TaskList.Dofunction{TaskID},', Task: ',num2str(W.G.TaskList.Task(TaskID)),', Filename: ',W.G.TaskList.Filename{TaskID},', Time: ',datestr(now,'yy.mm.dd HH:MM'),', TaskID: ',num2str(TaskID),'\n']);
        save(Path2SlaveInput,'Input');
        pause(1);
    end
    %% always
    if isempty(find(W.G.TaskList.Status==1|W.G.TaskList.Status==2))
        W.Stop =1;
    end
    saveProject(1);
    if datenum(now)>TimerShowPipeline+1/24/60*10
        disp(['ShowPipeline',datestr(datenum(now),'HH:MM:SS')]);
        showPipeline('Matlab2Excel');
        TimerShowPipeline=datenum(now);
    end
    if isfield(W,'Keyboard')
        W=rmfield(W,'Keyboard');
        showPipeline('Matlab2Excel');
        keyboard;
    end
    
    pause(10);
end

%% finish
saveProject();
excelViewer();
disp('Processing finished');

