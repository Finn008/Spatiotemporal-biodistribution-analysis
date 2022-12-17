function [ComputerLoad]=autoquantRunning()
% pause(15*60);
global W;
ComputerLoad=table;
for m2=1:1000000
    [Out]=trackTaskManager();
    AutoquantInd=strfind1(Out.TaskManager.Abbildname,'aqiPlatform.exe');
    if size(AutoquantInd,1)>1 % somebody running session synchroneously
       pause(30);
       continue;
    end
    ComputerLoad.Date{m2,1}=datestr(now,'yyyy.mm.dd HH:MM:SS');
    ComputerLoad.CPUZeit(m2,1)=Out.TaskManager.CPUZeit(AutoquantInd,1);
    ComputerLoad.RAM(m2,1)=Out.AvailableRAM/1000000000;
    Wave1=datenum(ComputerLoad.CPUZeit);
    Wave1=[0;Wave1];
    Wave1=Wave1(2:end)-Wave1(1:end-1);
    ComputerLoad.CPU=round(Wave1*10000);
    Path2AutoquantStatus='\\Mitstor8.srv.med.uni-muenchen.de\znp-user\fipeter\Desktop\mistor8\Finns programs\multicore\AutoquantStatus.xlsx';
    try
        xlswrite_2(Path2AutoquantStatus,ComputerLoad,2);
    end
    if size(ComputerLoad,1)>6 && mean(ComputerLoad.CPU(end-2:end))<0.00003
        break;
    end
    if isfield(W,'Keyboard'); W=rmfield(W,'Keyboard'); keyboard; end;
    inputemu('move',[100;100]); pause(0.5); inputemu('move',[200;200]);
    pause(60*10);
end