function [Datenum]=datenumNowLocal(Path2folder)
% keyboard;
SaveVar=[];
Path2file=[Path2folder,'DateChecker',num2str(round(rand*10)),'.mat'];
for m=1:100
    try
        save(Path2file,'SaveVar');
        Fileinfo=dir(Path2file);
        Datenum=Fileinfo.datenum;
        delete(Path2file);
        break;
    catch
        pause(0.4);
    end
end
Delay=(datenum(now)-Datenum)*24*60;
DateStr=datestr(Datenum,'yyyy.mm.dd HH:MM:SS');