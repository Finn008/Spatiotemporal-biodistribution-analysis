function [status]=getFileFromMarvin(filename)
global l; global w; dbstop if error;

pathSource=[w.marvinPath,'\',filename];
pathTarget=[l.g.pathRaw.path{w.inputDrive},'\',filename];
[status,message,messageid] = copyfile(pathSource,pathTarget,'f');
