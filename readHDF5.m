function [Data5D]=readHDF5(FilenameTotal,Channels,Timepoints,X,Y,Z)
[Path2file,Report]=getPathRaw(FilenameTotal);
[Fileinfo,Wave1]=getHD5Fileinfo(FilenameTotal);
BitType=Wave1.BitType{1};

if isnumeric(Channels)==0
    if ischar(Channels)
        Channels={Channels};
    end
    if size(Channels,1)>1
        keyboard;
    end
    Channels=strfind1(Fileinfo.ChannelList{1},Channels);
end

if exist('X')~=1 || isempty(X)
    X=[1;Fileinfo.Pix{1}(1)];
end
if exist('Y')~=1 || isempty(Y)
    Y=[1;Fileinfo.Pix{1}(2)];
end
if exist('Z')~=1 || isempty(Z)
    Z=[1;Fileinfo.Pix{1}(3)];
end
if exist('C')~=1 || isempty(Channels)
    C=(1:Fileinfo.GetSizeC(1)).';
end

if exist('T')~=1 || isempty(Timepoints)
    Timepoints=(1:Fileinfo.GetSizeC(1)).';
end
Pix=[X(2)-X(1)+1;Y(2)-Y(1)+1;Z(2)-Z(1)+1;size(Timepoints,1);size(Channels,1)];

Channels=Channels-1;
Timepoints=Timepoints-1;

% to import channels
Data5D=zeros(Pix(1),Pix(2),Pix(3),Pix(4),Pix(5),BitType);
for IndT=1:size(Timepoints,1)
    for IndC=1:size(Channels,1)
        Location=['/DataSet/ResolutionLevel 0/TimePoint ',num2str(Timepoints(IndT)),'/Channel ',num2str(Channels(IndC)),'/Data'];
        Data3D=h5read(Path2file,Location,[X(1),Y(1),Z(1)],[Pix(1),Pix(2),Pix(3)]);
        Data5D(:,:,:,IndT,IndC)=Data3D(:,:,:);
        clear Data3D;
    end
end
