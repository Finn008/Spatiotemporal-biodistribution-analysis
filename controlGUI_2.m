function varargout = controlGUI_2(varargin)
% CONTROLGUI_2 MATLAB code for controlGUI_2.fig
%      CONTROLGUI_2, by itself, creates a new CONTROLGUI_2 or raises the existing
%      singleton*.
%
%      H = CONTROLGUI_2 returns the handle to a new CONTROLGUI_2 or the handle to
%      the existing singleton*.
%
%      CONTROLGUI_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLGUI_2.M with the given input arguments.
%
%      CONTROLGUI_2('Property','Value',...) creates a new CONTROLGUI_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before controlGUI_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to controlGUI_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help controlGUI_2

% Last Modified by GUIDE v2.5 06-Jun-2018 16:30:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @controlGUI_2_OpeningFcn, ...
    'gui_OutputFcn',  @controlGUI_2_OutputFcn, ...
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
end


function controlGUI_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to controlGUI_2 (see VARARGIN)

% Choose default command line output for controlGUI_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes controlGUI_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = controlGUI_2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function projectBrowser_Callback(hObject, eventdata, handles)

statusNotifyer('Initializing ...');
initializeSlaveDriver();
global W;
set(handles.taskManager,'String',W.TaskLists);
statusNotifyer('Initialization done');
end

function saveExcel_Callback(hObject, eventdata, handles)
global W;
statusNotifyer('Save Excel started');
excelImporter_2();
statusNotifyer('Excel saved');
end

function saveProjects_Callback(hObject, eventdata, handles)
% keyboard;
% statusNotifyer('Save Projects started');
saveProject_2();
% statusNotifyer('Project saved');
end

function errorHandler_Callback(hObject, eventdata, handles)
% keyboard;
global W;
if W.SkipError==1
    W.SkipError=0;
    set(handles.errorHandler,'string','stop on error');
elseif W.SkipError==0
    W.SkipError=1;
    set(handles.errorHandler,'string','skip error');
end
end

function stopExecution_Callback(hObject, eventdata, handles)
global W;
if W.Stop==1
    set(handles.stopExecution,'string','Stop');
    statusNotifyer('Processing...');
    W.Stop=0;
    taskCaller_6();
elseif W.Stop==0
    set(handles.stopExecution,'string','Start');
    statusNotifyer('Stop processing...');
    W.Stop=1;
end
end

function taskManager_Callback(hObject, eventdata, handles)
% keyboard;
global W;
statusNotifyer('ExcelViewer started');
% W.G.Task = get(hObject,'Value');
% W.Task=get(hObject,'Value');
% W.DoN=get(handles.versionChooser,'Value');
W.CurrentTaskList=W.TaskLists{get(hObject,'Value')};
% statusNotifyer('ExcelViewer started');
excelViewer_2();
set(handles.taskManager,'String',W.TaskLists);
% set(handles.taskManager,'String',W.G.T.TaskName);
statusNotifyer('ExcelViewer done');
end

function taskManager_CreateFcn(hObject, eventdata, handles)
% keyboard;
% global W;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function taskChooser_Callback(hObject, eventdata, handles)
statusNotifyer('Task beeing processed...');
% keyboard;
Selection=cellstr(handles.taskChooser.String);
Selection=Selection{get(hObject,'Value'),1};
% J=struct; J.Selection1=;

if strcmp(Selection,'Current')
%     keyboard; % check why new tasks have two time "Row" as Rowspecifier in Pipeline
    generatePipeline_2(Selection);
    showPipeline_2('Matlab2Excel');
elseif strcmp(Selection,'GetSizeW')
    keyboard; % previously [W.G.SizeL]=getVariableSize(W,'W');
    getVariableSize(W.G,'WG');
elseif strcmp(Selection,'DeleteEntriesW')
    keyboard;
    changeStructChildren(W.G.SizeL);
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
elseif strcmp(Selection,'BackupMatlab')
    backupMatlab();
elseif strcmp(Selection,'TaskListConsistency')
    Wave2=W.G.TaskList;
    for m=1:size(W.G.TaskList,1)
        Wave1=W.G.T.F{W.G.TaskList.Task(m)}{W.G.TaskList.File(m),'Filename'}{1};
        if strfind1(W.G.TaskList.Filename{m},Wave1)
            
        else
            Wave2.Inequal(m,1)=1;
        end
    end
elseif strcmp(Selection,'ExchangeFileName')
    exchangeFileName();
    
end
statusNotifyer('Task finished');
end

function taskChooser_CreateFcn(hObject, eventdata, handles)
% keyboard;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',{'Current';'BackupMatlab';'GetSizeW';'UpdateDoFunctions';'UpdateRownames';'TaskListConsistency';'ExchangeFileName'}); % set(hObject,'String',{'All';'Current';'Fileinfo';'Autoquant';'ClearAll';'Fileinfo_Fct';'ClearSelection';'ZenInfoReader';'DisplayData';'SlaveSelect';'SwitchTasks';'GetSizeW'});
% set(hObject,'String',{'GetSizeW';'DeleteEntriesW';'Keyboard';'SetClock';'ChooseReference';'UpdateRownames';'UpdateDoFunctions';'DeleteClock';'BackupMatlab';'TaskListConsistency';'ExchangeFileName'});
end

function jobCaller_CreateFcn(hObject, eventdata, handles)
% keyboard;
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% set(hObject,'String',{'GetSizeW';'DeleteEntriesW';'Keyboard';'SetClock';'ChooseReference';'UpdateRownames';'UpdateDoFunctions';'DeleteClock';'BackupMatlab';'TaskListConsistency';'ExchangeFileName'});
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
end

function jobCaller_Callback(hObject, eventdata, handles)

end

function showPipeline_Callback(hObject, eventdata, handles)
% keyboard;
showPipeline_2('Matlab2Excel');
statusNotifyer('Pipeline updated');
end

function savePipeline_Callback(hObject, eventdata, handles)
% keyboard;
showPipeline_2();
statusNotifyer('Pipeline updated');
end
