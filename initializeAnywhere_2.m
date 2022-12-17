function initializeAnywhere_2()
global W;
W=struct;

W.PathProgs=fileparts(mfilename('fullpath'));
% 'C:\Users\Depp\OneDrive\Matlab\Programs\Finns programs'
% W.PathSlaveDriver=regexprep(W.PathProgs,'Programs\Finns programs','SlaveDriver');
W.PathSlaveDriver=strrep(W.PathProgs,'Programs\Finns programs','SlaveDriver');
% W.PathSlaveDriver='C:\Users\n4y\OneDrive\Matlab\SlaveDriver';
Wave1=loadProject_2;
W=catstruct(W,Wave1); % put contents of I into W

% get info on computer
W.ComputerName=getComputerName();
W.PathExp=W.G.ComputerInfo.Path2RawData{strcmp(W.G.ComputerInfo.Name,W.ComputerName)};
W.SlaveInstance=datestr(datenum(now),'mmddHHMMSSFFF');

%% Imaris
W.Imaris.PathImarisSample=[W.PathProgs,'\ImarisSample.ims'];
W.Imaris.ImarisVersion=regexprep(W.G.ComputerInfo.ImarisVersion{strcmp(W.G.ComputerInfo.Name,W.ComputerName)},'\','');
cd(['C:\Program Files\Bitplane\Imaris x64 ',W.Imaris.ImarisVersion,'\XT\matlab']);
javaaddpath ImarisLib.jar;
W.Imaris.ImarisLib=ImarisLib;
W.Imaris.Instances=table; %{0,'',0}; W.Imaris.Instances=cell2table(W.Imaris.Instances,'VariableNames',{'Id';'Char';'Status'}); W.Imaris.Instances(1,:)=[];
% W.Imaris.DefaultImarisVersion='7.7.2';
% W.Imaris.SingularImarisInstance=0;
% if isfield(W.Imaris,'ImarisLib')==0 || isempty(W.Imaris.ImarisLib)
%     OrigW=W; %Wave1=I;
% % %     if strfind1(javaclasspath('-all'),'loci_tools.jar')==0
% % %         javaaddpath([W.PathProgs,'\file Exchange\bfmatlab\bioformats_package.jar'],'-end');
% % % %         javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\bioformats_package.jar','-end');
% % %     end
% % %     if strfind1(javaclasspath('-all'),'bioformats_package.jar')==0
% % %         javaaddpath([W.PathProgs,'\file Exchange\bfmatlab\loci_tools.jar'],'-end');
% % % %         javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\loci_tools.jar','-end');
% % %     end
%     W=OrigW;
    
    
% end
% global W;
% evalin('caller','global W;');
% [~,~,ComputerInfo]=xlsread([W.PathProgs,'\ComputerInfo.xlsx'],'ComputerInfo');
% ComputerInfo=array2table(ComputerInfo(2:end,:),'VariableNames',ComputerInfo(1,:));
% ComputerInfo=ComputerInfo(strcmp(ComputerInfo.Name,W.ComputerInfo.Name),:);

% W.TimeDelay=0;

% W.ComputerInfo.ExcelVersion='.xlsx';
% try
%     W.Excel = actxGetRunningServer('Excel.Application');
% catch exception
%     try
%     W.Excel = actxserver('Excel.Application');
%     catch
%         W.Excel=[];
%     end
% end
% pause(0.5);

% W.SlaveInstance=uniqueInd([],[1;8]); % 9d to 1ms exact ind

