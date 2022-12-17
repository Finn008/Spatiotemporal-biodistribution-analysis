function saveProject(TimeChecker)
keyboard; % replaced by saveProject_2
global W;
% generate backup for l.mat
BackupChecker=0;
SaveChecker=1;
if exist('TimeChecker')==1
    [AllFiles]=listAllFiles([W.PathExp,'\backup']);
    LastBackup=(datenum(now)-max(AllFiles.Datenum))*24*60-W.TimeDelay;
    if LastBackup>60
        BackupChecker=1;
    end
    [AllFiles]=listAllFiles([W.Pathi,'I.mat']);
    LastSave=(datenum(now)-max(AllFiles.Datenum))*24*60-W.TimeDelay;
    if LastSave<30
        SaveChecker=0;
    end
end
if SaveChecker==1
    Isaving=datenum(now); save([W.Pathi,'I~.mat'],'Isaving');
    for m=1:1000000
        Iloading=listAllFiles(W.Pathi);
        Wave1=strfind1(Iloading.FilenameTotal,'Iloading');
        if Wave1==0
            break
        end
        Iloading=Iloading(Wave1,:);
        Wave1=saveLoad_2(Iloading.Path2file{1});
        if (datenum(now)-Wave1)*24*60>15 % 15min
            delete(Iloading.Path2file{1});
        end
        if m==1
            disp('I.mat is beeing loaded');
        end
        pause(2);
    end
    
    I.G=W.G;
    disp(['Saving I.mat... ',datestr(now,'yy.mm.dd HH:MM')]);
    Isaving=datenum(now); save([W.Pathi,'I~.mat'],'Isaving');
    
    if W.G.SaveLarge==0
        save([W.Pathi,'I.mat'],'I');
        Wave1=dir([W.Pathi,'I.mat']);
        if Wave1.bytes<1000
            W.G.SaveLarge=1;
        end
    end
    if W.G.SaveLarge==1
        Isaving=datenum(now); save([W.Pathi,'I~.mat'],'Isaving');
        I.G.Fileinfo=W.G.Fileinfo(1:3800,:);
        I2=W.G.Fileinfo(3801:4800,:);
        I3=W.G.Fileinfo(4801:end,:);
        save([W.Pathi,'I.mat'],'I');
        save([W.Pathi,'I2.mat'],'I2');
        save([W.Pathi,'I3.mat'],'I3');
    end
    delete([W.Pathi,'I~.mat']);
end

if BackupChecker==1
    BackupPath=[W.PathExp,'\backup\I_',datestr(now,'yy.mm.dd.HH.MM.AM'),'.mat'];
    Path=['copy "',[W.Pathi,'I.mat'],'" "',BackupPath,'"'];
    [Status,Cmdout]=dos(Path);
    if W.G.SaveLarge==1
        Path=regexprep(BackupPath,'\I_','\I2_');
        Path=['copy "',[W.Pathi,'I2.mat'],'" "',Path,'"'];
        [Status,Cmdout]=dos(Path);
        
        Path=regexprep(BackupPath,'\I_','\I3_');
        Path=['copy "',[W.Pathi,'I3.mat'],'" "',Path,'"'];
        [Status,Cmdout]=dos(Path);
    end
end
if SaveChecker==1 || BackupChecker==1
    disp(['Finished saving ',datestr(now,'yy.mm.dd HH:MM')]);
end