function initializeAnywhere()
keyboard; % replace by initializeAnywhere_2
global W;
W=struct;
W.DefaultImarisVersion='7.7.2';

[W.PathProgs,Name,Ext] = fileparts(mfilename('fullpath'));
W.PathImarisSample=[W.PathProgs,'\ImarisSample.ims'];

% get info on computer
W.ComputerInfo.Name = getComputerName();
W.TimeDelay=0;
W.SingularImarisInstance=0;
W.ComputerInfo.ExcelVersion='.xlsx';
try
    W.Excel = actxGetRunningServer('Excel.Application');
catch exception
    try
    W.Excel = actxserver('Excel.Application');
    catch
        W.Excel=[];
    end
end
pause(0.5);
W.ImarisId={0,'',0}; W.ImarisId=cell2table(W.ImarisId,'VariableNames',{'Id';'Char';'Status'}); W.ImarisId(1,:)=[];
W.SlaveInstance=uniqueInd([],[1;8]); % 9d to 1ms exact ind
W.Stop=0;
if isfield(W,'ImarisLib')==0 || isempty(W.ImarisLib)
    cd(['C:\Program Files\Bitplane\Imaris x64 ',W.DefaultImarisVersion,'\XT\matlab']);
    OrigW=W; %Wave1=I;
    javaaddpath ImarisLib.jar;
    
% % %     if strfind1(javaclasspath('-all'),'loci_tools.jar')==0
% % %         javaaddpath([W.PathProgs,'\file Exchange\bfmatlab\bioformats_package.jar'],'-end');
% % % %         javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\bioformats_package.jar','-end');
% % %     end
% % %     if strfind1(javaclasspath('-all'),'bioformats_package.jar')==0
% % %         javaaddpath([W.PathProgs,'\file Exchange\bfmatlab\loci_tools.jar'],'-end');
% % % %         javaaddpath('\\GNP90N\share\Finn\Finns programs\file Exchange\bfmatlab\loci_tools.jar','-end');
% % %     end
    W=OrigW;
    W.ImarisLib=ImarisLib;
    global W; 
end
evalin('caller','global W;');