function [Data3D]=dilateInOut(Data3D,In,Out,Res)

datestr(datenum(now),'HH:MM:SS')
In=In/min(Res);
Out=Out/min(Res);
Res=Res/min(Res);


Data3D=1-Data3D;

Data3D=bwdistsc1(Data3D,Res,In);
datestr(datenum(now),'HH:MM:SS')
Data3D=Data3D>=In;

Data3D=bwdistsc1(Data3D,Res,Out);

Data3D=Data3D<Out;
datestr(datenum(now),'HH:MM:SS')

