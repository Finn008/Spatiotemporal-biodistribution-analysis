function writeHDF5(Data5D,FilenameTotal,Channels,Timepoints,X,Y,Z)
keyboard; % integrate into ex2Imaris_2
[Path2file,Report]=getPathRaw(FilenameTotal);
if Report==0
    keyboard;
end
[Fileinfo,Wave1]=getHD5Fileinfo(FilenameTotal);
BitType=Wave1.BitType{1};



ChannelNumber=size(Fileinfo.ChannelList{1},1);
if isnumeric(Channels)
    ChannelName=num2strArray_2(Channels);
else
    if ischar(Channels); Channels={Channels}; end;
    ChannelName=Channels;
    for IndC=1:size(Channels,1)
        Channels2(IndC,1)=strfind1(Fileinfo.ChannelList{1},Channels{IndC,1},1);
        if Channels2(IndC,1)==0
            % use first emtpy channel
            Wave1=strfind1(Fileinfo.ChannelList{1},'empty');
            Channels2(IndC,1)=Wave1(1); % if several emtpy channels available
        end
        if Channels2(IndC,1)==0
            ChannelNumber=ChannelNumber+1;
            Channels2(IndC,1)=ChannelNumber;
        end
    end
    Channels=Channels2;
end

% rename new channels
if max(Channels(:))>size(Fileinfo.ChannelList{1},1)
    ChInd=find(Channels>size(Fileinfo.ChannelList{1},1));
    for m=ChInd.'
        Location=['/DataSetInfo/Channel 0'];
        Table=h5info(Path2file,Location);
        Table=struct2table(Table.Attributes,'RowNames',{Table.Attributes.Name}.');
        
        Table.Value('Name')={char2cell(ChannelName{ChInd})};
        Location=['/DataSetInfo/Channel ',num2str(Channels(ChInd)-1),'/A'];
        h5create(Path2file,Location,1);
        Location=['/DataSetInfo/Channel ',num2str(Channels(ChInd)-1)];
        for Atr=1:size(Table,1)
            h5writeatt_2(Path2file,Location,Table.Name{Atr,1},Table.Value{Atr,1});
        end
    end
end


TotalTimepoints=max(max(Timepoints(:)),Fileinfo.GetSizeT);
if max(Channels(:))>size(Fileinfo.ChannelList{1},1) || max(Timepoints(:))>Fileinfo.GetSizeT
    MaxSize=h5read(Path2file,'/DataSet/ResolutionLevel 0/TimePoint 0/Channel 0/Data');
    MaxSize=size(MaxSize);
    for IndT=1:TotalTimepoints
        for IndC=1:ChannelNumber
            Location=['/DataSet/ResolutionLevel 0/TimePoint ',num2str(IndT-1),'/Channel ',num2str(IndC-1),'/Data'];
            try
                Wave1=h5info(Path2file,Location);
            catch
                h5create(Path2file,Location,MaxSize,'Datatype',BitType);
            end
        end
    end
end
PixTotal=Fileinfo.Pix{1};


if exist('X')~=1 || isempty(X)
    X=[1;PixTotal(1)];
end
if exist('Y')~=1 || isempty(Y)
    Y=[1;PixTotal(2)];
end
if exist('Z')~=1 || isempty(Z)
    Z=[1;PixTotal(3)];
end
if exist('Channels')~=1 || isempty(Channels)
    Channels=(1:Fileinfo.GetSizeC(1)).';
end

if exist('Timepoints')~=1 || isempty(Timepoints)
    Timepoints=(1:Fileinfo.GetSizeC(1)).';
end
Pix=[X(2)-X(1)+1;Y(2)-Y(1)+1;Z(2)-Z(1)+1];

Channels=Channels-1;
Timepoints=Timepoints-1;



% to import channels
for IndT=1:size(Timepoints,1)
    for IndC=1:size(Channels,1)
        Location=['/DataSet/ResolutionLevel 0/TimePoint ',num2str(Timepoints(IndT)),'/Channel ',num2str(Channels(IndC)),'/Data'];
        
        h5write(Path2file,Location,Data5D(:,:,:,IndT,IndC),[X(1),Y(1),Z(1)],[Pix(1),Pix(2),Pix(3)]);
    end
end

