function taskCaller_6()
global W;
% TimerGoogleDrive=0;
TimerShowPipeline=datenum(now);

while W.Stop~=1
    
% %     %% integrate "Integrate.xlsx"
% %     Path2Integrate=[W.PathGoogleDrive,'\Pipeline\Integrate.xlsx'];
% %     if exist(Path2Integrate)==2
% %         try
% %             % close and delete Pipeline
% %             Path2Pipeline=[W.PathExp,'\default\Excel\Pipeline_2.xlsx'];
% %             [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2Pipeline);
% %             Workbook.Close;
% %             delete(Path2Pipeline);
% %             % rename "Integrate" to "Pipeline" and move it to default
% %             Path=['move "',Path2Integrate,'" "',Path2Pipeline,'"'];
% %             [Status,Cmdout]=dos(Path);
% %             showPipeline();
% %         end
% %     end
% %     %% place Pipeline to GoogleDrive
% %     if TimerGoogleDrive<datenum(now)-(10/24/60)
% %         % Show Pipeline on GoogleDrive
% %         Path2Pipeline=[W.PathGoogleDrive,'\Pipeline\Pipeline.xlsx'];
% %         try
% %             copyfile([W.PathExp,'\default\Excel\Pipeline_2.xlsx'],[W.PathGoogleDrive,'\Pipeline\Pipeline_2.xlsx']);
% %             copyfile([W.PathProgs,'\multicore\AutoquantStatus.xlsx'],[W.PathGoogleDrive,'\Pipeline\AutoquantStatus.xlsx']);
% %             CDpath=['cd(''C:\Program Files (x86)\Google\Drive'');']; eval(CDpath);
% %         end
% %         inputemu('move',[100;100]); pause(0.5); inputemu('move',[200;200]);
% %         TimerGoogleDrive=datenum(now);
% %     end
    
    
    %% check through Input data, if job not taken within 10min then reset TaskID to 1
    InputFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Input']);
    for File=1:size(InputFiles,1)
        if InputFiles.Datenum(File)<datenum(now)-1/24/60*20 % delete after 20min
            Input=saveLoad_2(InputFiles.Path2file{File});
            try
                delete(InputFiles.Path2file{File});
                W.G.Pipeline.Status(Input.TimeStamp)=1;
            end
        end
    end
    
    %% check for Output data
%     OutputFiles=listAllFiles([W.PathProgs,'\multicore\Output']);
    OutputFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Output']);
    OutputFiles(OutputFiles.Bytes>1e+9|OutputFiles.Bytes==0,:)=[];
    for File=1:size(OutputFiles,1)
%         keyboard;
        clear Report;
        Output=saveLoad_2(OutputFiles.Path2file{File});
        TaskID=strfind1(W.G.Pipeline.Properties.RowNames,Output.TimeStamp);
        if TaskID~=0
            if isempty(Output.ErrorMessage) % successfully finished, iFile successfully integrated
                Report=1;
                W.G.Pipeline.Error{Output.TimeStamp}='Success!';
                W.G.Pipeline.Status(Output.TimeStamp)=0;
                cprintf('green',['Success. Slave: ',OutputFiles.FilenameTotal{File},', Filename: ',W.G.Pipeline.Filename{Output.TimeStamp},', Time: ',datestr(datenum(now),'yyyy.mm.dd HH:MM'),', TaskID: ',num2str(TaskID),'\n']);
            else % finished with error, but iFile successfully integrated
                Report=2;
                cprintf('err',['ERROR: Slave: ',OutputFiles.FilenameTotal{File},', Filename: ',W.G.Pipeline.Filename{Output.TimeStamp},', Time: ',datestr(datenum(now),'yyyy.mm.dd HH:MM'),', TaskID: ',num2str(TaskID),'\n']);
                cprintf('err',[Output.ErrorMessage,'\n']);
                W.G.Pipeline.Error{Output.TimeStamp}=Output.ErrorMessage;
                W.G.Pipeline.Status(Output.TimeStamp)=3;
            end
            [Wave1]=incorporateIdata(Output.IfileChanges);
            if Wave1==0 % Task was found but iFile could not be integrated
                Report=3;
                W.G.Pipeline.Status(Output.TimeStamp)=999;
                W.G.Pipeline.Error{Output.TimeStamp}='Error Ifile!';
                cprintf('err','Error Ifile!\n');
            end
            W.G.Pipeline.Duration(Output.TimeStamp)=round((datenum(now)-W.G.Pipeline.Datenum(Output.TimeStamp))*24*10)/10;
        else % Task was not found in Pipeline
            Report=0;
            cprintf('err','Task was not found among Pipeline!\n');
        end
        if Report==1 || Report==2
            BackupPath=[W.PathProgs,'\multicore\backup\Output\',OutputFiles.FilenameTotal{File}];
        elseif Report==0 || Report==3
            BackupPath=[W.PathProgs,'\multicore\backup\ErrorIfile\',OutputFiles.FilenameTotal{File}];
        end

        delete(OutputFiles.Path2file{File}); % movefile(OutputFiles.Path2file{File},BackupPath,'f'); % 
    end
    
    %% check which MatlabCores are available to receive new task
    % slaveStatus has to be present, Occupation must be 1, no InputFiles should be present, no Outputfile should be present
    StatusFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Status']); StatusFiles=StatusFiles(:,{'Filename';'Datenum';'Path2file'});
    InputFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Input']);
    OutputFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Output']);
%     Slave=1;
    for Slave=1:size(StatusFiles,1)
        StatusFiles.Command(Slave,1)={'Continue'};
        StatusFiles.Command2(Slave,1)={[' ']};
%         clear Status;
        SlaveName=StatusFiles.Filename{Slave};
%         StatusFiles.InputReport(Slave)=strfind1(InputFiles.FilenameTotal,SlaveName);
%         StatusFiles.OutputReport(Slave)=strfind1(OutputFiles.FilenameTotal,SlaveName);
%         StatusFiles.Recency(Slave)=(datenum(now)-StatusFiles.Datenum(Slave,1))*24*60;
        
        if strfind1(InputFiles.FilenameTotal,SlaveName)~=0 && strfind1(OutputFiles.FilenameTotal,SlaveName)~=0
            continue;
        end
%         if StatusFiles.Recency(Slave)>10
        if (datenum(now)-StatusFiles.Datenum(Slave,1))*24*60>10
            delete(StatusFiles.Path2file{Slave,1});
            StatusFiles.Available(Slave,1)=0;
            continue;
        end
        StatusFiles.Available(Slave,1)=1;
        Wave1=saveLoad_2(StatusFiles.Path2file{Slave,1});
        if isempty(Wave1)
            StatusFiles.Available(Slave,1)=0;
            continue;
        else
            Wave1=struct2table(Wave1,'AsArray',1);
        end
%         if exist('Status')~=1 || isempty(Status)
%             Status=struct; Status.Occupation=0;
%         end
%         StatusFiles=fuseTable_3(StatusFiles,struct2table(Status,'AsArray',1),[1,Slave]);
        StatusFiles(Slave,Wave1.Properties.VariableNames)=Wave1;
        Wave1=strfind1(W.G.SlaveList.Slave,SlaveName,1);
        if Wave1~=0
            StatusFiles.Command(Slave,1)=W.G.SlaveList.Command(Wave1); % for temporary tasks: quit, certain TaskID
            try;StatusFiles.Command2(Slave,1)=W.G.SlaveList.Command2(Wave1);end; % for constant tasks: random TaskID
%             try;
%                 StatusFiles.Command2(Slave,1)=W.G.SlaveList.Command2(Wave1);
%             catch
%                 StatusFiles.Command2(Slave,1)={''};
%             end
        end
    end
    
    if isempty(StatusFiles)==0
        StatusFiles=StatusFiles(StatusFiles.Available==1,:);
    end
    %% distribute tasks to slaves waiting for task
%     if size(SlaveStatus,1)==0
%         SlaveIDs=[];
%     else
%         SlaveIDs=find(SlaveStatus.Occupation==1).';
%     end
    for Slave=1:size(StatusFiles,1)
        SlaveName=StatusFiles.Filename{Slave};
        if strcmp(StatusFiles.Command{Slave},'Pause')
            continue;
        end
%         % set tasks of that computer still set to Status 2 to 3
%         Wave1=find(W.G.Pipeline.Status==2 & strcmp(W.G.Pipeline.Slave,StatusFiles.FilenameTotal{Slave}));
%         if isempty(Wave1)==0
%             W.G.Pipeline.Status(Wave1,1)=4;
%         end
        Path2SlaveInput=[W.PathSlaveDriver,'\Communication\Input\',SlaveName,'.mat'];
%         Path2SlaveInput=[W.PathProgs,'\multicore\Input\',StatusFiles.FilenameTotal{Slave}];
        TaskID=[];
        if strfind1(StatusFiles.Properties.VariableNames.','TaskID',1)~=0 && StatusFiles.TaskID(Slave)~=0 % Slave provides TaskID
            TaskID=StatusFiles.TaskID(Slave);
        end
        
        % exert commands from Pipeline
        if strfind1(StatusFiles.Command{Slave},'TaskID')
            TaskID=str2num(StatusFiles.Command{Slave}(7:end));
            W.G.SlaveList.Command(strfind1(W.G.SlaveList.Slave,StatusFiles.FilenameTotal{Slave}),1)={'SetContinue'};
        elseif strcmp(StatusFiles.Command{Slave},'Quit')
%             keyboard; % check if slaves does it
            Input=struct; Input.Quit=1;
            save(Path2SlaveInput,'Input');
            cprintf('cyan',['Quitting ',StatusFiles.Filename{Slave},'\n']);
            continue;
        end
        
        if isempty(TaskID) && (W.SkipError==0 || strcmp(StatusFiles.Command{Slave},'Stop')) % give control to keyboard
            showPipeline_2('Matlab2Excel');
            disp(['Slave: ',StatusFiles.Filename{Slave},', TaskID: ']);
            keyboard;
        end
        
        if isempty(TaskID)
%             keyboard;
            Undone=table;
            Undone.TaskID=find(floor(W.G.Pipeline.Status)==1);
            Undone.Status=W.G.Pipeline.Status(Undone.TaskID);
            if strfind1(StatusFiles.Command2{Slave},'Random')
                [~,Wave1]=sort(rand(size(Undone,1),1));
                Undone=Undone(Wave1,:);
            else
                Undone=sortrows(Undone,'Status');
            end
            for Row=Undone.TaskID.' % find task that is feasible for this slave
                % ComputerName
                try
                    Wave1=W.G.Pipeline.Restriction{Row,1}.ComputerName.Only;
                    if strfind1(StatusFiles.Filename{Slave},Wave1.')==0
                        continue;
                    end
                end
               
%                 % ImarisStatus
%                 if StatusFiles.Imaris(Slave)==0
%                     try
%                         Wave1=W.G.Pipeline.Restriction{Row,1}.ImarisStatus.Also;
%                     catch
%                         continue;
%                     end
%                 end
                TaskID=Row;
                break;
            end
        end
                
        
        if isempty(TaskID) % currently no task available
            continue;
        end
        
        W.G.Pipeline.Datenum(TaskID,1)=datenum(now);
        W.G.Pipeline.Error{TaskID}='';
        W.G.Pipeline.Clock{TaskID}=datestr(now,'mmm.dd HH:MM');
        Input=struct;
%         Input=table2struct(W.G.Pipeline(TaskID,:));
%         Input.PipelineEntry=table2struct(W.G.Pipeline(TaskID,:));
        Input.TimeStamp=W.G.Pipeline.Properties.RowNames{TaskID,1};
        Input.TaskID=TaskID;
        Input.Task=W.G.Pipeline.Task(TaskID);
        Input.File=W.G.Pipeline.File(TaskID);
        Input.Filename=W.G.Pipeline.Filename{TaskID};
        Input.Dofunction=W.G.Pipeline.Dofunction{TaskID};
%         Input.PathExp=W.PathExp;
        if strfind1(StatusFiles.Command{Slave},'TaskID') || (strfind1(StatusFiles.Properties.VariableNames.','TaskID',1)~=0 && StatusFiles.TaskID(Slave)~=0)
            Input.SkipError=0;
        else
            Input.SkipError=W.SkipError; % 0 if has to stop, 1 to continue
        end
%         Input.InputDrive=W.InputDrive;
%         Input.Path2W=W.Pathi;
%         Input.SingularImarisInstance=W.SingularImarisInstance;
        W.G.Pipeline.Status(TaskID)=2;
        W.G.Pipeline.Slave{TaskID}=SlaveName;
        cprintf('cyan',['Slave: ',SlaveName,', TaskID: ',num2str(TaskID),', Filename: ',W.G.Pipeline.Filename{TaskID},', Time: ',datestr(now,'yy.mm.dd HH:MM'),'\n']);
        save(Path2SlaveInput,'Input');
        try; delete(StatusFiles.Path2file{Slave,1}); end;
        pause(1);
    end
    %% always
    if isempty(find(W.G.Pipeline.Status==1|W.G.Pipeline.Status==2))
        W.Stop =1;
    end
    saveProject_2(0.5,12);
    if datenum(now)>TimerShowPipeline+1/24/60*10
        statusNotifyer(['ShowPipeline',datestr(datenum(now),'HH:MM:SS')]);
        showPipeline_2('Matlab2Excel');
        TimerShowPipeline=datenum(now);
    end
%     if isfield(W,'Keyboard')
%         W=rmfield(W,'Keyboard');
%         showPipeline('Matlab2Excel');
%         keyboard;
%     end
    
     pause(2);
end

%% finish
% saveProject();
showPipeline_2('Matlab2Excel');
excelViewer_2();
disp('Processing finished');

