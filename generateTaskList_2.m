function generateTaskList_2(Selection)
% v2struct(In);
global W;
% if strcmp(Selection,'SlaveSelect')
%     Wave1={'brain-pc';'dexter';'gnp454n'};
%     [Ind,A2] = listdlg('PromptString','Select a computer:','SelectionMode','single','ListString',Wave1);
%     W.SelectedComputer=Wave1{Ind,1};
%     return;
% end
% if strcmp(Selection,'SwitchTasks')
%     Wave1 = inputdlg({'SourceTask','Put before Row:'},'Customer',[1,20;1,20]);
%     Source=str2num(Wave1{1,1}).';
%     Target=str2num(Wave1{2,1});
%     
%     if Target==0
%        W.G.Pipeline(Source,:)=[];
%        return;
%     end
%     
%     Wave1=W.G.Pipeline;
%     Wave1.Properties.RowNames(Source)=strcat({'Remove'},num2strArray(Source));
%     Wave2=W.G.Pipeline(Source,:);
%        
%     Wave1=[Wave1(1:Target-1,:);Wave2;Wave1(Target:end,:)];
%     Wave1(strfind1(Wave1.Properties.RowNames,'Remove'),:)=[];
%     W.G.Pipeline=Wave1;
%     return;
% end
TaskContainers= {
    'Single','W.G.SingleTasks';
    'SubTask','W.G.T.F';
    'Fileinfo','W.G.Fileinfo';
    'SuperTask','W.G.T';
    };
TaskContainers=cell2table(TaskContainers,'VariableNames',{'Name';'ProxyPath'},'RowNames',TaskContainers(:,1));
DoFunctions=W.G.DoFunctions;

DoFunctions.Restriction{1}=struct;
if isfield(W,'SelectedComputer') && isempty(W.SelectedComputer)==0
    keyboard;
    DoFunctions.Restriction{1}.ComputerName.Only=W.SelectedComputer;
    W.SelectedComputer=[];
end
DoFunctions.Restriction(:)=DoFunctions.Restriction(1);

if strcmp(Selection,'GetSizeW')
    DoFunctions.Restriction{'GetSizeW'}.ImarisStatus.Also=0;
    W.G.SingleTasks.GetSizeW(1)={'Do#Go|'};
    TaskContainers=TaskContainers('Single',:);
    DoFunctions=DoFunctions('GetSizeW',:);
elseif strcmp(Selection,'Autoquant')
    Wave1={'brain-pc';'gnp454n'};
    [Ind,A2] = listdlg('PromptString','Select a computer:','SelectionMode','single','ListString',Wave1);
    DoFunctions.Restriction{'DoAutoquant'}.ComputerName.Only=Wave1{Ind,1};
    DoFunctions.Restriction{'DoAutoquant'}.ImarisStatus.Also=0;
    W.G.SingleTasks.DoAutoquant(1)={'Do#Go|'};
    TaskContainers=TaskContainers('Single',:);
    DoFunctions=DoFunctions('DoAutoquant',:);
elseif strcmp(Selection,'ZenInfoReader')
    Wave1={'brain-pc';'gnp454n'};
    [Ind,A2] = listdlg('PromptString','Select a computer:','SelectionMode','single','ListString',Wave1);
    DoFunctions.Restriction{'DoZenInfo'}.ComputerName.Only=Wave1{Ind,1};
    DoFunctions.Restriction{'DoZenInfo'}.ImarisStatus.Also=0;
    W.G.SingleTasks.DoZenInfo(1)={'Do#Go|'};
    TaskContainers=TaskContainers('Single',:);
    DoFunctions=DoFunctions('DoZenInfo',:);
elseif strcmp(Selection,'DisplayData')
    DoFunctions.Restriction{'DoDisplayData'}.ImarisStatus.Also=0;
    W.G.SingleTasks.DoDisplayData(1)={'Do#Go|'};
    TaskContainers=TaskContainers('Single',:);
    DoFunctions=DoFunctions('DoDisplayData',:);
elseif strcmp(Selection,'Current')
    TaskContainers=TaskContainers('SubTask',:);
    % choose Task
    [Ind,A2] = listdlg('PromptString','Select a Task:','SelectionMode','single','ListString',W.G.T.TaskName);
    CurrentTask=Ind;
    % choose function
    [Ind,A2] = listdlg('PromptString','Select a function:','SelectionMode','single','ListString',['All';DoFunctions.CallerString]);
    Ind=Ind-1;
    if Ind~=0
        DoFunctions=DoFunctions(DoFunctions.CallerString{Ind,1},:);
    end
    % choose File
    [Ind,A2] = listdlg('PromptString',['From ',W.G.T.TaskName{CurrentTask},' select a File:'],'SelectionMode','single','ListString',['All';W.G.T.F{CurrentTask,1}.Filename]);
    CurrentFile=Ind-1;
    
elseif strcmp(Selection,'Fileinfo')
    TaskContainers=TaskContainers('Fileinfo',:);
elseif strcmp(Selection,'Fileinfo_Fct')
    [Ind,A2] = listdlg('PromptString','Select a function:','SelectionMode','single','ListString',DoFunctions.CallerString);
    DoFunctions=DoFunctions(DoFunctions.CallerString{Ind,1},:);
    TaskContainers=TaskContainers('Fileinfo',:);
elseif strcmp(Selection,'ClearAll')
    W.G.Pipeline=table;
    return;
elseif strfind1(Selection,'ClearSelection')
    [Ind,A2] = listdlg('PromptString','Select Tasks to be deleted:','SelectionMode','single','ListString',{'All except Status 2'});
    if Ind==1
        W.G.Pipeline=W.G.Pipeline(W.G.Pipeline.Status==2,:);
    end
    return;
end



Pipeline=emptyRow(W.G.Pipeline);
% TaskList=table;
for m1=TaskContainers.Properties.RowNames.'
    SuperProxy=eval(TaskContainers.ProxyPath{m1,1});
    if istable(SuperProxy)
        SuperProxy={SuperProxy};
        SubTask=0;
    else
        SubTask=1;
    end
        
    for m2=1:size(SuperProxy,1)
        Proxy=SuperProxy{m2,1};
        % name the rows if necessary
        if isempty(Proxy.Properties.RowNames)
            RowNames=cellstr(num2str([1:size(Proxy,1)].'));
            RowNames=regexprep(RowNames,' ','');
            Proxy.Properties.RowNames=RowNames;
            if SubTask==1
                Path=([TaskContainers.ProxyPath{m1,1},'{m2,1}=Proxy;']);
            else
                Path=([TaskContainers.ProxyPath{m1,1},'=Proxy;']);
            end
            eval(Path);
        end
        
        for m3=DoFunctions.CallerString.'
            if strfind1(Proxy.Properties.VariableNames,m3,1)
                DoColumn=strfind1(Proxy{:,m3}(:,1),'Do#Go');
                DoColumn(DoColumn==0,:)=[];
                for m4=DoColumn.'
                    Ind=size(Pipeline,1)+1;
%                     keyboard; % remove TaskList.Info
%                     TaskList.Info(Ind,1)={Proxy(m4,:)};
                    Pipeline.Task(Ind,1)=m2;
                    Pipeline.File(Ind,1)=m4;
                    Pipeline.Row(Ind,1)=Proxy.Properties.RowNames(m4,1);
                    Pipeline.Dofunction(Ind,1)=DoFunctions.Dofunction(m3,1);
                    Pipeline.CallerString(Ind,1)=m3;
%                     keyboard;
                    if strcmp(TaskContainers.Name{m1,1},'SubTask')
                        Path=([TaskContainers.ProxyPath{m1,1},'{',num2str(m2),',1}']);
                    elseif strcmp(TaskContainers.Name{m1,1},'Single')
                        Path=([TaskContainers.ProxyPath{m1,1}]);
                    end
                    Pipeline.ProxyPath(Ind,1)={Path};
                    Pipeline.Status(Ind,1)=1;
                    Pipeline.TimeStamp(Ind,1)={''};
                    Pipeline.Restriction(Ind,1)=DoFunctions{m3,'Restriction'};
                    Pipeline.Error(Ind,1)={''};
                    Pipeline.Clock(Ind,1)={''};
                    Pipeline.Slave(Ind,1)={''};
                    Pipeline.ContainerName(Ind,1)=TaskContainers.Name(m1,1);
                    try
%                         TaskList.Filename(Ind,1)={[Proxy.Filename{m4},' (',num2str(m4),')']};
                        Pipeline.Filename(Ind,1)={Proxy.Filename{m4}};
                    catch
                        Pipeline.Filename(Ind,1)={[num2str(m4)]};
                    end
                    Pipeline.Properties.RowNames{Ind,1}=uniqueInd([],[2;6]);
                    
                end
            end
        end
    end
end
% keyboard; % for SingleTasks ProxyPath should end up in 'W.G.SingleTasks' not 'W.G.SingleTasks{1,1}'

% W.G.SingleTasks.DoAutoquant(1)={'DoDone|'};
if size(W.G.SingleTasks,1)>0
    W.G.SingleTasks{1,1:end}={[]};
    Pipeline(1,:)=[];
%     W.G.SingleTasks.Filename(1)={'Single'};
%     keyboard; % donot delete but set to []
%     W.G.SingleTasks(1,:)=[];
end
if strcmp(Selection,'Current')
%     keyboard;
    Pipeline(Pipeline.Task~=CurrentTask,:)=[];
    if CurrentFile~=0
        Pipeline(Pipeline.File~=CurrentFile,:)=[];
    end
end

% keyboard; % check if RowNames of W.G.Pipeline remain or are changed, what RowNames are used for added files?
if isfield(W.G,'TaskList')
    % check if Pipeline and Tasks are aligned
%     for m=1:size(W.G.Pipeline,1)
%         Wave1=W.G.T{W.G.Pipeline.Task{m}.F{W.G.Pipeline.File{m}}};
%     end
    
    % check which Tasks are already in
    for m=1:size(Pipeline,1)
        Wave1=find(W.G.Pipeline.Task==Pipeline.Task(m)&W.G.Pipeline.File==Pipeline.File(m)&strcmp(W.G.Pipeline.Dofunction,Pipeline.Dofunction{m}));
        if isempty(Wave1)==0
%             W.G.Pipeline.Status(Wave1,1)=1;
            Pipeline.Task(m,1)=-100;
        end
    end
    Pipeline(Pipeline.Task==-100,:)=[];
    keyboard;
    W.G.Pipeline=[W.G.Pipeline;Pipeline]; % add to end
%     W.G.Pipeline=[TaskList;W.G.Pipeline]; % add to beginning
else
    W.G.Pipeline=Pipeline;
end
    
