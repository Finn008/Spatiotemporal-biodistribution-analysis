function [Info]=loadProject_2()
global W;

% FileList=listAllFiles([W.PathSlaveDriver,'\Communication\Input']);

Wave1=struct2table(dir([W.PathSlaveDriver,'\Communication\Info\']));
Wave1=sortrows(Wave1(strfind1(Wave1.name,'Info_'),:),'datenum');

Info=saveLoad_2([W.PathSlaveDriver,'\Communication\Info\',Wave1.name{end}]);
% startup