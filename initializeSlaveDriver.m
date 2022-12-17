function initializeSlaveDriver()
global W;
% set(handles.stopExcecution,'string','Stop processing');
%% load anywhere

initializeAnywhere_2(); 

% W.InputDrive=5; % drive where stuff is deconvoluted and where enough space is available
W.ExcelViewerHeadLines=3;
W.SkipError=1;
W.TimerSave=datenum(now);
W.TimerBackup=datenum(now);
%% load after initializeAnywhere
% load([W.PathProgs,'\X0156.mat']);
% W.PathExp= uigetdir(X0156.DefaultPath,'Browse a path');
% W.Pathi=[W.PathExp,'\default\'];
% if W.PathExp==0; return; end;
% X0156.DefaultPath=W.PathExp;
% W.G.PathFinn=regexprep(W.PathExp,'\Analysis','');
% save([W.PathProgs,'\X0156.mat'],'X0156');
% W.PathExportXlsx=[W.PathProgs,'\Export',W.ComputerInfo.ExcelVersion];
% W.PathGoogleDrive='\\GNP454n\C\Users\fipeter\Google Drive\Analysis';



% Out=load([W.Pathi,'I~.mat']);
% keyboard; % replace with direct loading
% W.Pathi='C:\Users\n4y\OneDrive\Matlab\SlaveDriver\';
% Isaving=saveLoad_2([W.Pathi,'I~.mat']);

% W.G.PathOut=[W.PathExp,'\Output'];
% W.SingularImarisInstance=1;
% W.Task = W.G.Task;
% W.TimeDelay=0;

% Wave1=[PathSlaveDriver,'\TaskLists'];
Wave1=listAllFiles([W.PathSlaveDriver,'\Excel']);
Wave1=Wave1.FilenameTotal(strncmp(Wave1.FilenameTotal,'TaskList',8),:);
% Wave1=struct2table(dir([W.PathSlaveDriver,'\TaskLists']));

% Wave1=Wave1.name(strfind1(Wave1.name,'.xlsx'));
W.TaskLists=regexprep(Wave1,'.xlsx','');
% W.TaskLists={'GENERAL_INFO';'TaskList_2'};
W.CurrentTaskList=W.TaskLists{1,1};
W.Stop=1;

% % % Choice = questdlg('Update Rownames?','','Yes','No','No');
% % % if strcmp(Choice,'Yes')
% % %     updateRownames();
% % % end
showPipeline_2('Matlab2Excel');
excelViewer_2();

% evalin('caller','global W;');
