function [out]=setI(in);
global w;
dbstop if error;
try
    [out]=putXYZdata(in,w.XYZvariables,{'X';'Y';'Z'});
catch; end;
