function [Application]=openImaris(II)
global W;
v2struct(II);
% Path2file=II.Path;

Application=[];

if exist('Path2file')~=1;
    W.DoReport=['P0237_2: filepath not exists: ',Path2file];
    return;
end

if exist('ImarisVersion')~=1 || isempty(ImarisVersion);
    ImarisVersion=W.DefaultImarisVersion;
end
ExPath=['cd(''C:\Program Files\Bitplane\Imaris x64 ',ImarisVersion,'\XT\matlab'');'];
eval(ExPath);

for Trials=1:5;
    W.ImarisId=W.ImarisId+1;
    Path=['! ../../Imaris.exe id',num2str(W.ImarisId),'&'];
    eval(Path);
    pause(W.Pause);
    Application = W.ImarisLib.GetApplication(W.ImarisId);
    if isempty(Application)==0; break; end;
end
if Trials > 1;
    disp(['failed to connect to Imaris ',num2str(Trials-1),' times']);
end
if isempty(Application); 
    W.DoReport=['P0237_2: filepath exists but not loaded: ',Path2file];
    return;
end;

Application.SetVisible(0);

if exist('PixMin')~=1
    PixMin=[0;0;0;0;0];
end
if exist('PixMax')~=1
    PixMax=[0;0;0;0;0];
end
if strcmp(ImarisVersion,'7.7.2')    
    if PixMin(4)==0&&PixMax(4)~=0
        PixMin(4)=1;
        PixMax(4)=PixMax(4)+1;
    end
end
if exist('Resample')~=1
    Resample=[1;1;1;1;1];
end

Croplimitsmin=mat2str(PixMin.');Croplimitsmin=Croplimitsmin(2:end-1);
Croplimitsmax=mat2str(PixMax.');Croplimitsmax=Croplimitsmax(2:end-1);
Resample=mat2str(Resample.');Resample=Resample(2:end-1);

Specifier=['reader="All Formats" croplimitsmin="',Croplimitsmin,'" croplimitsmax="',Croplimitsmax,'" resample="',Resample,'"'];

% load 8bit instead of 16bit
if exist('BitType')==1
    if strcmp(BitType,'uint8')
        Path2file=[Path2file(1:end-4),'8bit',Path2file(end-3:end)];
    elseif strcmp(BitType,'uint16')
    end
end

try
    Application.FileOpen(Path2file,Specifier);
catch
end
VDataSetIn=Application.GetDataSet;
if isempty(VDataSetIn);
    W.DoReport=['P0237_2: file corrupt: ',Path2file];
    Fileinfo=[];
else
    W.DoReport='success';
    if exist('UmMinMax')==1&&isempty(UmMinMax)==0;
        VDataSetIn.SetExtendMinX(UmMinMax(1,1)); VDataSetIn.SetExtendMinY(UmMinMax(2,1)); VDataSetIn.SetExtendMinZ(UmMinMax(3,1));
        VDataSetIn.SetExtendMaxX(UmMinMax(1,2)); VDataSetIn.SetExtendMaxY(UmMinMax(2,2)); VDataSetIn.SetExtendMaxZ(UmMinMax(3,2));
    end

end
