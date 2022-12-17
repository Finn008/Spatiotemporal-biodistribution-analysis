% [Application]=dataInspector3D(PlaqueMapTotal(:,:,:,Time),Res);
function [Application]=dataInspector3D(Data,Res,ChannelNames,Large,FilenameTotal,Visibility)
global W;
Pix=[1;1;1;1];
if isnumeric(Data); Data={Data}; end;
Wave1=size(Data{1}).';
Pix(1:size(Wave1,1))=Wave1;
% J=struct;
if exist('Res')==1
    UmMinMax=[[0;0;0],Pix(1:3).*Res];
end
if exist('Visibility')~=1
    Visibility=1;
end
if exist('ChannelNames')~=1
    ChannelNames={'Data'};
end
if ischar(ChannelNames)
    ChannelNames={ChannelNames};
end
if exist('FilenameTotal')~=1
    FilenameTotal='DataInspector.ims';
end

% J.PixMax=[Pix(1:3);0;Pix(4)];
% J.Path2file=W.Imaris.PathImarisSample;

% Application=openImaris_4(J);
[Application]=openImaris_4([Pix(1:3);0;Pix(4)],[],[],[],UmMinMax);
if exist('Large')==1 && Large==1
    Path2file=getPathRaw(FilenameTotal);
    Application.FileSave(Path2file,'writer="Imaris5"');
    quitImaris(Application);
    for Ch=1:size(Data,1)
        ex2Imaris_2(Data{Ch},FilenameTotal,ChannelNames{Ch});
    end
    if Visibility==1
        imarisSaveHDFlock(FilenameTotal);
        Application=openImaris_4(FilenameTotal);
        Application.SetVisible(1);
    end
else
    Application.SetVisible(1);
    for Ch=1:size(Data,1)
        ex2Imaris_2(Data{Ch},Application,Ch);
        if exist('ChannelNames')~=0
            Application.GetDataSet.SetChannelName(Ch-1,ChannelNames{Ch});
        end
    end
    
end

if W.SingularImarisInstance==1
    mouseMoveController(0);
end
