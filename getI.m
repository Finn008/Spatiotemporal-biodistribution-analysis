function [out]=getI(in)
global w;
dbstop if error;

try
    [out]=getXYZdata(in,w.XYZvariables,{'X';'Y';'Z'});
catch; end;
