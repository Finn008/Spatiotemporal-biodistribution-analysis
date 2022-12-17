function [Fileinfo]=getImarisFileinfo(Application)
VdataSetIn=Application.GetDataSet;
if isempty(VdataSetIn)
%     W.ErrorMessage=['File corrupt: ',NameTable{'DeFin','FilenameTotal'}];
    A1=qwertzuiop; % File could not be opened by Imaris
end
Fileinfo=table;

%% imaris specific info
% keyboard;
Fileinfo.GetSizeC=VdataSetIn.GetSizeC;
Fileinfo.GetSizeT=VdataSetIn.GetSizeT;
Fileinfo.GetType=VdataSetIn.GetType;
GetSizeX=VdataSetIn.GetSizeX;
GetSizeY=VdataSetIn.GetSizeY;
GetSizeZ=VdataSetIn.GetSizeZ;
GetExtendMinX=VdataSetIn.GetExtendMinX;
GetExtendMinY=VdataSetIn.GetExtendMinY;
GetExtendMinZ=VdataSetIn.GetExtendMinZ;
GetExtendMaxX=VdataSetIn.GetExtendMaxX;
GetExtendMaxY=VdataSetIn.GetExtendMaxY;
GetExtendMaxZ=VdataSetIn.GetExtendMaxZ;
% Wave1={'GetSizeC','GetSizeT','GetSizeX','GetSizeY','GetSizeZ','GetExtendMinX','GetExtendMinY','GetExtendMinZ','GetExtendMaxX','GetExtendMaxY','GetExtendMaxZ','GetType'}.';
% for n=1:size(Wave1);
%     Path=['Fileinfo.',Wave1{n},'=VdataSetIn.',Wave1{n},';'];
%     eval(Path);
% end
Fileinfo.Pix={[GetSizeX;GetSizeY;GetSizeZ]};
Fileinfo.UmStart={[GetExtendMinX;GetExtendMinY;GetExtendMinZ]};
Fileinfo.UmEnd={[GetExtendMaxX;GetExtendMaxY;GetExtendMaxZ]};
Fileinfo.Um={Fileinfo.UmEnd{1}-Fileinfo.UmStart{1}};
Fileinfo.Res={Fileinfo.Um{1}./Fileinfo.Pix{1}};

[Wave1,Fileinfo.ChannelList{1}]=getChannelId(Application);
[Wave1,Wave2,Fileinfo.ObjectList{1}]=selectObject(Application);

% keyboard;
% Additionally=struct;
% BitType=VdataSetIn.GetType;
if strcmp(Fileinfo.GetType(1),'eTypeUInt8')
    Fileinfo.GetType={'uint8'};
elseif strcmp(Fileinfo.GetType(1),'eTypeUInt16')
    Fileinfo.GetType={'uint16'};
elseif strcmp(Fileinfo.GetType(1),'eTypeFloat')
    Fileinfo.GetType={'single'};
end
