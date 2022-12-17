% get several surfaces at 3 defined timepoints at once
% [data5D]=Im2Matlab(application,{'surface1','surface2','surface3'},[1,5,10],'surface')
% Application,Channels,Timepoints,Identity,Feature
function [Data5D]=im2Matlab_4(In,Channels,Timepoints,Res,UmMinMax) % Identity,
global W;
% keyboard;
% Container=struct;
if isstruct(In)
    v2struct(In);
elseif strcmp(class(In),'Imaris.IApplicationPrxHelper')
    Application=In;
else
    FilenameTotal=In;
    [Fileinfo,IndFileinfo,Path2file]=getFileinfo_2(FilenameTotal);
end

if exist('Application')==1
    %     [Fileinfo,IndFileinfo,Path2file]=getFileinfo_2(FilenameTotal);
    [Fileinfo]=getImarisFileinfo(Application);
    %     [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application,0);
end

if exist('Feature','var') && isempty(Feature)==0
    Identity='SurfaceFeature';
else
    Feature=[];
end

if exist('Identity')==0 || isempty(Identity) % handle channels
    Identity='Channel';
end

PixOrig=Fileinfo.Pix{1};
BitType=Fileinfo.GetType{1};
ResOrig=Fileinfo.Res{1};
UmMinMaxOrig=[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}];
if exist('UmMinMax','Var')~=1 || isempty(UmMinMax)
    UmMinMax=UmMinMaxOrig;
end

if exist('Res')~=1 || isempty(Res)
    Res=ResOrig;
end
% PixMinMaxOrig=
PixMinMax=ceil((UmMinMax*0.9999999999999)./repmat(Res,[1,2]));
% PixMinMax=(UmMinMax*0.9999999999999)./repmat(Res,[1,2]);
% Wave1=PixMinMax(:,2); Wave1(Wave1>PixOrig)=PixOrig(Wave1>PixOrig);
% PixMinMax(:,2)=Wave1;
PixMinMax(PixMinMax<1)=1;
PixMinMaxOrig=ceil((UmMinMax*0.999999)./repmat(ResOrig,[1,2]));
PixMinMaxOrig(PixMinMaxOrig<1)=1;
% if exist('PixMinMax')==0 || isempty(PixMinMax) % default
%     PixMinMax=[[1;1;1],[PixTotal]];
% end
Pix=PixMinMax(:,2)-PixMinMax(:,1)+1; % Pix size of final subset image

% if exist('ResCalc')==1 && isempty(ResCalc)==0
%     Stride=floor(ResCalc./ResOrig);
% else
%     Stride=[1;1;1];
% end

if exist('Channels')==0 || isempty(Channels) % default
    Channels=[1:Fileinfo.GetSizeC].';
end

if exist('Timepoints')==0 || isempty(Timepoints) % default
    Timepoints=[1:Fileinfo.GetSizeT].';
end

if ischar(Channels)
    Channels={Channels};
end
if size(Channels,2)>1
    keyboard;
end

if strfind1({'Surface';'Spot';'SurfaceFeature'},Identity,1)
    Objects=Channels;
    Channels=1; % load only one data channel, not first because otherwise Imaris crashes
end

if strcmp(Identity,'Channel') && isnumeric(Channels)==0
    if isnumeric(Channels{1})
        Channels=cell2mat(Channels);
    else
        ChannelNames=Channels;
        for m=1:size(Channels,1)
            Channels{m,1}=strfind1(Fileinfo.ChannelList{1},Channels{m,1},1);
        end
        Channels=cell2mat(Channels);
        if isempty(find(Channels==0))==0
            %         W.ErrorMessage=['Channels ',strjoin(ChannelNames(find(Channels==0)).'),' not exist in ',FilenameTotal];
            A1=asdf; % Channel does not exist in the dataset
        end
    end
end

% select import version
if exist('Application') && strcmp(class(Application),'Imaris.IApplicationPrxHelper')
    DataImporter='Imaris';
elseif strcmp(Fileinfo.Type{1},'.ims')
    
    if strfind1({'Surface';'SurfaceFeature'},Identity)
        DataImporter='Imaris';
        if isequal(Pix,PixMinMax(:,2))==0 || size(Channels,1)>1 || Timepoints(1)~=1
            keyboard; % open such that only needed chunk is loaded, change Pix, TargetChannel and Timepoints such that from the small chunk the correct things are imported
        end
        J=struct;
        J.PixMin=[PixMinMax(1,1)-1;PixMinMax(2,1)-1;PixMinMax(3,1)-1;min(Channels(:))-1;min(Timepoints(:))-1];
        J.PixMax=[PixMinMax(1,2)-1;PixMinMax(2,2)-1;PixMinMax(3,2)-1;max(Channels(:));max(Timepoints(:))-1];
        J.Path2file=Path2file;
        J.ImarisVersion='7.6.0';
        Application=openImaris_2(J);
        QuitImaris=1;
        Channels=Channels-min(Channels(:))+1;
        Timepoints=Timepoints-min(Timepoints(:))+1;
    elseif strfind1({'Channel';'Spot'},Identity)
        DataImporter='HDF5loader';
    end
else
    DataImporter='BFloader';
end


%% to import channels
if strcmp(Identity,'Channel') % handle channels
% %     Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),size(Channels,1),BitType);
    for IndT=1:size(Timepoints,1)
        for IndC=1:size(Channels,1);
            if strcmp(DataImporter,'Imaris')
                if isequal(PixOrig,Pix)==0
                    keyboard; % differentiate between selected PixMinMax and TotalPix
                end
                J=struct;
                J.DataImarisObject=Application.GetDataSet;
                J.TargetChannel=Channels(IndC,1);
                J.TargetTimepoint=Timepoints(IndT,1);
                J.Pix=Pix;
                J.BitType=BitType;
                J.Application=Application;
                [Data3D]=imarisImporter_2(J);
            elseif strcmp(DataImporter,'HDF5loader')
                Location=['/DataSet/ResolutionLevel 0/TimePoint ',num2str(Timepoints(IndT)-1),'/Channel ',num2str(Channels(IndC)-1),'/Data'];
                if isequal(ResOrig,Res)
                    Data3D=h5read(Path2file,Location,double(PixMinMax(:,1)),double(Pix(:,1)));
                else
                    Stride=floor(Res./ResOrig);
                    Count=floor((PixMinMaxOrig(:,2)-PixMinMaxOrig(:,1))./Stride);
                    Data3D=h5read(Path2file,Location,double(PixMinMaxOrig(:,1)),double(Count),double(Stride));
                    
                    Xi=round(linspace(1,size(Data3D,1),Pix(1)));
                    Yi=round(linspace(1,size(Data3D,2),Pix(2)));
                    Zi=round(linspace(1,size(Data3D,3),Pix(3)));
                    Data3D=Data3D(Xi,Yi,Zi);
                end
%                 Data3D=h5read(Path2file,Location,double(PixMinMax(:,1)),[4297;5509;1635],Stride);
            elseif strcmp(DataImporter,'BFloader')
                OrigW=W;
                [Data3D]=imreadBF_3(Path2file,PixMinMax,Timepoints(IndT),Channels(IndC),BitType);
                global W; W=OrigW;
            end
            if size(Channels,1)==1 && size(Timepoints,1)==1
                Data5D=Data3D;
            else
                Data5D(:,:,:,IndT,IndC)=Data3D(:,:,:);
            end
            clear Data3D;
        end
    end
end

%% to import surfaces
if strcmp(Identity,'Surface')
    %     keyboard; % differentiate between selected PixMinMax and TotalPix
    for m=1:size(Objects,2)
        if ischar(Objects{1,m})
            [Objects{1,m},Ind,ObjectList]=selectObject(Application,Objects{1,m});
        end
    end
    Data5D=zeros(Pix(1),Pix(2),Pix(3),size(Timepoints,1),size(Objects,1),'uint8');
    for IndT=1:size(Timepoints,1);
        for IndC=1:size(Objects,1);
            % select surface
            Vobject=Objects{m,1};
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
    %     keyboard;
    if strcmp(DataImporter,'Imaris')
        [Vobject]=selectObject(Application,Objects{1});
        %         Wave1=Application.GetFactory.ToSpots(Application.GetSurpassSelection);
        %         aPositionsXYZ = vSpots.GetPositionsXYZ
        Wave1=Vobject.GetPositionsXYZ;
        Wave2=Vobject.GetRadiiXYZ;
        Statistics=array2table([Wave1,Wave2],'VariableNames',{'PositionX';'PositionY';'PositionZ';'RadiusX';'RadiusY';'RadiusZ'});
        
    else
        keyboard;
        SceneInfo=h5info(Path2file,'/Scene/Content');
        SceneInfo=struct2table(SceneInfo.Groups,'AsArray',1);
        Location=SceneInfo.Name{strfind1(Fileinfo.ObjectList{1}(:,1),Objects{1}),1};
        Location=[Location,'/CoordsXYZR'];
        XYZR=h5read(Path2file,Location).';
        keyboard; %RadiusY and RadiusZ
        Data5D=array2table(XYZR,'VariableNames',{'PositionX';'PositionY';'PositionZ';'RadiusX'});
    end
    [Wave1]=umXYZ2pixXYZ(Statistics{:,{'PositionX','PositionY','PositionZ'}},Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Fileinfo.Pix{1}.');
    Statistics=[Statistics,Wave1];
    Data5D=struct;
    Data5D.ObjInfo=Statistics;
    Data5D.GeneralInfo.Fileinfo=Fileinfo;
    
end

%% import surfaceFeature
if strcmp(Identity,'SurfaceFeature')
    if isequal(Pix,PixMinMax(:,2))==0
        keyboard; % differentiate between selected PixMinMax and TotalPix
    end
    cprintf('text','im2Matlab_2');
    [Vobject,Ind,ObjectList]=selectObject(Application,Objects);
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
                IDs.PixMinXYZ(m,1:3)=round((IDs.UmMinXYZ(m,:)-Fileinfo.UmStart{1}.')./Fileinfo.Res{1}.');
                IDs.PixMaxXYZ(m,1:3)=round((IDs.UmMaxXYZ(m,:)-Fileinfo.UmStart{1}.')./Fileinfo.Res{1}.');
                IDs.UmMinXYZ(m,:)=(IDs.PixMinXYZ(m,:).*Fileinfo.Res{1}.')+Fileinfo.UmStart{1}.';
                IDs.UmMaxXYZ(m,:)=(IDs.PixMaxXYZ(m,:).*Fileinfo.Res{1}.')+Fileinfo.UmStart{1}.';
            end
            IDs.Pix=uint16(IDs.PixMaxXYZ-IDs.PixMinXYZ);
            IDs.Pix(IDs.Pix==0)=1;
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
            Feature3D(:)=0;
        end
    end
    cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);
end


if exist('QuitImaris')==1 && QuitImaris==1
    quitImaris(Application);
end
evalin('caller','global W;');