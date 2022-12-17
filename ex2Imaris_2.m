% RGBA: redish: [1,0.5,0,0]; greenish: [0.5,1,0,0]; white: [1,1,1,0]; blue
% [0,0,1,0]; red [1,0,0,0]
% Application,Data5D,Channels,Timepoints,ChannelName,RGBA,ChannelRange
function [Report]=ex2Imaris_2(Data5D,In,Channels,Timepoints,Res,BitType,H5start)

global W;
if isstruct(In)
    v2struct(In);
elseif strcmp(class(In),'Imaris.IApplicationPrxHelper')
    Application=In;
else
    FilenameTotal=In;
end
if exist('BitType','Var')==0
    BitType='uint16';
end
if exist('Application')==1
    [Fileinfo]=getImarisFileinfo(Application);
else
    [Path2file,Report]=getPathRaw(FilenameTotal);
    if Report==0 && exist('Res','Var')==1
%         keyboard;

        [Application2]=openImaris_4([size(Data5D).';0;1],Res,[],[],[],BitType); % class(Data5D)
        Application2.FileSave(Path2file,'writer="Imaris5"');
        quitImaris(Application2);

    end
%     W.G.Fileinfo.DoGetFileinfo(Ind)
    [Fileinfo]=extractFileinfo(FilenameTotal);
%     [Fileinfo,IndFileinfo,Path2file]=getFileinfo_2(FilenameTotal);
    Application=[];
end

BitType=Fileinfo.GetType{1};
if strcmp(class(Data5D),BitType)==0
    Data5D=cast(Data5D,BitType);
end
if exist('Identity')~=1
    Identity='Channel';
end

if exist('Channels')==1
    Identity='Channel';
    if exist('Channels')~=1 || isempty(Channels)
        keyboard;
        Channels=(1:size(Data5D,5)).';
    end
elseif exist('TargetSurface')==1
    Identity='Surface';
else
    Channels=1;
end


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
            Wave1=strfind1(Fileinfo.ChannelList{1},{'empty';'(name not specified)';''});
            Channels2(IndC,1)=Wave1(1); % if several emtpy channels available
        end
        if Channels2(IndC,1)==0
            ChannelNumber=ChannelNumber+1;
            Channels2(IndC,1)=ChannelNumber;
        end
    end
    Channels=Channels2;
end
if exist('Timepoints')==0 || isempty(Timepoints)
    Timepoints=(1:size(Data5D,4)).';
end

%% delete channel or surface
if strcmp(Data5D,'Remove')
    keyboard; % does not work yet
    if strcmp(Identity,'Channel')
        ResolutionLevels=h5info(Path2file,'/DataSet');
        ResolutionLevels=table({ResolutionLevels.Groups.Name}.','VariableNames',{'Name'});
        for ResLevel=1:size(ResolutionLevels,1)
            Location=['/DataSet/ResolutionLevel ',num2str(ResLevel)-1,'/TimePoint 0/Channel ',num2str(Channels-1)];
            h5delete_2(Path2file,Location);
        end
    elseif strcmp(Identity,'Surface')
        keyboard;
    else
        keyboard;
    end
    return;
end

%% write HDF5
if isempty(Application)
    if exist('GZIPcompression')~=1
        GZIPcompression=2;
    end
    ResolutionLevels=h5info(Path2file,'/DataSet');
    ResolutionLevels=table({ResolutionLevels.Groups.Name}.','VariableNames',{'Name'});
    for ResLevel=1:size(ResolutionLevels,1)
        Wave1=h5info(Path2file,['/DataSet/ResolutionLevel ',num2str(ResLevel)-1,'/TimePoint 0/Channel 0/Data']);
        ResolutionLevels.MaxSize(ResLevel)={Wave1.Dataspace.MaxSize.'};
        ResolutionLevels.ChunkSize(ResLevel)={Wave1.ChunkSize.'};
        Wave1=h5info(Path2file,['/DataSet/ResolutionLevel ',num2str(ResLevel)-1,'/TimePoint 0/Channel 0']);
        Wave1=struct2table(Wave1.Attributes,'RowNames',{Wave1.Attributes.Name}.');
        Wave2(1,1)=str2num(strjoin(Wave1.Value{'ImageSizeX'}.',''));
        Wave2(2,1)=str2num(strjoin(Wave1.Value{'ImageSizeY'}.',''));
        Wave2(3,1)=str2num(strjoin(Wave1.Value{'ImageSizeZ'}.',''));
        ResolutionLevels.RealSize(ResLevel)={Wave2};
    end
    
    % add channels and timepoints
    TotalTimepoints=max(max(Timepoints(:)),Fileinfo.GetSizeT);
    for ResLevel=1:size(ResolutionLevels,1)
        for IndT=1:TotalTimepoints%max(Timepoints(:))
            for IndC=1:size(Channels,1)
                Location=['/DataSet/ResolutionLevel ',num2str(ResLevel-1),'/TimePoint ',num2str(IndT-1),'/Channel ',num2str(Channels(IndC)-1),'/Data'];
                try
                    Wave1=h5info(Path2file,Location);
                catch
                    h5create(Path2file,Location,ResolutionLevels.MaxSize{ResLevel,1}.','Datatype',BitType,'ChunkSize',ResolutionLevels.ChunkSize{ResLevel,1}.','Deflate',GZIPcompression);
                    
                end
            end
        end
    end
    
    PixTotal=Fileinfo.Pix{1};
    if size(Channels,1)>1
        keyboard; % check renaming
    end
    % rename new channels
    for m=1:size(Channels,1)
        Location=['/DataSetInfo/Channel 0'];
        Table=h5info(Path2file,Location);
        Table=struct2table(Table.Attributes,'RowNames',{Table.Attributes.Name}.');
        Table.Value('Name')={char2cell(ChannelName{m})};
        
        
        Location=['/DataSetInfo/Channel ',num2str(Channels(m,1)-1)];
%         Location=['/DataSetInfo/Channel ',num2str(Channels(m,1)-1)];
        try
            Wave1=h5info(Path2file,Location);
        catch
%         if Channels(m,1)>size(Fileinfo.ChannelList{1},1) || strcmp(Fileinfo.ChannelList{1}{Channels(m,1)},ChannelName{m})==0
            
%             Location=['/DataSetInfo/Channel ',num2str(Channels(m,1)-1),'/A'];
            h5create(Path2file,[Location,'/A'],1);
        end
        
        for Atr=1:size(Table,1)
            h5writeatt_2(Path2file,Location,Table.Name{Atr,1},Table.Value{Atr,1});
        end
        
        
    end
%     if exist('PixMinMax')~=1
%         PixMinMax=[[1;1;1],PixTotal];
%     end
%     if isequal(PixMinMax,[[1;1;1],PixTotal])==0
%         keyboard; % check how to place Resolution Levels?? ... h5write(Path2file,Location,Data3D,PixMinMax(:,1).',PixMinMax(:,2).');
%     end
    
    % to import channels
    if exist('H5start','Var')~=1
        H5start=[1,1,1];
    end
    for IndT=1:size(Timepoints,1)
        for IndC=1:size(Channels,1)
            
            for ResLevel=1:size(ResolutionLevels,1)
                if ResLevel==1
                    Data3D=Data5D(:,:,:,IndT,IndC);
                else
                    OrigRealSize=ResolutionLevels.RealSize{1,1};
                    RealSize=ResolutionLevels.RealSize{ResLevel,1};
                    Xi=round(linspace(1,OrigRealSize(1),RealSize(1)));
                    Yi=round(linspace(1,OrigRealSize(2),RealSize(2)));
                    Zi=round(linspace(1,OrigRealSize(3),RealSize(3)));
                    Data3D=Data5D(Xi,Yi,Zi,IndT,IndC);
                end
                Location=['/DataSet/ResolutionLevel ',num2str(ResLevel-1),'/TimePoint ',num2str(Timepoints(IndT)-1),'/Channel ',num2str(Channels(IndC)-1),'/Data'];
                try
                    h5write(Path2file,Location,Data3D,H5start,size(Data3D));
                catch Error
                    keyboard;
                    if strcmp(Error.message,'The HDF5 library encountered an unknown error.')
                        accessImarisManually(Path2file,struct('Function','DeleteChannel','ChannelList',[Channels(IndC)]));
                    end
                    h5write(Path2file,Location,Data3D,H5start,size(Data3D));
                end
            end
        end
    end
end

%% write via Imaris
if isempty(Application)==0
    %     keyboard; % check if still works after integration
    cprintf('text','ex2Imaris:');
    if max(Channels(:))>Application.GetDataSet.GetSizeC
        cprintf('text',' AddingChannelDim,');
        Application.GetDataSet.SetSizeC(max(Channels(:)));
    end
    if Fileinfo.GetSizeT<max(Timepoints(:))
        cprintf('text',' AddingTimeDim,');
        Application.GetDataSet.SetSizeT(max(Timepoints(:)));
    end
    %% to export to channels
    if strcmp(Identity,'Channel') % handle channels
        
        
        for IndT=1:size(Timepoints,1);
            for IndC=1:size(Channels,1);
                cprintf('text',[' Ch',ChannelName{IndC,1},'/Tp',num2str(Timepoints(IndT,1)),' ']);
                J=struct;
                J.DataImarisObject=Application.GetDataSet;
                J.TargetChannel=Channels(IndC,1);
                J.TargetTimepoint=Timepoints(IndT,1);
                imarisImporter_2(J,Data5D(:,:,:,IndT,IndC));
            end
        end
        cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);
        if exist('ChannelName','var') && isempty(ChannelName)==0
            for IndC=1:size(ChannelName,1)
                Application.GetDataSet.SetChannelName(Channels(IndC,1)-1,ChannelName{IndC,1});
            end
        end
        if exist('RGBA','var') && isempty(RGBA)==0
            RGBA=RGBAconverter(RGBA);
            Application.GetDataSet.SetChannelColorRGBA(Channels-1,RGBA)
        end
        if exist('ChannelRange')==1 && isempty(ChannelRange)==0
            Application.GetDataSet.SetChannelRange(Channels-1,ChannelRange(1),ChannelRange(2));
        end
        
        
        
    end
    %% to export to surfaces
    if strcmp(Identity,'Surface')
        [Vobject,Ind,ObjectList]=selectObject(Application,TargetSurface);
        if isempty(Vobject) % generate new SurfaceObject
            %% The following MATLAB code creates a Volume object and adds it to the Surpass scene.
            %% Remark: do not add more than one Volume object to the same Surpass scene.
            Vobject=Application.GetFactory.CreateSurfaces;
            Application.GetSurpassScene.AddChild(Vobject,-1);
            Vobject.SetName(TargetSurface);
        end
        [Results]=getObjectInfo_2(Vobject,[],Application);
        Edges=Vobject.GetTrackEdges();
        for m=1:size(SurfaceInfo,1)
            Vobject.AddSurface(SurfaceInfo.Vertices{m},SurfaceInfo.Triangles{m},SurfaceInfo.Normals{m},SurfaceInfo.TargetTimepoint(m)-1);
            SurfaceInfo.ID(m,1)=max(Edges(:))+m;
            Results.IDmap(SurfaceInfo.TrackID(m)+1,SurfaceInfo.TargetTimepoint(m))=SurfaceInfo.ID(m,1);
        end
        for m=1:size(SurfaceInfo,1)
            SurfaceInfo.ID2connect(m,1)=Results.IDmap(SurfaceInfo.TrackID(m)+1,SurfaceInfo.TargetTimepoint(m)+1);
            Edges(end+1,:)=[SurfaceInfo.ID(m,1),SurfaceInfo.ID2connect(m,1)];
        end
        Vobject.SetTrackEdges(Edges);
    end
end


