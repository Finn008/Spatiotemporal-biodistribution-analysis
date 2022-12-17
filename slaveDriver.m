function slaveDriver()

Path=['net use x: ',W.G.PathFinn,' /user:gnp90n\fipeter arco73'];
% Path='net use *: \\gnp90n\share\Finn /user:gnp90n\fipeter arco73';
[status,results] = dos(Path, '-echo');

CDpath=['cd(''\\GNP90N\share\Finn\Finns programs'');'];
eval(CDpath);
addpath(genpath('\\GNP90N\share\Finn\Finns programs'))
startup();
slaveGUI();
% DosCommand=['!Matlab.exe "\\GNP90N\share\Finn\Finns programs\slaveGUI.mat" &'];

% DosCommand=['!Matlab.exe "\\GNP90N\share\Finn\Finns programs\slaveGUI.fig" &'];
% eval(DosCommand);


% exist('\\gnp90n\share\Finn')
% dir('\\gnp90n\share\Finn');
% dir('\\gnp90n\share\Finn\');
% 
% % CDpath=['cd(''C:\Program Files\Media Cybernetics\AutoQuant X3'');'];
% 
% 
% 
% 'C:\Program Files\MATLAB\R2014b\bin\matlab.exe';