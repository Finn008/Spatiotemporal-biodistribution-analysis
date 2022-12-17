function [Report]=autoquantSetParameters(Pos,Val)
global W;
pause(2);
pauseMouse(10,Pos.Pause);
Report=0;
% try
inputemu('key_alt','w'); pause(0.5);
inputemu(repmat({'key_normal';'\DOWN'},[1,3]),0.5);
inputemu('key_normal','\ENTER'); pauseMouse(2,Pos.Pause);

% set ch1
setParameters_3(Val.Ch1Wavelength,Pos.Ch1); pause(1);

% set ch2
setParameters_3(Val.Ch2Wavelength,Pos.Ch2); pause(1);

% set modality
setParameters_3(Val.Modality,Pos.Modality);

% set lens
setParameters_3(Val.Lens,Pos.Lens); pause(1);

% set immMedium
inputemu('normal',Pos.ImmMedium);pauseMouse(5,Pos.Pause);
setParameters_3(Val.ImmMedium,Pos.ImmMedium); pause(1);

% set sampleMedium
setParameters_3(Val.SampleMedium,Pos.SampleMedium); pause(1);

% press 3D decon button
inputemu('normal',Pos.D3); 
pauseMouse(4,Pos.Pause);
% set spherical aberation
inputemu('normal',Pos.SA); pause(1);
setParameters_3(Val.SA,Pos.SAinput); pause(1);
setParameters_3('1,333',Pos.RIinput); pause(1);
% inputemu('key_normal','\TAB'); pause(1);
inputemu('normal',Pos.SAch2); pause(1);
setParameters_3(Val.SA,Pos.SAinput); pause(1);
setParameters_3('1,333',Pos.RIinput); pause(1);
inputemu('normal',Pos.SA); pause(1);


AutoquantTargetPathSelected=0;
while AutoquantTargetPathSelected==0
    pause(1);
    inputemu('normal',Pos.BaseName);
    pauseMouse(20,Pos.Pause);
    % set filename
    setParameters_3(Val.TargetFilename); pause(1);
    
    %% search targetPath
    if isfield(W,'AutoquantTargetPathSelected')==0
        if strcmp(W.ComputerInfo.Name,'gnp454n')
            inputemu(transpose({'key_down','\SHIFT';'key_normal','\TAB';'key_normal','\TAB';'key_normal','\TAB';'key_up','\SHIFT'}));pause(0.5);
        else
            inputemu(transpose({'key_down','\SHIFT';'key_normal','\TAB';'key_normal','\TAB';'key_up','\SHIFT'}));pause(0.5);
        end
        inputemu('key_normal','\DOWN');
        inputemu('key_normal',' '); pause(2);
        inputemu('key_normal','\TAB');
        inputemu('key_normal','0');
        inputemu('key_normal','\F02'); pause(1);
        inputemu('key_ctrl','c'); pause(2);
        try; Wave1 = clipboard('paste'); pause(2); end;
        if strcmp(Wave1,'0000DoNotRemove!')
            AutoquantTargetPathSelected=1;
        else
            AutoquantTargetPathSelected=0;
            keyboard;
            inputemu('key_normal','\ESC'); pause(1);
            inputemu('key_normal','\ESC');
        end
    end
end
inputemu('key_normal','\ENTER');
inputemu('key_normal','\ENTER');
pauseMouse(5,Pos.Pause);
pauseMouse(60,Pos.Pause);
inputemu('key_normal','\TAB');
inputemu('key_normal','\TAB');
if strcmp(W.ComputerInfo.Name,'gnp454n')
    inputemu('key_normal','\TAB');
end
pauseMouse(2,Pos.Pause);
% strcmp(Val.Type,'.lsm')
if strcmp(Val.Type,'.lsm')
    inputemu(repmat({'key_normal';'\DOWN'},[1,3]),0.1); pause(0.5);
end
inputemu(repmat({'key_normal';'\TAB'},[1,5]),0.5);
% set bitType
pause(0.5);
setParameters_3(Val.BitType); pause(0.5);

inputemu('key_normal','\TAB');
inputemu('key_normal','\ENTER');
pauseMouse(40,Pos.Pause);

% save screenshot
% % % % Path2folder=[W.PathProgs,'\multicore\ScreenShots'];
% % % % Filename=[datestr(datenum(now),'yyyy.mm.dd HH.MM.SS'),'_',Val.Filename];
% % % % screenShot(Path2folder,Filename,W.ComputerInfo.Name);
% % % % pauseMouse(3,Pos.Pause);

inputemu('normal',Pos.Add2batch); pause(2);
Report=1;
