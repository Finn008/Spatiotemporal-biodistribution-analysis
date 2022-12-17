function showPipeline(Direction)
keyboard; % replaced by showPipeline_2
global W;

if exist('Direction')~=1
    Direction='Excel2Matlab';
end

Path=[W.PathExp,'\default\Excel\Pipeline_2.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path);



%% make SlaveList
Ind=find(W.G.TaskList.Status==2 & W.G.TaskList.Datenum>datenum(now)-1); % only younger than 1 day
[Wave1,Wave2,Wave3]=unique(W.G.TaskList.Slave(Ind));
Ind=Ind(Wave2);
if size(Ind,1) ~= size(Wave1,1)
    keyboard;
    Wave1=W.G.TaskList.Slave(Ind);
end

SlaveList=table;
SlaveList.Slave=Wave1;
SlaveList.TaskID(:,1)=Ind;
SlaveList.LastJob=datestr(W.G.TaskList.Datenum(Ind),'yyyy.mm.dd HH:MM');
for m=1:size(SlaveList,1)
    SlaveList.JobDescription(m,1)={['Function: ',W.G.TaskList.Dofunction{SlaveList.TaskID(m)},', Task: ',num2str(W.G.TaskList.Task(SlaveList.TaskID(m))),', Filename: ',W.G.TaskList.Filename{SlaveList.TaskID(m)}]};
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
% SlaveList.Slave(end+1:size(SlaveList,1)+end,1)=SlaveStatus.FilenameTotal;
% SlaveList.Slave(1)={[]};
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

%% get info from xls file
if strcmp(Direction,'Excel2Matlab')
    Pipeline=xlsActxGet(Workbook,'Pipeline');
    
    RowNames=regexprep(Pipeline(2:end,end),'Row','');
    Pipeline=cell2table([Pipeline(2:end,1:end-1),RowNames],'VariableNames',Pipeline(1,1:end),'RowNames',RowNames);
    % compare to W.G.TaskList
    % remove any Row in W.G.TaskList that is not present in Data
    Wave1=W.G.TaskList(Pipeline.RowSpecifier,:);
    Wave1.Status=Pipeline.Status;
    Wave1.Notes=Pipeline.Notes;
    W.G.TaskList=Wave1;
end

%% check if Tasklist entries are still correct, update step info
for m=1:size(W.G.TaskList,1)
    if strcmp(W.G.TaskList.ContainerName{m},'Single')
    else
        try
            Filename=W.G.T.F{W.G.TaskList.Task(m)}.Filename{W.G.TaskList.Row{m}};
        catch
            Filename='';
        end
        if strcmp(Filename,W.G.TaskList.Filename{m})==0
            % update File, Row
            Wave1=eval(W.G.TaskList.ProxyPath{m});
            Wave2=strfind1(Wave1.Filename,W.G.TaskList.Filename{m});
            if Wave2==0; keyboard; end;
            W.G.TaskList.File(m,1)=Wave2;
            W.G.TaskList.Row(m,1)=Wave1.Properties.RowNames(Wave2);
        end
        W.G.TaskList.Step(m)=W.G.T.F{W.G.TaskList.Task(m)}{W.G.TaskList.Row{m},W.G.TaskList.CallerString{m}};
        try
            W.G.TaskList.Notes(m)=W.G.T.F{W.G.TaskList.Task(m)}{W.G.TaskList.Row{m},'Notes'};
        end
    end
end


%% put data into Pipeline.xlsx
ColumnNames={'Task';'Filename';'Dofunction';'Status';'Restriction';'Step';'Clock';'Duration';'Slave';'Error';'Notes'};
Pipeline=W.G.TaskList(:,ColumnNames);
% keyboard; % take datenum to show Clock
Pipeline.Clock=datestr(W.G.TaskList.Datenum,'dd.mm.yyyy HH:MM');
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

%% showGuiTaskList
handles = findall(0,'type','figure','Name','controlGUI_2');
handles=guidata(handles(1,1));
if isempty(W.G.TaskList)
    set(handles.uitable8,'Data',[]);
    Pipeline=table;
else
    Table={'Task',0,30;...
        'Filename',0,150;...
        'Dofunction',0,80;...
        'Status',1,40;...
        'Restriction',0,60;...
        'Step',0,100;...
        'Clock',0,80;...
        'Duration',0,60;...
        'Slave',0,'auto';...
        'Error',0,100;...
        'Notes',0,200};
    Table=cell2table(Table,'VariableNames',{'Name','Editable','Width'});
    Table.Editable=logical(Table.Editable);
%     set(handles.uitable8,'Data',Pipeline(2:end,1:end-1),'ColumnName',Pipeline(1,1:end-1));
%     set(handles.uitable8,'ColumnEditable',Table.Editable.');
%     set(handles.uitable8,'ColumnWidth',Table.Width.');
    
end
