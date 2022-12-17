function [I]=loadProject()
global W;

for m=1:1000000
    Isaving=saveLoad_2([W.Pathi,'I~.mat']);
    if isempty(Isaving)
        break
    end
    if (datenum(now)-Isaving)*24*60>60 % 60min
        delete([W.Pathi,'I~.mat']);
    end
    if m==1
        disp('I.mat beeing saved');
    end
    pause(2);
end
IloadingPath=[W.Pathi,'Iloading_',W.ComputerInfo.Name,W.SlaveInstance,'.mat'];
Iloading=datenum(now); save(IloadingPath,'Iloading');

% keyboard;
I=saveLoad_2([W.Pathi,'I.mat']);

if I.G.SaveLarge==1
    Iloading=datenum(now); save(IloadingPath,'Iloading'); % put Iloading once again
    I2=saveLoad_2([W.Pathi,'I2.mat']);
    I3=saveLoad_2([W.Pathi,'I3.mat']);
    I.G.Fileinfo=[I.G.Fileinfo;I2;I3];
end
delete(IloadingPath);