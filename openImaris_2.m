% open empty Imaris file: J=struct;J.PixMax=[Pix(1);Pix(2);Pix(3);0;1]; J.Resolution=Res; J.Path2file=W.PathImarisSample; Application2=openImaris_2(J); Application2.SetVisible(1);
function [Application]=openImaris_2(II,SetVisible,MouseMove)
keyboard; % replaced by openImaris_4
global W;
% if W.SingularImarisInstance==1
mouseMoveController(1);
% end

if isstruct(II)
    v2struct(II);
elseif ischar(II)
   Path2file=II; 
end
Application=[];


if isempty(strfind(Path2file,'\')) % if only FilenameTotal is provided
    Path2file=getPathRaw(Path2file);
end
if exist(Path2file,'file')==0; A1=asdf; end; % Path2file does not exist

% if exist('ImarisVersion')~=1 || isempty(ImarisVersion);
%     ImarisVersion=W.Imaris.ImarisVersion;
% end
if exist('PixMin','Var')~=1
    PixMin=[0;0;0;0;0];
end
if exist('PixMax','Var')~=1
    PixMax=[0;0;0;0;0];
end
if exist('Resample')~=1
    Resample=[1;1;1;1;1];
end

if size(PixMax,1)==3
    PixMax=[PixMax;0;1];
end
if min(PixMax(:))<0 || min(PixMin(:))<0
    A1=asdf;
end
if strcmp(W.Imaris.ImarisVersion,'7.7.2') && PixMin(4)==0&&PixMax(4)==1
    keyboard;
    PixMax(4)=2;
    ProblemImaris772=1;
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
    try; UmMinMax=[[0;0;0],Resolution.*PixMax(1:3)]; end;
end

Croplimitsmin=mat2str(PixMin.');Croplimitsmin=Croplimitsmin(2:end-1);
Croplimitsmax=mat2str(PixMax.');Croplimitsmax=Croplimitsmax(2:end-1);
Resample=mat2str(Resample.');Resample=Resample(2:end-1);

Specifier=['reader="All Formats" croplimitsmin="',Croplimitsmin,'" croplimitsmax="',Croplimitsmax,'" resample="',Resample,'"'];

% load 8bit instead of 16bit
if exist('BitType')==1 && strcmp(BitType,'uint8')
    Path2file=[Path2file(1:end-4),'8bit',Path2file(end-3:end)];
end

ExPath=['cd(''C:\Program Files\Bitplane\Imaris x64 ',W.Imaris.ImarisVersion,'\XT\matlab'');'];
eval(ExPath);

% if exist('TrialNumber')~=1
% TrialNumber=3;
% end
% ImarisInstances
for Trials=1:3
    ObjectID=zeros(0,1,'double');
    try
        Server=W.Imaris.ImarisLib.GetServer;
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
    pause(6); % previously 8 seconds
    
    for m=1:3
        Application=W.Imaris.ImarisLib.GetApplication(Ind);
        if isempty(Application)==0
            break;
        end
        pause(1);
    end
    
    if isempty(Application)==0
%         Wave1=size(W.ImarisId.Id,1)+1;
        W.Imaris.Instances.Id(size(W.Imaris.Instances,1)+1,1)=Ind;
        W.Imaris.Instances.Char(size(W.Imaris.Instances,1),1)={char(Application)};
        W.Imaris.Instances.Application(size(W.Imaris.Instances,1),1)={Application};
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

if isempty(Application)
    A1=asdf; % filepath exists but not loaded
end
% if exist('GetAllStatistics')==1
%     includeAllImarisStatistics(Application);
% end
if exist('SetVisible')~=1 || SetVisible==0
    Application.SetVisible(0);
end

try
    Application.FileOpen(Path2file,Specifier);
    VdataSetIn=Application.GetDataSet;
end
setImarisViewer(Application,'surpass');
Application.GetSurpassScene.SetVisible(0);
if exist('VdataSetIn')~=1
    A1=asdf; % P0237_2: file corrupt
end
if exist('UmMinMax')==1&&isempty(UmMinMax)==0;
    VdataSetIn.SetExtendMinX(UmMinMax(1,1)); VdataSetIn.SetExtendMinY(UmMinMax(2,1)); VdataSetIn.SetExtendMinZ(UmMinMax(3,1));
    VdataSetIn.SetExtendMaxX(UmMinMax(1,2)); VdataSetIn.SetExtendMaxY(UmMinMax(2,2)); VdataSetIn.SetExtendMaxZ(UmMinMax(3,2));
end

if exist('MouseMove','var')~=0
    mouseMoveController(0);
end
