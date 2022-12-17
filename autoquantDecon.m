function autoquantDecon()
dbstop if error;
pos.openFile=[-1657;976];
pos.closeImage=[-303;916];
pos.firstQuantFile=[-1600;920];
pos.ch1=[-1500;412];
pos.ch2=[-1500;392];
pos.modality=[-1500;372];
pos.lens=[-1500;356];
pos.immMedium=[-1500;316];
pos.sampleMedium=[-1500;300];
pos.D3=[-730;980];
pos.baseName=[-95;636];
pos.add2batch=[-190;352];

status=0;
filenumber=0;
while status==0
    filenumber=filenumber+1;
    disp(filenumber);
    % open file
    inputemu('normal',pos.openFile);
    pause(8);
    % select file
    for m=1:4; inputemu('key_normal','\TAB'); end;
    pause(1);
    inputemu('key_normal','\DOWN');
    if filenumber==1
        pause(1);
        inputemu('key_normal','\UP');
    end
    for m=1:filenumber-2
        pause(1);
        inputemu('key_normal','\DOWN')
    end
    % copy filename
    pause(4);
    inputemu('key_normal','\TAB');
    inputemu('key_normal','\TAB');
    pause(3);
    inputemu('key_down','\CTRL');
    inputemu('key_down','c');
    inputemu('key_up','\CTRL');
    filename = clipboard('paste');
    
    % check if file is valid
    allFiles{filenumber,1}=filename;
    type=filename(end-3:end);
    wave1=strfind1(allFiles,allFiles{filenumber,1},1);
    if size(wave1,1)>1
        inputemu('key_normal','\ESCAPE');
        break
    elseif filenumber~=1 && wave1==0 % success
        
    elseif strcmp(type,'.lsm')==0 && strcmp(type,'.ids')==0
        inputemu('key_normal','\ESCAPE');
        continue;
    end
    inputemu('key_normal','\ENTER');
    pause(10);
    % for valid file determine settings
    if strcmp(filename(end-4:end-4),'b')
        ch1Wavelength='450 nm';
        ch2Wavelength='620 nm';
    elseif strcmp(filename(end-4:end-4),'a')
        ch1Wavelength='620 nm';
        ch2Wavelength='530 nm';
    end
        
    setEntry(pos.ch1,ch1Wavelength);
    setEntry(pos.ch2,ch2Wavelength);
    setEntry(pos.modality,'Multi-Photon Fluorescence');
    setEntry(pos.lens,'W Plan-Apochromat 20x/1.0 DIC M27 75mm');
    setEntry(pos.immMedium,'Water (1,333)');
    setEntry(pos.sampleMedium,'Water (1,333)');
    
    inputemu('normal',pos.D3);
    pause(2);
    inputemu('normal',pos.baseName);
    pause(4);
    clipboard('copy', filename)
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
    inputemu('normal',pos.add2batch);
    filenumber=filenumber+1;
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
