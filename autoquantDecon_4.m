function autoquantDecon_4()
global W;
% keyboard; % use another folder for deconvolution
killImaris();
[status,cmdout] = dos('taskkill /f /im aqiPlatform.exe');

%% Positions
if strcmp(W.ComputerInfo.Name,'gnp454n') %get(0,'PointerLocation')
    W.PauseMouseCirculator=0;
    Pos.OpenFile=[23;976];
    Pos.Window=[390;1010];
    Pos.Ch1=[180;632];
    Pos.Ch2=[180;612];
    Pos.Modality=[180;592];
    Pos.Lens=[180;576];
    Pos.Aperture=[180;556];
    Pos.ImmMedium=[180;536];
    Pos.SampleMedium=[180;520];
    Pos.D3=[950;980];
    Pos.SA=[1580;775];
    Pos.SAinput=[1320;622];
    Pos.SAch2=[1320;690];
    Pos.RIinput=[1320;572];
    Pos.BaseName=[1585;636];
    Pos.Add2batch=[1490;352];
    Pos.Launch=[1620;605];
% elseif strcmp(W.ComputerInfo.Name,'brain-pc')
%     W.PauseMouseCirculator=1;
%     Pos.OpenFile=[20;1530];
%     Pos.Ch1=[300;1185];
%     Pos.Ch2=[300;1165];
%     Pos.Modality=[300;1145];
%     Pos.Lens=[300;1125];
%     Pos.Aperture=[300;1105];
%     Pos.ImmMedium=[300;1085];
%     Pos.SampleMedium=[300;1067];
%     Pos.D3=[955;1530];
%     Pos.SA=[2460;1325];
%     Pos.SAinput=[2200;1170];
%     Pos.RIinput=[2220;asdf];
%     Pos.SAch2=[2300;1240];
%     Pos.BaseName=[2465;1185];
%     Pos.Add2batch=[2369;905];
%     Pos.Launch=[2500;1155];
end
Pos.Pause=[1176;274;100];

%% define files to be deconvoluted
Wave1=strfind1(W.G.Fileinfo.Decon,'Autoquant#Go|');
DeconFileList=W.G.Fileinfo(Wave1,:);
DeconFileList(DeconFileList.MB==0,:)=[];
for m2=1:size(DeconFileList,1)
    Param2add=table;
    try
        Param2add=DeconFileList.Results{m2,1}.Decon.FileList;
    end
    if strfind1(Param2add.Properties.VariableNames,'TrialDate')==0
        continue;
    end
    if m2==1
        DeconParameters=Param2add;
    else
        DeconParameters=[DeconParameters;Param2add];
    end
end
[Wave1,Wave2]=strfind1(DeconParameters.FilenameTotal,'4deCal');
DeconParameters(Wave2==1,:)=[]; % exclude all the 4deCal files
for m2=1:size(DeconParameters,1)
    [Wave1,Wave2]=getPathRaw(DeconParameters.FilenameTotal(m2,1)); % ForDecon file there?
    DeconParameters.Path2file{m2,1}=Wave1;
    DeconParameters.Report1(m2,1)=Wave2;
    [Wave1,Wave2]=getPathRaw([DeconParameters.TargetFilename{m2,1},'.ids']); % DeFin file already there
    DeconParameters.Report2(m2,1)=Wave2;
    [Wave1,Wave2]=getPathRaw(['10_',DeconParameters.TargetFilename{m2,1},'.ids']); % 10_ DeFin file already there
    DeconParameters.Report3(m2,1)=Wave2;
end
DeconParameters(DeconParameters.Report1==0,:)=[]; % exclude if ForDecon file not present
DeconParameters(DeconParameters.Report2==1,:)=[]; % exclude if DeFin file already there
DeconParameters(DeconParameters.Report3==1,:)=[]; % exclude if 10_DeFin file already there
DeconParameters((datenum(now)-DeconParameters.TrialDate)<2,:)=[]; % no idea
% sort according Family
clear Wave1;
for m2=1:size(DeconParameters,1)
    Wave1{m2,1}=DeconParameters.FilenameTotal{m2,1}(12:end);
end
[~,Wave1]=sort(Wave1);
DeconParameters=DeconParameters(Wave1,:);

%         Large=DeconParameters(DeconParameters.MB>1000,:);
%         DeconParameters(DeconParameters.MB>1000,:)=[];
%         DeconParameters=[Large;DeconParameters];

% if size(DeconParameters,1)==0
%     keyboard; % check if AutoquantDecon really quits correctly
%     break;
% end
DeconParameters=[DeconParameters(strfind1(DeconParameters.FilenameTotal,'a_'),:);DeconParameters(strfind1(DeconParameters.FilenameTotal,'b_'),:)];
disp(DeconParameters.FilenameTotal);
InitializeAutoquant=1;
% m=0;
for m=1:size(DeconParameters,1)
    if InitializeAutoquant==1
        inputemu(transpose({'key_down','\WINDOWS';'key_normal','d';'key_up','\WINDOWS'}));pause(0.5);
        CDpath=['cd(''C:\Program Files\Media Cybernetics\AutoQuant X3'');']; eval(CDpath);
        !aqiPlatform.exe &
        pause(120);
        if strcmp(W.ComputerInfo.Name,'gnp454n')~=1
            detectKeyPress();
        end
        InitializeAutoquant=0;
    end
    if isfield(W,'Keyboard'); W=rmfield(W,'Keyboard'); keyboard; end;
    Val=DeconParameters(m,:);
    Val=table2struct(Val);
    Val.Path2fileXML=[Val.Path2file,'.xml'];
    delete(Val.Path2fileXML);
    CDpath=['cd(''C:\Program Files\Media Cybernetics\AutoQuant X3'');']; eval(CDpath);
    DosCommand=['!aqiPlatform.exe "',Val.Path2file,'" &'];
    eval(DosCommand);
    pause(120);
    for m1=1:20 % check if file was loaded
        Report=setParameters_3('1 nm',Pos.Ch1);
        if Report==1
            break;
        end
    end
    if  Report==0
        keyboard;
    end
    [Report]=autoquantSetParameters(Pos,Val);
    disp(DeconParameters.FilenameTotal{m,1});
    DeconParameters.Deconvoluted(m,1)=1;
    [Wave1,Wave2]=memory; AvailableRAM(m,1)=Wave2.PhysicalMemory.Available/1000000000;
    
    if AvailableRAM(end,1)<6 || m>=20 || m==size(DeconParameters,1)
        for m2=1:m*2
            inputemu('normal',Pos.Launch); pause(0.5);
        end
        try
            Path2AutoquantStatus='\\Mitstor8.srv.med.uni-muenchen.de\znp-user\fipeter\Desktop\mistor8\Finns programs\multicore\AutoquantStatus.xlsx';
            xlswrite_2(Path2AutoquantStatus,DeconParameters,1);
        end
        [ComputerLoad]=autoquantRunning();
        [status,cmdout] = dos('taskkill /f /im aqiPlatform.exe');
        
        pause(60);
        InitializeAutoquant=1;
    end
end

