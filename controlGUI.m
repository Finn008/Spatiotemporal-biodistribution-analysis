function varargout = controlGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @controlGUI_OpeningFcn, ...
    'gui_OutputFcn',  @controlGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function controlGUI_OpeningFcn(hObject, eventdata, handles, varargin) % --- Executes just before controlGUI is made visible.
keyboard; % still in use? 2015.10.09
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function varargout = controlGUI_OutputFcn(hObject, eventdata, handles) % --- Outputs from this function are returned to the command line.
% Get default command line output from handles structure
varargout{1} = handles.output;

function saveExcel_Callback(hObject, eventdata, handles)
global W; 
W.DoN=get(handles.versionChooser,'Value');

statusNotifyer('Save Excel started');
excelImporter();
statusNotifyer('Excel saved');

function taskManager_Callback(hObject, eventdata, handles)
global W; 
statusNotifyer('ExcelViewer started');

W.G.Task = get(hObject,'Value');
W.Task=get(hObject,'Value');
W.DoN=get(handles.versionChooser,'Value');
statusNotifyer('ExcelViewer started');
excelViewer();
set(handles.taskManager,'String',W.G.T.TaskName);
statusNotifyer('ExcelViewer done');

function saveProjects_Callback(hObject, eventdata, handles)
statusNotifyer('Save Projects started');
saveProject();
statusNotifyer('Project saved');

function projectBrowser_Callback(hObject, eventdata, handles)
global W;
statusNotifyer('Initializing ...');
initialize();
statusNotifyer('Initialization done');
set(handles.taskManager,'String',W.G.T.TaskName);

function jobCaller_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'GetSizeW';'DeleteEntriesW';'Keyboard';'SetClock';'ChooseReference';'UpdateRownames';'UpdateDoFunctions';'DeleteClock';'BackupMatlab'});

function jobCaller_Callback(hObject, eventdata, handles)
global W;
Selection=cellstr(handles.jobCaller.String);
Selection=Selection{get(hObject,'Value'),1};
statusNotifyer('Job caller started');
if strcmp(Selection,'GetSizeW')
    keyboard;
    [W.G.SizeL]=getVariableSize(W,'W');
elseif strcmp(Selection,'DeleteEntriesW')
    keyboard;
    changeStructChildren(W.G.SizeL);
elseif strcmp(Selection,'Keyboard')
    W.Keyboard=1;
elseif strcmp(Selection,'RemoveDuplets')
    keyboard;
    W.G.Error.FileDuplications;
    for m=1:size(AllFiles,1)-1
        PathTarget=[W.G.PathRaw.Path{1,1},'\remove\',AllFiles.FilenameTotal{m,1}];
        [Status,Message,Messageid] = movefile(AllFiles.Path2file{m,1},PathTarget,'f');
    end
elseif strcmp(Selection,'UpdateRownames')
    updateRownames();
elseif strcmp(Selection,'UpdateDoFunctions')
    Choice = questdlg('Choose!','','Open','Import','Open');
    Path=[W.PathExp,'\default\DoFunctions.xlsx'];
    if strcmp(Choice,'Open')
        
        winopen(Path);
    elseif strcmp(Choice,'Import')
        [~,~,Wave1]=xlsread(Path,1);
        W.G.DoFunctions=cell2table(Wave1(2:end,:),'VariableNames',Wave1(1,:),'RowNames',Wave1(2:end,1));
        
    end
elseif strcmp(Selection,'DeleteClock')
%     Wave2=inputdlg('Delete Clock before X days:','',1);
%     Wave2=str2num(Wave2{1});
%     Wave1=W.G.TaskList.Datenum-datenum(now)+Wave2;
%     W.G.TaskList.Clock(Wave1<0)={''};
%     showGuiTaskList();
elseif strcmp(Selection,'BackupMatlab')
    backupMatlab();
%     keyboard;
end
statusNotifyer('Job caller done');

function versionChooser_Callback(hObject, eventdata, handles)
global W; 
W.DoN = get(hObject,'Value');

function versionChooser_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function stopExcecution_Callback(hObject, eventdata, handles)
global W;
if W.Stop==1
    W.Stop=0;
    statusNotifyer('Start');
    set(handles.stopExcecution,'string','Stop');
    taskCaller_5(0,handles);
elseif W.Stop==0
    W.Stop=1;
    statusNotifyer('Stop');
    set(handles.stopExcecution,'string','Start');
end



function imarisKiller_Callback(hObject, eventdata, handles)
killImaris();

function doCurrentTask_Callback(hObject, eventdata, handles)
global W; 
statusNotifyer('DoFunction running');
% set(handles.notifier,'String','DoFunction running');
taskCaller_5(W.G.Task,hObject, eventdata, handles);
W.G.Task=W.Task;
statusNotifyer('DoCurrentTask done');

function doAllTasks_Callback(hObject, eventdata, handles)
global W; 
statusNotifyer('DoAllTask running');
taskCaller_5(0,hObject, eventdata, handles);
statusNotifyer('DoAllTask done');

function errorHandler_Callback(hObject, eventdata, handles)
global W;
if W.SkipError==1
    W.SkipError=0;
    set(handles.errorHandler,'string','stop on error');
elseif W.SkipError==0
    W.SkipError=1;
    set(handles.errorHandler,'string','skip error');
end

function processingSwitch_Callback(hObject, eventdata, handles)
global W;
if W.ProcessingType==1
    W.ProcessingType=2;
    set(handles.processingSwitch,'string','Multicore processing');
elseif W.ProcessingType==2
    W.ProcessingType=1;
    set(handles.processingSwitch,'string','Normal processing');
end

function taskChooser_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'All';'Current';'Fileinfo';'Autoquant';'ClearAll';'Fileinfo_Fct';'ClearSelection';'ZenInfoReader';'DisplayData';'SlaveSelect';'SwitchTasks'});


function taskChooser_Callback(hObject, eventdata, handles)
global W;
Selection=cellstr(handles.taskChooser.String);
Selection=Selection{get(hObject,'Value'),1};
J=struct; J.Selection1=Selection;
generateTaskList(J);
showPipeline('Matlab2Excel');
statusNotifyer('Selected tasks are integrated');

function uitable8_CellEditCallback(hObject, eventdata, handles)
global W;
Data=get(handles.uitable8,'data');
StatusInd=strfind1(get(handles.uitable8,'ColumnName'),'Status',1);
W.G.TaskList.Status=cell2mat(Data(:,StatusInd));

function autoquantStarter_Callback(hObject, eventdata, handles)

function taskManager_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function taskManager_ButtonDownFcn(hObject, eventdata, handles)
function taskManager_KeyPressFcn(hObject, eventdata, handles)
function notifier_CreateFcn(hObject, eventdata, handles)
