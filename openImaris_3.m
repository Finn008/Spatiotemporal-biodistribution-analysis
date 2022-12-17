% open empty Imaris file: [Application]=openImaris_3([Pix(1);Pix(2);Pix(3);0;1],Res,SetVisible,MouseMove)

function [Application]=openImaris_3(Pix,Res,SetVisible,MouseMove,UmMinMax)
global W;
% if W.SingularImarisInstance==1
%     mouseMoveController(1);
% end

if ischar(Pix)
   Path2file=Pix;
else
    Path2file=W.PathImarisSample;
end
Application=[];

% if exist('Path2file')~=1;
%     W.DoReport=['openImaris: filepath not exists: ',Path2file];
%     return;
% end
if isempty(strfind(Path2file,'\')) % in case Path2file is a filename
    [Path2file,Report]=getPathRaw(Path2file);
    if Report==0
        keyboard;
    end
end
% if exist('ImarisVersion')~=1 || isempty(ImarisVersion);
%     ImarisVersion=W.DefaultImarisVersion;
% end
% if exist('PixMin')~=1
PixMin=[0;0;0;0;0];
% end
if exist('Pix')~=1
    Pix=[0;0;0;0;0];
end

if size(Pix,1)==3
    Pix=[Pix;0;1];
end
if min(Pix(:))<0 || min(PixMin(:))<0
    A1=asdf;
end
if strcmp(ImarisVersion,'7.7.2') && PixMin(4)==0&&Pix(4)==1
    keyboard;
    Pix(4)=2;
    ProblemImaris772=1;
end
if exist('Resample')~=1
    Resample=[1;1;1;1;1];
end
% if exist('Resolution')==1 && exist('Fileinfo')==1
%     keyboard; % not used since 2016.08.30
%     for m=1:3
%         if Resolution(m,1)~=0
%             Resample(m,1)=Resolution(m,1)/Fileinfo.Res{1,1}(m,1);
%         end
%     end
% end
if exist('UmMinMax')~=1
    try; UmMinMax=[[0;0;0],Res.*Pix(1:3)]; end;
end
Croplimitsmin=mat2str(PixMin.');Croplimitsmin=Croplimitsmin(2:end-1);
Croplimitsmax=mat2str(Pix.');Croplimitsmax=Croplimitsmax(2:end-1);
Resample=mat2str(Resample.');Resample=Resample(2:end-1);

Specifier=['reader="All Formats" croplimitsmin="',Croplimitsmin,'" croplimitsmax="',Croplimitsmax,'" resample="',Resample,'"'];

% load 8bit instead of 16bit
if exist('BitType')==1
    if strcmp(BitType,'uint8')
        Path2file=[Path2file(1:end-4),'8bit',Path2file(end-3:end)];
    elseif strcmp(BitType,'uint16')
    end
end

ExPath=['cd(''C:\Program Files\Bitplane\Imaris x64 ',ImarisVersion,'\XT\matlab'');'];
eval(ExPath);

if exist('TrialNumber')~=1
    TrialNumber=3;
end
for Trials=1:TrialNumber
    ObjectID=zeros(0,1,'double');
    try
        Server=W.ImarisLib.GetServer;
        NumberOfObjects=Server.GetNumberOfObjects;
        for m=1:NumberOfObjects
            ObjectID(m,1)=Server.GetObjectID(m-1);
        end
    end
    Ind=(0:100).';
    Ind(ObjectID+1,:)=[];
    Ind=Ind(1);
    Path=['! ../../Imaris.exe id',num2str(Ind),'&'];
% % %     mouseMoveController(1);
    eval(Path);
    pause(8);
    
    for m=1:3
        Application = W.ImarisLib.GetApplication(Ind);
        if isempty(Application)==0
            break;
        end
        pause(1);
    end
    
    if isempty(Application)==0
        Wave1=size(W.ImarisId.Id,1)+1;
        W.ImarisId.Id(Wave1,1)=Ind;
        W.ImarisId.Char(Wave1,1)={char(Application)};
        W.ImarisId.Application(Wave1,1)={Application};
        
        break;
    else
        [ImarisServerIce]=trackTaskManager();
        ImarisServerIce=strfind1(ImarisServerIce.TaskManager.Abbildname,'ImarisServerIce.exe',1);
        if ImarisServerIce~=0
            inputemu('key_alt','\F04'); pause(0.5);
            disp('Successfully closed after incorrect ImarisConnection');
        end
    end
    
end
% % % mouseMoveController(0);

if isempty(Application);
    W.DoReport=['P0237_2: filepath exists but not loaded: ',Path2file];
    return;
end;
% if exist('GetAllStatistics')==1
%     includeAllImarisStatistics(Application);
% end
if exist('SetVisible')~=1 || SetVisible==0
    Application.SetVisible(0);
end

try
    Application.FileOpen(Path2file,Specifier);
    VdataSetIn=Application.GetDataSet;
catch error
    keyboard;
end
setImarisViewer(Application,'surpass');
Application.GetSurpassScene.SetVisible(0);
if exist('VdataSetIn')~=1
    W.DoReport=['P0237_2: file corrupt: ',Path2file];
    Fileinfo=[];
else
    W.DoReport='success';
    if exist('UmMinMax')==1&&isempty(UmMinMax)==0;
        VdataSetIn.SetExtendMinX(UmMinMax(1,1)); VdataSetIn.SetExtendMinY(UmMinMax(2,1)); VdataSetIn.SetExtendMinZ(UmMinMax(3,1));
        VdataSetIn.SetExtendMaxX(UmMinMax(1,2)); VdataSetIn.SetExtendMaxY(UmMinMax(2,2)); VdataSetIn.SetExtendMaxZ(UmMinMax(3,2));
    end
end

if exist('MouseMove','var')~=0
    mouseMoveController(0);
end
