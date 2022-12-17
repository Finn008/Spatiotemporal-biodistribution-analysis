function zenInfoReader()
global W;
% killImaris(1);

FileList=W.G.Fileinfo(:,1);
FileList.Type=W.G.Fileinfo.Type;
FileList.Results=W.G.Fileinfo.Results;
Wave1=strfind1(FileList.Type,{'.lsm';'.czi'});
FileList=FileList(Wave1,:);

for m=1:size(FileList)
    
    try
        Wave1=FileList.Results{m,1}.ZenInfo.GetInfo;
        FileList.ZenInfo(m,1)=1;
    catch
        FileList.ZenInfo(m,1)=0;
        continue;
    end
    
    try
        [Wave1,Wave2]=getPathRaw(FileList.FilenameTotal{m,1}); % ForDecon file there?
        %     FileList.Path2file{m,1}=Wave1;
        FileList.Report(m,1)=Wave2;
    catch
        FileList.Report(m,1)=0;
    end
    try
        FileList.Datenum(m,1)=datenum(FileList.FilenameTotal{m,1}(1:10),'yyyy.mm.dd');
    catch
        FileList.Datenum(m,1)=0;
    end
end
FileList(FileList.Report==0,:)=[];
FileList(FileList.ZenInfo==1,:)=[];
% FileList(FileList.Datenum<datenum('2014.04.08','yyyy.mm.dd'),:)=[];
% Wave1=strfind1(FileList.Type,{'.lsm';'.czi'});
% FileList=FileList(Wave1,:);
% datestr(FileList.Datenum(m,1),'yyyy.mm.dd HH:MM:SS')

%% Positions
if strcmp(W.ComputerInfo.Name,'gnp454n') %get(0,'PointerLocation')
    Pos.CloseLoginWindow=[988;454];
%     Pos.InfoTab=[426,426,426,426;656,698,916];
%     Pos.InfoTab=[426,426,426,426;1207,1249,1369,1419];
    Pos.InfoTab=[426,426,426,426;656,698,818,868];
    Pos.Name=[1367;916];
    Pos.Description=[1367;887];
    Pos.Notes=[1367;781];
    Pos.User=[1367;755];
    Pos.ScalingX=[1367;729];
    Pos.ScalingY=[1367;701];
    Pos.ScalingZ=[1367;675];
    Pos.Dimensions=[1367;645];
    Pos.ImageSize=[1367;615];
    Pos.ScanMode=[1367;586];
    Pos.Zoom=[1367;560];
    Pos.Objective=[1367;532];
    Pos.PixelDwell=[1367;502];
    Pos.Average=[1367;475];
    Pos.MasterGain=[1367;438];
    Pos.DigitalGain=[1367;410];
    Pos.DigitalOffset=[1367;382];
    Pos.Pinhole=[1367;354];
    Pos.Filters=[1367;326];
    Pos.BeamSplitters=[1367;298];
    Pos.Lasers=[1367;270];
    Pos.UpperLeftMargin=[581;917];
elseif strcmp(W.ComputerInfo.Name,'brain-pc') %get(0,'PointerLocation')
    Pos.CloseLoginWindow=[1407;729];
    Pos.InfoTab=[426,426,426,426;1207,1249,1369,1419];
    Pos.Name=[2247;1466];
    Pos.Description=[2247;1439];
    Pos.Notes=[2247;1330];
    Pos.User=[2247;1306];
    Pos.ScalingX=[2247;1279];
    Pos.ScalingY=[2247;1251];
    Pos.ScalingZ=[2247;1224];
    Pos.Dimensions=[2247;1194];
    Pos.ImageSize=[2247;1163];
    Pos.ScanMode=[2247;1136];
    Pos.Zoom=[2247;1109];
    Pos.Objective=[2247;1083];
    Pos.PixelDwell=[2247;1055];
    Pos.Average=[2247;1025];
    Pos.MasterGain=[2247;989];
    Pos.DigitalGain=[2247;966];
    Pos.DigitalOffset=[2247;937];
    Pos.Pinhole=[2247;909];
    Pos.Filters=[2247;883];
    Pos.BeamSplitters=[2247;854];
    Pos.Lasers=[2247;825];
    Pos.UpperLeftMargin=[570;1481];
end

inputemu(transpose({'key_down','\WINDOWS';'key_normal','d';'key_up','\WINDOWS'}));pause(0.5);
CDpath=['cd(''C:\ZEN'');']; eval(CDpath);
% !aqiPlatform.exe &



!AIMApplication.exe &
pause(4);
inputemu({'key_normal';'o'}); pause(1);
inputemu('normal',Pos.CloseLoginWindow); pause(0.5);
inputemu({'key_normal';'o'}); pause(1);
inputemu('key_alt',' '); pause(0.5);
inputemu(repmat({'key_normal';'\DOWN'},[1,4]),0.5);
inputemu('key_normal','\ENTER'); pause(0.5);

for m=FileList.Properties.RowNames.'
    [Path2file,Report]=getPathRaw(FileList.FilenameTotal{m,1}); % ForDecon file there?
    
    DosCommand=['!AIMApplication.exe "',Path2file,'" &'];
    eval(DosCommand); pause(2);
    % get infoTab
    OriginalFilename=FileList.FilenameTotal{m,1}; OriginalFilename=OriginalFilename(1:end-4);
    for m2=1:size(Pos.InfoTab,2)
        inputemu('normal',Pos.InfoTab(:,m2)); pause(1);
        Filename=setParameters_3([],Pos.Name,Pos.UpperLeftMargin);
        if strcmp(OriginalFilename,Filename)
            break;
        end
    end
    if Report==0
        continue;
    end
    
    FileList.Zoom{m,1}=setParameters_3([],Pos.Zoom,Pos.UpperLeftMargin);
    FileList.PixelDwell{m,1}=setParameters_3([],Pos.PixelDwell,Pos.UpperLeftMargin);
    FileList.Average{m,1}=setParameters_3([],Pos.Average,Pos.UpperLeftMargin);
    FileList.MasterGain{m,1}=setParameters_3([],Pos.MasterGain,Pos.UpperLeftMargin);
    if strcmp(FileList.MasterGain{m,1},'EmptyClipboard')==0
        FileList.DigitalGain{m,1}=setParameters_3([],Pos.DigitalGain,Pos.UpperLeftMargin);
        FileList.Lasers{m,1}=setParameters_3([],Pos.Lasers,Pos.UpperLeftMargin);
    else % only one lane of Master gain
        FileList.MasterGain{m,1}=setParameters_3([],Pos.MasterGain+[0;10],Pos.UpperLeftMargin);
        FileList.DigitalGain{m,1}=setParameters_3([],Pos.DigitalGain+[0;10],Pos.UpperLeftMargin);
        FileList.Lasers{m,1}=setParameters_3([],Pos.Lasers+[0;10],Pos.UpperLeftMargin);
    end
    pause(1);
    inputemu('key_ctrl','\F04'); pause(1);
end
keyboard;
for m=FileList.Properties.RowNames.'
    ZenInfo=struct;
    ZenInfo.Zoom=str2num(FileList.Zoom{m,1});
    ZenInfo.PixelDwell=FileList.PixelDwell{m,1};
    ZenInfo.Average=FileList.Average{m,1};
    [Wave1]=extractStringPart(FileList.MasterGain{m,1},'MasterGain');
    ZenInfo.MasterGain=Wave1;
    ZenInfo.DigitalGain=str2num(FileList.DigitalGain{m,1});
    [Wave1]=extractStringPart(FileList.Lasers{m,1},'Lasers');
    ZenInfo.Lasers=Wave1;
    FileList.ZenInfo2(m,1)={ZenInfo};
    iFileChanger('W.G.Fileinfo.Results{Q1,1}.ZenInfo',ZenInfo,{'Q1',m});
end
% iFileChanger({['G.SingleTasks.DoZenInfo{1}']},{'Do#Done|'});

keyboard;
[status,cmdout] = dos('taskkill /f /im AIMApplication.exe');



