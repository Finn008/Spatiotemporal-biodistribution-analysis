function startup()
dbstop if error;
warning('off','all');
% keyboard;
% % % % addpath(genpath('\\mitstor8.srv.med.uni-muenchen.de\ZNP-User\fipeter\Desktop\mistor8\Finns programs'));
Wave1=fileparts(mfilename('fullpath'));
Wave2=strfind(Wave1,'\');
% Path=['\\fs-mu.dzne.de\ag-herms\Finn Peters\JarFiles\',getComputerName()];
% keyboard;
Path=[Wave1(1:Wave2(end)),'\JarFiles\',getComputerName()];
% keyboard;
if exist(Path,'dir')==0
    A1=asdf;
end
javaaddpath([Path,'\loci_tools.jar'])
javaaddpath([Path,'\bioformats_package.jar'])
javaaddpath([Path,'\bio-formats.jar'])

  