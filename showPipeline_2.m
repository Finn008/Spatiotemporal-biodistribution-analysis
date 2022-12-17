function showPipeline_2(Direction)
global W;

if exist('Direction')~=1
    Direction='Excel2Matlab';
end

[~,Workbook]=connect2Excel([W.PathSlaveDriver,'\Excel\Pipeline.xlsx']);

%% make List of currently active slaves
SlaveList=table;
Ind=find(W.G.Pipeline.Status==2 & W.G.Pipeline.Datenum>datenum(now)-1); % only younger than 1 day
% StatusFiles=listAllFiles([W.PathSlaveDriver,'\Communication\Status']); StatusFiles=StatusFiles(:,{'Filename';'Datenum';'Path2file'});
if isempty(Ind)==0
    [Wave1,Wave2]=unique(W.G.Pipeline.Slave(Ind));
    Ind=Ind(Wave2);
    SlaveList.Slave=Wave1;
    SlaveList.TaskID(:,1)=Ind;
    SlaveList.LastJob=datestr(W.G.Pipeline.Datenum(Ind),'yyyy.mm.dd HH:MM');
    for m=1:size(SlaveList,1)
        SlaveList.JobDescription(m,1)={['Function: ',W.G.Pipeline.Dofunction{SlaveList.TaskID(m)},', Task: ',num2str(W.G.Pipeline.Task(SlaveList.TaskID(m))),', Filename: ',W.G.Pipeline.Filename{SlaveList.TaskID(m)}]};
    end
    SlaveStatus=listAllFiles([W.PathProgs,'\multicore\Status']);
    try % to circumvent empty SlaveStatus
        Wave1=strfind1(SlaveList.Slave,SlaveStatus.FilenameTotal,1);
        if Wave1~=0
            SlaveList(Wave1,:)=[];
        end
    end
    if size(SlaveList,1)==0
        SlaveList=table;
    end
    SlaveList.Slave(size(SlaveList,1)+1:size(SlaveList,1)+size(SlaveStatus,1),1)=SlaveStatus.FilenameTotal;
    SlaveList.Command(:,1)={'Continue'};
    
    Wave1=xlsActxGet(Workbook,'SlaveList',1);
    if isempty(Wave1)==0 && (strfind1(Wave1.Properties.VariableNames.','Command2')==0 || isnumeric(Wave1.Command2))
        Wave1.Command2=cell(size(Wave1,1),1);
    end
    for m=1:size(Wave1,1)
        Ind=strfind1(SlaveList.Slave,Wave1.Slave(m),1);
        if Ind~=0
            SlaveList.Command(Ind,1)=Wave1.Command(m);
            SlaveList.Command2(Ind,1)=Wave1.Command2(m);
        end
    end
    try
        W.G.SlaveList=sortrows(SlaveList,'Slave');
    end
end
%% get info from xls file
if strcmp(Direction,'Excel2Matlab')
    Pipeline=xlsActxGet(Workbook,'Pipeline');
    
    RowNames=regexprep(Pipeline(2:end,end),'Row','');
    Pipeline=cell2table([Pipeline(2:end,1:end-1),RowNames],'VariableNames',Pipeline(1,1:end),'RowNames',RowNames);
    % compare to W.G.Pipeline
    % remove any Row in W.G.Pipeline that is not present in Data
    Wave1=W.G.Pipeline(Pipeline.RowSpecifier,:);
    Wave1.Status=Pipeline.Status;
    Wave1.Notes=Pipeline.Notes;
    W.G.Pipeline=Wave1;
end

%% check if Pipeline entries are still correct, update step info
for m=1:size(W.G.Pipeline,1)
    if strcmp(W.G.Pipeline.ContainerName{m},'Single')
        continue;
    end
    try
        Filename=W.G.T.F{W.G.Pipeline.Task(m)}.Filename{W.G.Pipeline.Row{m}};
    catch
        Filename='';
    end
    if strcmp(Filename,W.G.Pipeline.Filename{m})==0
        % update File, Row
        Wave1=eval(W.G.Pipeline.ProxyPath{m});
        Wave2=strfind1(Wave1.Filename,W.G.Pipeline.Filename{m});
        if Wave2==0
            keyboard;
            W.G.Pipeline.Filename{m}='RemoveThisFile';
            continue;
        end
        W.G.Pipeline.File(m,1)=Wave2;
        W.G.Pipeline.Row(m,1)=Wave1.Properties.RowNames(Wave2);
    end
    W.G.Pipeline.Step(m)=W.G.T.F{W.G.Pipeline.Task(m)}{W.G.Pipeline.Row{m},W.G.Pipeline.CallerString{m}};
    try
        W.G.Pipeline.Notes(m)=W.G.T.F{W.G.Pipeline.Task(m)}{W.G.Pipeline.Row{m},'Notes'};
    end
end
W.G.Pipeline(strcmp(W.G.Pipeline.Filename,'RemoveThisFile'),:)=[];


%% put data into Pipeline.xlsx
ColumnNames={'Task';'Filename';'Dofunction';'Status';'Restriction';'Step';'Clock';'Duration';'Slave';'Error';'Notes'};
Pipeline=W.G.Pipeline(:,ColumnNames);
% keyboard; % take datenum to show Clock
Pipeline.Clock=datestr(W.G.Pipeline.Datenum,'dd.mm.yyyy HH:MM');
Pipeline.Duration=round2digit(Pipeline.Duration);
[Wave1]=taskRestrictor();
Pipeline.Restriction=Wave1.RestrictionList;

RowNames=strcat({'Row'},Pipeline.Properties.RowNames);
Pipeline=[[Pipeline.Properties.VariableNames,'RowSpecifier'];[table2cell(Pipeline),RowNames]];
try
    xlsActxWrite(Pipeline,Workbook,'Pipeline',[],'DeleteOnlyContent');
    xlsActxWrite(W.G.SlaveList,Workbook,'SlaveList',[],'DeleteOnlyContent');
    Workbook.Save;
end