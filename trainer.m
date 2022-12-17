function varargout = trainer(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trainer_OpeningFcn, ...
                   'gui_OutputFcn',  @trainer_OutputFcn, ...
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


% --- Executes just before trainer is made visible.
function trainer_OpeningFcn(hObject, eventdata, handles, varargin)
global W;
initializeTrainer(handles);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = trainer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function taskChooser_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function taskChooser_Callback(hObject, eventdata, handles)
global W;
Contents = cellstr(get(hObject,'String'));
Selection=Contents{get(hObject,'Value')};
if strcmp(W.TaskChooserState,'Main')
    if strcmp(Selection,'Initialize')
        initializeTrainer(handles);
        global W;
    elseif strcmp(Selection,'Excel2Matlab')
        keyboard;
%         extractVocXls('Excel2Matlab');
    elseif strcmp(Selection,'Matlab2Excel')
        keyboard;
        extractVocXls('Matlab2Excel');
    elseif strcmp(Selection,'SaveVocs')
        disp('SaveVocs started');
        saveVocs();
        trainer_Matlab2Excel()
        disp('SaveVocs finished');
    elseif strcmp(Selection,'ChooseTopic')
        addTopic2Chunk(handles)
    elseif strcmp(Selection,'OpenExcel')
        winopen(W.Path2Excel);
    end
elseif strcmp(W.TaskChooserState,'AddTopic2Chunk')
    addTopic2Chunk(handles,Selection);
end

function vocSwitch_Callback(hObject, eventdata, handles)
global W;
if W.VocStatus==1 % next question
    trainer_showVoc('Question');
    W.VocStatus=2;
    set(handles.vocSwitch,'String','Answer');
elseif W.VocStatus==2 % answer
    trainer_showVoc('Answer');
    W.VocStatus=1;
    set(hObject,'String','Next');
end

function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ratingMenu_Callback(hObject, eventdata, handles)
global W;
Contents = cellstr(get(hObject,'String'));
Selection=Contents{get(hObject,'Value')};
if strcmp(Selection,'Quality')
    keyboard; % open edit menu to enter quality value
elseif strcmp(Selection,'OutChunk2')
    W.Voc.Selection(W.VocInd,1)=NaN;
    W.VocStatus=1;
    set(handles.vocSwitch,'String','Next');
elseif strcmp(Selection,'StoreChanges')
    Wave1=char(W.JEditbox.getText());
    Ind=strfind(Wave1,'###').';
    % extract changes in Answer and Question
    % extract bottom info
    Wave2=Wave1(Ind(2)+3:Ind(3)-1);
    Wave1=variableExtract(Wave2);
    Fieldnames=fieldnames(Wave1);
    for m=Fieldnames.'
        if isequal(W.OrigStoreChanges.(m{1}),Wave1.(m{1}))==0
            W.Voc{W.VocInd,m}{1}=Wave1.(m{1});
            W.Matlab2ExcelUpdate(end+1,1)=m;
        end
    end
end

function ratingMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkWrong_Callback(hObject, eventdata, handles)
global W;
% keyboard;
trainer_successTracker(-1,handles);
% Wave1=W.Chunk(1,:);
% W.Chunk(1,:)=[];
% W.Chunk=[W.Chunk;Wave1];

function checkCorrect_Callback(hObject, eventdata, handles)
% keyboard;
trainer_successTracker(1,handles);
% successTracker(1,handles);

function topicChooser_Callback(hObject, eventdata, handles)
global W;

function topicChooser_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
