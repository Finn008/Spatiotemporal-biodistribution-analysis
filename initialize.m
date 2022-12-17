function initialize()
global W;
% set(handles.stopExcecution,'string','Stop processing');
%% load anywhere
initializeAnywhere(); 

W.InputDrive=5; % drive where stuff is deconvoluted and where enough space is available
W.ExcelViewerHeadLines=3;
W.SkipError=1;
%% load after initializeAnywhere
load([W.PathProgs,'\X0156.mat']);
W.PathExp= uigetdir(X0156.DefaultPath,'Browse a path');
W.Pathi=[W.PathExp,'\default\'];
if W.PathExp==0; return; end;
X0156.DefaultPath=W.PathExp;
W.G.PathFinn=regexprep(W.PathExp,'\Analysis','');
save([W.PathProgs,'\X0156.mat'],'X0156');
W.PathExportXlsx=[W.PathProgs,'\Export',W.ComputerInfo.ExcelVersion];
W.PathGoogleDrive='\\GNP454n\C\Users\fipeter\Google Drive\Analysis';

I=loadProject;
W=catstruct(W,I); % put contents of I into W
W.G.PathOut=[W.PathExp,'\Output'];
W.SingularImarisInstance=1;
W.Task = W.G.Task;
W.TimeDelay=0;
W.TaskLists={'GENERAL_INFO';'TaskList_2'};
W.TaskListID=W.TaskLists{1,1};
W.Stop=1;

% % % Choice = questdlg('Update Rownames?','','Yes','No','No');
% % % if strcmp(Choice,'Yes')
% % %     updateRownames();
% % % end
showPipeline('Matlab2Excel');
excelViewer();

evalin('caller','global W;');
