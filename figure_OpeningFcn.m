function figure_OpeningFcn(hObject, eventdata, handles,varargin)

%// This function has no output args, see OutputFcn.
%// hObject    handle to figure
%// eventdata  reserved - to be defined in a future version of MATLAB
%// handles    structure with handles and user data (see GUIDATA)
%// varargin   command line arguments to DatabaseViewerApp (see VARARGIN)

%// Choose default command line output for DatabaseViewerApp
handles.output = hObject;

%// Update handles structure
guidata(hObject, handles);
%// UIWAIT makes DatabaseViewerApp wait for user response (see UIRESUME)
%// uiwait(handles.mainFigure);

    %//set the current figure handle to main application data
    setappdata(0,'figureHandle',gcf);

    %//set the axes handle to figure's application data
    setappdata(gcf,'axesHandle1',handles.axes6);

    %//set the axes handle to figure's application data
    setappdata(gcf,'axesHandle2',handles.axes7);

end

function varargout = func1(varargin)

%// get the figure handle from the application main data
figureHandle = getappdata(0,'figureHandle');

%// get the axes handle from the figure data
axesHandle1 = getappdata(figureHandle,'axesHandle1');

%// get the axes handle from the figure data
axesHandle2 = getappdata(figureHandle,'axesHandle2');

%// And here you can write your own code using your axes

end


% set(handles.text6,'String','Initialization done');