function slaveTimer()

global W;
try
    Timeplan=W.G.SlaveTimer;
    Timeplan.Delete(1,1)=0;
    for m=1:size(Timeplan,1)
        if strfind1(W.ComputerName,Timeplan.SlaveName{m,1})==0
            continue;
        end
        [Condition]=variableExtract(Timeplan.Condition{m,1});
        Wave1=datenum(Condition.Start,'yyyy.mm.dd HH:MM');
        if datenum(now)>Wave1 && datenum(now)<Wave1+1/24*6
            Timeplan.Delete(m,1)=1;
            disp([W.ComputerName  ,' paused until user presses F5 ',datestr(datenum(now),'yyyy.mm.dd HH:MM')]);
            keyboard;
            disp([W.ComputerName  ,' running again',datestr(datenum(now),'yyyy.mm.dd HH:MM')]);
        end
    end
    % iFileChanger('W.G.T.F{W.Task,1}.RatioPlaque(Q1)',FA.Selection,{'Q1',FA.RowSpecifier});
    if max(Timeplan.Delete)==1
        iFileChanger('W.G.SlaveTimer(Q1,:)',[],{'Q1',find(Timeplan.Delete==1)});
    end
end