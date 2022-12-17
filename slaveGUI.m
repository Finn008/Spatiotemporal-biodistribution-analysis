function varargout = slaveGUI(varargin)
% SLAVEGUI MATLAB code for slaveGUI.fig
%      SLAVEGUI, by itself, creates a new SLAVEGUI or raises the existing
%      singleton*.
%
%      H = SLAVEGUI returns the handle to a new SLAVEGUI or the handle to
%      the existing singleton*.
%
%      SLAVEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLAVEGUI.M with the given input arguments.
%
%      SLAVEGUI('Property','Value',...) creates a new SLAVEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before slaveGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to slaveGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help slaveGUI

% Last Modified by GUIDE v2.5 01-Apr-2015 17:29:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @slaveGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @slaveGUI_OutputFcn, ...
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


% --- Executes just before slaveGUI is made visible.
function slaveGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to slaveGUI (see VARARGIN)
global handles;


% Choose default command line output for slaveGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes slaveGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = slaveGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% taskExecuter();


% --- Executes on button press in stopProcessing.
function stopProcessing_Callback(hObject, eventdata, handles)
global W;
W.Stop=1;

function pauseProcessing_Callback(hObject, eventdata, handles)
global W;
Wave1 = inputdlg('Enter pause duration in hours:','Pause dialog',1);
try 
    Wave1 = str2num(Wave1{1,1});
    W.Stop=Wave1*60*60;
end

function startProcessing_Callback(hObject, eventdata, handles)
global W;
taskExecuter();


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
global W;
Selection=cellstr(handles.popupmenu1.String);
Selection=Selection{get(hObject,'Value'),1};
if strcmp(Selection,'Keyboard')
    W.Keyboard=1;
elseif strcmp(Selection,'StartLater')
    PauseTime=inputdlg('Time in hours:','Start later');
    if strcmp(PauseTime,'AQ')==0
        PauseTime=str2num(PauseTime{:});
    end
    SelectionList={'None';'Close Autoquant before'};
    [Selection] = listdlg('PromptString','Select Tasks to be deleted:','SelectionMode','single','ListString',SelectionList);
    if strcmp(PauseTime,'AQ')
        [ComputerLoad]=autoquantRunning();
    else
    pause(PauseTime*60*60);
    end
    if Selection==2
        [status,cmdout] = dos('taskkill /f /im aqiPlatform.exe');
        [status,cmdout] = dos('taskkill /f /im ImarisServerIce.exe');
    end
    pause(10);
    taskExecuter();
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
