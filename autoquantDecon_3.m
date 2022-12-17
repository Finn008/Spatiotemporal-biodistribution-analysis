%autoquantDecon_3(1,5);
function autoquantDecon_3(Autostart,MaxFilenumber,ComputerName)
pause(5);

% SphericalAberation={'0,2';'0,4';'0,6';'0,8';'0';'-0,2';'-0,4';'-0,6';'-0,8'};
% SphericalAberation(:,2)=SphericalAberation(:,1);
RealFileNumber=0;
Path2DeconFolder='\\GNP454N\finn001\raw data\toBeDeconvoluted\now';
%% define position coordinates
if exist('ComputerName')==0
    ComputerName='gnp454n';
end
if strcmp(ComputerName,'gnp454n')
    pos.openFile=[-1657;976];
%     pos.closeImage=[-303;916];
%     pos.firstQuantFile=[-1600;920];
%     pos.outside=[-1000;412];
    pos.Window=[-1290;1010];
%     pos.spacings=[-1500;652]; % [-1500;432]
    pos.ch1=[-1500;632]; % [-1500;412]
    pos.ch2=[-1500;612]; % [-1500;392]
    pos.modality=[-1500;592]; % [-1500;372]
    pos.lens=[-1500;576]; % [-1500;356]
    pos.aperture=[-1500;556]; % [-1500;336]
    pos.immMedium=[-1500;536]; % [-1500;316]
    pos.sampleMedium=[-1500;520]; % -1500;300]
    pos.D3=[-730;980];
    pos.SA=[-100;775];
    pos.SAinput=[-360;622];
    pos.SAch2=[-360;690];
    pos.baseName=[-95;636];
    pos.add2batch=[-190;352];
    pos.Launch=[-60;605];
elseif strcmp(ComputerName,'brain')
    pos.openFile=[20;1530];
    pos.ch1=[300;1185]; % [-1500;412]
    pos.ch2=[300;1165]; % [-1500;392]
    pos.modality=[300;1145]; % [-1500;372]
    pos.lens=[300;1125]; % [-1500;356]
    pos.aperture=[300;1105]; % [-1500;336]
    pos.immMedium=[300;1085]; % [-1500;316]
    pos.sampleMedium=[300;1067]; % -1500;300]
    pos.D3=[955;1530];
    pos.SA=[2460;1325];
    pos.SAinput=[2200;1170];
    pos.SAch2=[2300;1240];
    pos.baseName=[2465;1185];
    pos.add2batch=[2369;905];
    pos.Launch=[2500;1155];
end

%%

if exist('Autostart')==0
    Autostart=0;
end
if exist('MaxFilenumber')==0
    MaxFilenumber=1000000;
end
m1=0;
% AllFiles=listAllFiles(Path2DeconFolder);
while m1<=MaxFilenumber
    
%     DeconFiles=strcmp(AllFiles.Type,'.lsm')+strcmp(AllFiles.Type,'.ids');
%     DeconFiles=AllFiles(find(DeconFiles),:);
    
    
    m1=m1+1;
    disp(m1);
    % open file
    inputemu('normal',pos.openFile);
    pause(3);
    % select file
    for m=1:4; inputemu('key_normal','\TAB'); end;
    pause(1);
    inputemu('key_normal','\DOWN');
    if m1==1
        pause(1);
        inputemu('key_normal','\UP');
    end
    for m=1:m1-2
        pause(3);
        inputemu('key_normal','\DOWN')
    end
    % copy filename
    clipboard('copy','test');
    pause(4);
    
    inputemu('key_normal','\TAB');
    if strcmp(ComputerName,'gnp454n')
        inputemu('key_normal','\TAB');
    end
    pause(3);
    inputemu('key_down','\CTRL');
    inputemu('key_down','c');
    inputemu('key_up','\CTRL');
    pause(3);       
    filename = clipboard('paste');
    if strcmp(filename,'test')
        inputemu('key_normal','\ESCAPE');
%         m1=m1+1;
        continue;
    end
    disp(filename);
    % check if file is valid
    allFiles{m1,1}=filename;
    type=filename(end-3:end);
    wave1=strfind1(allFiles,allFiles{m1,1},1);
    if size(wave1,1)>1
        inputemu('key_normal','\ESCAPE');
        break
    elseif m1~=1 && wave1==0 % success
        
    elseif strcmp(type,'.lsm')==0 && strcmp(type,'.ids')==0
        inputemu('key_normal','\ESCAPE');
        continue;
    end
    inputemu('key_normal','\ENTER');
    pause(5);
    % for valid file determine settings
    if strcmp(filename(end-4:end-4),'b')
        ch1Wavelength='450 nm';
        ch2Wavelength='620 nm';
    elseif strcmp(filename(end-4:end-4),'a')
        ch1Wavelength='620 nm';
        ch2Wavelength='530 nm';
    end
    
    if m1==1; pause(10); end;
%     inputemu('key_down','\ALT'); inputemu('key_normal','\w'); inputemu('key_up','\ALT');
    inputemu('normal',pos.Window);pause(0.5);
    for m=1:4
        inputemu('key_normal','\DOWN')
        pause(0.5);
    end
    inputemu('key_normal','\ENTER');
    RealFileNumber=RealFileNumber+1;
    %% set ch1
    inputemu('normal',pos.ch1);
    inputemu('key_normal','\END'); for m=1:10; inputemu('key_normal','\BACKSPACE'); end;
    inputemu('key_normal',ch1Wavelength); pause(1);
    %% set ch2
    inputemu('normal',pos.ch2); pause(5); inputemu('normal',pos.ch2); pause(1);
    inputemu('key_normal','\END'); for m=1:10; inputemu('key_normal','\BACKSPACE'); end;
    inputemu('key_normal',ch2Wavelength); pause(1);
    %% set modality
    inputemu('normal',pos.modality); pause(5); inputemu('normal',pos.modality); pause(1);
    inputemu('key_normal','\END'); for m=1:100; inputemu('key_normal','\BACKSPACE'); end;
    clipboard('copy','Multi-Photon Fluorescence'); pause(1);
    inputemu('key_down','\CTRL'); inputemu('key_normal','v'); inputemu('key_up','\CTRL'); inputemu('key_down','\ENTER');pause(1);
    %% set lens
    inputemu('normal',pos.lens);
    inputemu('key_normal','\END'); for m=1:100; inputemu('key_normal','\BACKSPACE'); end;
    clipboard('copy','W Plan-Apochromat 20x/1.0 DIC M27 75mm'); pause(0.2);
    inputemu('key_down','\CTRL'); inputemu('key_normal','v'); inputemu('key_up','\CTRL'); inputemu('key_down','\ENTER');pause(1);
    %% set immMedium
    inputemu('normal',pos.immMedium);pause(5); inputemu('normal',pos.immMedium); pause(1);
    inputemu('key_normal','\END'); for m=1:100; inputemu('key_normal','\BACKSPACE'); end;
    inputemu('key_normal','Water (1,333)'); pause(1);
    %% set sampleMedium
    inputemu('normal',pos.sampleMedium);
    inputemu('key_normal','\END'); for m=1:100; inputemu('key_normal','\BACKSPACE'); end;
    inputemu('key_normal','Water (1,333)'); pause(1);
    
    
    inputemu('normal',pos.D3); % press 3D decon button
    pause(4);
    %% set spherical aberation
    inputemu('normal',pos.SA); pause(0.5);
    inputemu('normal',pos.SAinput); pause(0.5);
%     clipboard('copy',SphericalAberation{RealFileNumber,1}); pause(0.5);
    clipboard('copy','0,4'); pause(0.5);
    inputemu('key_down','\CTRL');
    inputemu('key_normal','v');
    inputemu('key_up','\CTRL');pause(0.5);
    inputemu('key_normal','\TAB'); pause(1);
    
    inputemu('normal',pos.SAch2); pause(0.5);
    inputemu('normal',pos.SAinput); pause(0.5);
%     clipboard('copy',SphericalAberation{RealFileNumber,2}); pause(0.5);
    clipboard('copy','0,4'); pause(0.5);
    inputemu('key_down','\CTRL');
    inputemu('key_normal','v');
    inputemu('key_up','\CTRL');pause(0.5);
    inputemu('key_normal','\TAB'); pause(1);
    
    inputemu('normal',pos.SA); pause(1);
    
    inputemu('normal',pos.baseName);
    pause(2);
    clipboard('copy', filename)
    pause(1);
    inputemu('key_down','\CTRL');
    inputemu('key_normal','v');
    inputemu('key_up','\CTRL');
    pause(1);
    % define type .ids
    inputemu('key_normal','\TAB');
    pause(2);
    if strcmp(type,'.lsm')
        for m=1:3; inputemu('key_normal','\DOWN'); end;
        pause(0.5);
    end
    for m=1:5; inputemu('key_normal','\TAB'); pause(0.5);end;
    
    inputemu('key_normal','\DOWN');
    inputemu('key_normal','\DOWN');
    inputemu('key_normal','\TAB');
    inputemu('key_normal','\ENTER');
    pause(1);
    inputemu('key_normal','j');
    inputemu('normal',pos.add2batch); pause(0.5);
    
    
    m1=m1+1; % to jump over xml file
end
if Autostart==1
    pause(5);
    for m=1:200
        inputemu('normal',pos.Launch);
        pause(1);
    end
end
disp('finished');

function setEntry(position,string)
pause(1);
inputemu('normal',position);
pause(1);
inputemu('normal',position);
pause(1);
inputemu('key_normal','\END');
for m=1:100; inputemu('key_normal','\BACKSPACE'); end;
pause(1);
clipboard('copy', string)
inputemu('key_down','\CTRL');
inputemu('key_normal','v');
inputemu('key_up','\CTRL');

