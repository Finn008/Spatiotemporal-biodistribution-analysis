function pauseMouse(Duration,In)
global W;
% keyboard; % why does circulate on gnp454n?
if isfield(W,'PauseMouseCirculator')==0
    W.PauseMouseCirculator=1;
end
if W.PauseMouseCirculator==0 || Duration<=5
    pause(Duration);
    return;
else
    % if Duration<=5; pause(Duration); return; end;
    [Pos]=circleGenerator(In(1:2,1),In(3,1),5);
    TimeResolution=0.0001;
    StartTime=datenum(now);
    PauseTime=0;
    while PauseTime<Duration-3
        for m=1:size(Pos,1)
            PauseTime=(datenum(now)-StartTime)*24*60*60;
            inputemu('move',[Pos.Xpos(m),Pos.Ypos(m)]);
            pause(TimeResolution);
        end
    end
    pause(5);
end