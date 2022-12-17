% get several surfaces at 3 defined timepoints at once
% [data5D]=Im2Matlab(application,{'surface1','surface2','surface3'},[1,5,10],'surface')
% Application,Channels,Timepoints,Identity,Feature
function [Data5D]=im2Matlab_2(In,Channels,Timepoints,Identity)
keyboard; % still in use? 2015.10.09

if isstruct(In)
    v2struct(In);
elseif strcmp(class(In),'Imaris.IApplicationPrxHelper')
   Application=In;
else
    FilenameTotal=In;
    [Fileinfo,IndFileinfo,Path2file]=getFileinfo_2(FilenameTotal);
end

if exist('Application')==1
   [Fileinfo]=getImarisFileinfo(Application); 
end

if exist('Feature','var') && isempty(Feature)==0
    Identity='SurfaceFeature';
else
    Feature=[];
end
BitType=Fileinfo.GetType{1};



Pix=[Application.GetDataSet.GetSizeX;Application.GetDataSet.GetSizeY;Application.GetDataSet.GetSizeZ;Application.GetDataSet.GetSizeC;Application.GetDataSet.GetSizeT];
UmMinMax=[  Application.GetDataSet.GetExtendMinX,Application.GetDataSet.GetExtendMaxX;...
            Application.GetDataSet.GetExtendMinY,Application.GetDataSet.GetExtendMaxY;...
            Application.GetDataSet.GetExtendMinZ,Application.GetDataSet.GetExtendMaxZ];
% default: load all channels and all timepoints

if exist('Identity')==0 || isempty(Identity) % handle channels
    Identity='Channel';
end

if exist('Channels')==0 || isempty(Channels) % default
    Channels=[1:Pix(4)].';
end

if exist('Timepoints')==0 || isempty(Timepoints) % default
    Timepoints=[1:Pix(5)].';
end

if isnumeric(Channels)==0
    if ischar(Channels)
        Channels={Channels};
    end
    if strcmp(Identity,'Channel'); % get ids of channelnames
        for m=1:size(Channels,2)
            [Channels{1,m},ChannelList]=getChannelId(Application,Channels(1,m));
            % develop function that reads out the id number of channel name
        end
        Channels=cell2mat(Channels);
    end
    if strcmp(Identity,'Surface'); % get ids of surfacenames
        for m=1:size(Channels,2)
            if ischar(Channels{1,m})
                [Channels{1,m},Ind,ObjectList]=selectObject(Application,Channels{1,m});
            end
        end
    end
    
end

%% to import channels
if strcmp(Identity,'Channel') % handle channels
    Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),size(Channels,1),BitType);
    for IndT=1:size(Timepoints,1)
        for IndC=1:size(Channels,1);
            J=struct;
            J.DataImarisObject=Application.GetDataSet;
            J.TargetChannel=Channels(IndC,1);
            J.TargetTimepoint=Timepoints(IndT,1);
            J.Pix=Pix;
            J.BitType=BitType;
            J.Application=Application;
            [Data3D]=imarisImporter_2(J);
%             [Data3D]=imarisImporter_2(Application.GetDataSet,Channels(IndC,1),Timepoints(IndT,1),Pix,BitType);
            Data5D(:,:,:,IndT,IndC)=Data3D(:,:,:);
            clear Data3D;
        end
    end
end

%% to import surfaces
if strcmp(Identity,'Surface')
    Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),size(Channels,1),'uint8');
    for IndT=1:size(Timepoints,1);
        for IndC=1:size(Channels,1);
            % select surface
            Vobject=Channels{m,1};
            % get surface mask
            DataImarisObject= Vobject.GetMask(...
                UmMinMax(1,1),UmMinMax(2,1),UmMinMax(3,1),...
                UmMinMax(1,2),UmMinMax(2,2),UmMinMax(3,2),...
                Pix(1),Pix(2),Pix(3),Timepoints(IndT)-1);
            J=struct;
            J.DataImarisObject=DataImarisObject;
            J.TargetChannel=1;
            J.TargetTimepoint=1;
            J.Pix=Pix;
            J.BitType='uint8';
            J.Application=Application;
            [Data3D]=imarisImporter_2(J);
%             [Data3D]=imarisImporter_2(DataImarisObject,1,1,Pix,'uint8');
            Data5D(:,:,:,IndT,IndC)=Data3D(:,:,:);
        end
    end
end

%% to import spots
if strcmp(Identity,'Spot')
    keyboad;
    Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),size(Channels,1),'uint8');
    for IndT=1:size(Timepoints,1);
        for IndC=1:size(Channels,1);
            % select surface
            Vobject=Channels{m,1};
            % get surface mask
            DataImarisObject= Vobject.GetMask(...
                UmMinMax(1,1),UmMinMax(2,1),UmMinMax(3,1),...
                UmMinMax(1,2),UmMinMax(2,2),UmMinMax(3,2),...
                Pix(1),Pix(2),Pix(3),Timepoints(IndT)-1);
            J=struct;
            J.DataImarisObject=DataImarisObject;
            J.TargetChannel=1;
            J.TargetTimepoint=1;
            J.Pix=Pix;
            J.BitType='uint8';
            J.Application=Application;
            [Data3D]=imarisImporter_2(J);
            
%             [Data3D]=imarisImporter_2(DataImarisObject,1,1,Pix,'uint8');
            Data5D(:,:,:,IndT,IndC)=Data3D(:,:,:);
        end
    end
end
% vThisTime = vSpotsTime == vTime;
%     vThisSpots = vSpotsXYZ(vThisTime, :);
%     for vIndexZ = 1:vDataSize(3)
%       vSliceSpots = vThisSpots(vThisSpots(:, 3) == vIndexZ, :);
%       if isempty(vSliceSpots)
%         continue;
%       end
%       vSlice = zeros(vDataSize(1), vDataSize(2), 'uint8');
%       vSlice(vSliceSpots(:, 1) + (vSliceSpots(:, 2) - 1) * vDataSize(1)) = 1;

%% import surfaceFeature
% FeatureChannel=15;
if isempty(Feature)==0
    cprintf('text','im2Matlab_2');
    [Vobject,Ind,ObjectList]=selectObject(Application,Channels);
    if exist('ObjectInfo')~=1
        [ObjectInfo]=getObjectInfo_2(Vobject,[],Application,1);
    end
    FeatureNumber=size(Feature,1);
    Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),FeatureNumber,BitType);
    Feature3D=zeros(Pix(1),Pix(2),Pix(3),BitType);
    for IndFeature=1:FeatureNumber
        cprintf('text',[', Feature: ',Feature]);
        for IndT=1:size(Timepoints,1)
            cprintf('text',[', Timepoint: ',num2str(Timepoints(IndT,1)),', IDs: ']);
            IDs=find(ObjectInfo.ObjInfo.TimeIndex==Timepoints(IndT,1));
            IDs=table(double(ObjectInfo.ObjInfo.Id(IDs)),[ObjectInfo.ObjInfo.PositionX(IDs),ObjectInfo.ObjInfo.PositionY(IDs),ObjectInfo.ObjInfo.PositionZ(IDs)],[ObjectInfo.ObjInfo.BoundingBoxAALengthX(IDs),ObjectInfo.ObjInfo.BoundingBoxAALengthY(IDs),ObjectInfo.ObjInfo.BoundingBoxAALengthZ(IDs)],'VariableNames',{'IDs','PositionXYZ','SizeXYZ'});
            IDs.UmMinXYZ=IDs.PositionXYZ-IDs.SizeXYZ;
            IDs.UmMaxXYZ=IDs.PositionXYZ+IDs.SizeXYZ;
            for m=1:size(IDs,1)
                for m2=1:3
                    if IDs.UmMinXYZ(m,m2)<UmMinMax(m2,1)
                        IDs.UmMinXYZ(m,m2)=UmMinMax(m2,1);
                    end
                    if IDs.UmMaxXYZ(m,m2)>UmMinMax(m2,2)
                        IDs.UmMaxXYZ(m,m2)=UmMinMax(m2,2);
                    end
                end
                IDs.PixMinXYZ(m,1:3)=floor((IDs.UmMinXYZ(m,:)-Fileinfo.UmStart{1}.')./Fileinfo.Res{1}.');
                IDs.PixMaxXYZ(m,1:3)=ceil((IDs.UmMaxXYZ(m,:)-Fileinfo.UmStart{1}.')./Fileinfo.Res{1}.');
                IDs.UmMinXYZ(m,:)=(IDs.PixMinXYZ(m,:).*Fileinfo.Res{1}.')+Fileinfo.UmStart{1}.';
                IDs.UmMaxXYZ(m,:)=(IDs.PixMaxXYZ(m,:).*Fileinfo.Res{1}.')+Fileinfo.UmStart{1}.';
            end
            IDs.Pix=uint16(IDs.PixMaxXYZ-IDs.PixMinXYZ);
            IDs.PixMinXYZ=IDs.PixMinXYZ+1;
            for m=1:size(IDs,1)
                cprintf('text',[num2str(m),',']);
                DataImarisObject=Vobject.GetSingleMask(IDs.IDs(m,1),...
                    IDs.UmMinXYZ(m,1),IDs.UmMinXYZ(m,2),IDs.UmMinXYZ(m,3),...
                    IDs.UmMaxXYZ(m,1),IDs.UmMaxXYZ(m,2),IDs.UmMaxXYZ(m,3),...
                    IDs.Pix(m,1),IDs.Pix(m,2),IDs.Pix(m,3));
                J=struct;
                J.DataImarisObject=DataImarisObject;
                J.TargetChannel=1;
                J.TargetTimepoint=1;
                J.Pix=IDs.Pix(m,:).';
                J.BitType='uint8';
                J.Application=Application;
                [Data3D]=imarisImporter_2(J);
                FeatureValue=ObjectInfo.ObjInfo{num2str(IDs.IDs(m,1)),Feature};
                if strfind1(Feature,{'TrackId';'Id'},1)
                    FeatureValue=FeatureValue+1;
                end
                Wave2=Feature3D(IDs.PixMinXYZ(m,1):IDs.PixMaxXYZ(m,1),IDs.PixMinXYZ(m,2):IDs.PixMaxXYZ(m,2),IDs.PixMinXYZ(m,3):IDs.PixMaxXYZ(m,3));
                Wave2(Data3D==1)=FeatureValue;
                Feature3D(IDs.PixMinXYZ(m,1):IDs.PixMaxXYZ(m,1),IDs.PixMinXYZ(m,2):IDs.PixMaxXYZ(m,2),IDs.PixMinXYZ(m,3):IDs.PixMaxXYZ(m,3))=Wave2(:,:,:);
            end
            Data5D(:,:,:,IndT,IndFeature)=Feature3D(:,:,:);
        end
    end
    cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);
end
