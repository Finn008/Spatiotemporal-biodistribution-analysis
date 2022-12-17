% res, pix, filename, type, center, um, SourceChannel, SourceTimepoint correspond to info on the file to get the raw data from
% tRes and tPix represent the output resolution and pixel size
% um is size of the timeline file

% um values can either specify the boundaries of pixels or their center,
% for me a umValue specifies the most positive boundary of a given pixel,
% so 1.2µm at 0.4 resolution specifies pixel 3, 0µm is pixel zero and -1.2µm is pixel -3
% Path2file,FilenameTotal,SourceChannel,SourceTimepoint,FitCoefs,FitCoefRange,TumMinMax,Tres,Tpix,DepthCorrectionInfo

function [DataOut,Mask,Out]=applyDrift2Data_4(In,SourceChannel)
%% initialize, gather data together
global W;

v2struct(In);

if exist('Interpolation')~=1
    Interpolation='Nearest';
end
if exist('FitCoefRange')~=1
    FitCoefRange=[];
end
if exist('FitCoefs')~=1 || isempty(FitCoefs)
    FitCoefs=[0,0,0;0,0,0;0,0,0];
end
if size(FitCoefs,2)==1
    FitCoefs=[[0,0;0,0;0,0],FitCoefs];
end
if exist('Fileinfo')~=1
    [Fileinfo,FileinfoInd,PathRaw]=getFileinfo_2(FilenameTotal);
end
if exist('PathRaw')==1
    Path2file=PathRaw;
end
% if exist('Path2file')~=1
%     Path2file=PathRaw;
% end

if exist('TumMinMax')==1 && exist('Tpix')==1
    Tres=(TumMinMax(:,2)-TumMinMax(:,1))./double(Tpix);
end

if exist('TumMinMax')~=1
    TumMinMax=[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}];
end

if exist('Tres')~=1
    Tres=Fileinfo.Res{1};
end

if exist('Tpix')~=1
    Tpix=uint16((TumMinMax(:,2)-TumMinMax(:,1))./Tres);
end

if exist('SourceTimepoint')~=1
    SourceTimepoint=1;
end

XYZ=table;
Axis{1}=table;Axis{2,1}=table;Axis{3,1}=table;
Zaxis=table;
XYZ.Tpix=round(Tpix); clear Tpix;
XYZ.Properties.RowNames={'X';'Y';'Z'};
XYZ.Tres=Tres;
XYZ.Ium=Fileinfo.Um{1};
XYZ.Ipix=Fileinfo.Pix{1};
XYZ.Ires=Fileinfo.Res{1};
XYZ.TumMinMax=TumMinMax;
XYZ.TumMinMaxPixCenter=[TumMinMax(:,1)+Tres(:,1)/2,TumMinMax(:,2)-Tres(:,1)/2];
clear TumMinMax; clear Tres;
XYZ.Tum=XYZ.TumMinMax(:,2)-XYZ.TumMinMax(:,1);
XYZ.FitCoefs=FitCoefs; clear FitCoefs;
XYZ.TpixAtiRes=round(XYZ.Tum./XYZ.Ires);

if exist('SourceChannel')==1
    if ischar(SourceChannel)
        SourceChannel={SourceChannel};
    end
    if size(SourceChannel,2)==2
        Identity=cell2mat(SourceChannel(:,2));
        SourceChannel=SourceChannel(:,1);
        SourceSurfaces=find(Identity==1);
        OrigSourceChannel=SourceChannel;
        SourceChannel(SourceSurfaces,1)={'PlaceHolderForSurface'};
    else
        OrigSourceChannel=SourceChannel;
    end
    ChannelDeleteFlag=zeros(0,0);
    
    if exist('InterCalc')
        for m=1:size(InterCalc,1)
            if InterCalc{m,1}==2 % threshold MetBlue by value 'Threshold' in BRratio
                if exist('DeleteFlag')==1
                    ChannelDeleteFlag(end+1,1)=m;
                else
                    ChannelDeleteFlag=m;
                end
            end
        end
        SourceChannel(ChannelDeleteFlag,:)=[];
    end
    if isnumeric(SourceChannel)==0
        for m=1:size(SourceChannel,1)
            SourceChannel1(m,1)=strfind1(Fileinfo.ChannelList{1},SourceChannel{m,1},1);
            if SourceChannel1(m,1)==0
                ChannelDeleteFlag(end+1,1)=m;
            end
        end
        SourceChannel1(SourceChannel1==0,:)=[];
        SourceChannel=SourceChannel1;
    end
end
Out=struct;
%% Use oversampled Zaxis to determine the changes
XYZ.IumMinMax=[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}]; % total boundaries of input z-stack,
Zaxis.Ipix=(1:XYZ.Ipix(3)).';
Zaxis.Ium=XYZ.IumMinMax(3,1)+(Zaxis.Ipix*XYZ.Ires(3)-XYZ.Ires(3)/2);

% a negative fitCoef value means that the center of the current file is
% positioned above the reference point, so the vector from the follower
% file towards the refFile
[Zaxis.Drift]=YofBinFnc(Zaxis.Ium,XYZ.FitCoefs(3,1),XYZ.FitCoefs(3,2),XYZ.FitCoefs(3,3),FitCoefRange); % calculate only drift of Zrange
Zaxis.Tum=Zaxis.Ium+Zaxis.Drift; % determine to what Zrange the input file corresponds to

Axis{3}.Tpix=(1:XYZ.Tpix(3)).';
Axis{3}.TumC=(XYZ.TumMinMax(3,1)+XYZ.Tres(3)/2:XYZ.Tres(3):XYZ.TumMinMax(3,2)-XYZ.Tres(3)/2).';

for m=1:XYZ.Tpix(3) % determine the corresponding indices of input Zrange
    Wave1=Axis{3}.TumC(m)+0.00001;
    if Wave1>Zaxis.Tum(1)-XYZ.Ires(3)/2 && Wave1<Zaxis.Tum(end)+XYZ.Ires(3)/2
        [Diff,Ind]=min(abs(Zaxis.Tum-Wave1));
        Axis{3}.Ipix(m,1)=Zaxis.Ipix(Ind,1);
        Axis{3}.Ium(m,1)=Zaxis.Ium(Ind,1);
    else
        Axis{3}.Tpix(m,1)=0;
    end
end

Axis{3,1}(Axis{3}.Tpix==0,:)=[];
Axis{3}.IpixCut(:,1)=Axis{3}.Ipix-min(Axis{3}.Ipix(:))+1;

for m=1:2; % go through x and y
    [Axis{m}.I2tUmLayDrift]=YofBinFnc(Axis{3}.Ium,XYZ.FitCoefs(m,1),XYZ.FitCoefs(m,2),XYZ.FitCoefs(m,3),FitCoefRange);
    Axis{m}.IumLayMinMax(:,1)=XYZ.IumMinMax(m,1)+XYZ.Ires(m)/2;
    Axis{m}.IumLayMinMax(:,2)=XYZ.IumMinMax(m,2)-XYZ.Ires(m)/2;
    Axis{m}.TumLayMinMax(:,1)=Axis{m}.IumLayMinMax(:,1)+Axis{m}.I2tUmLayDrift(:);
    Axis{m}.TumLayMinMax(:,2)=Axis{m}.IumLayMinMax(:,2)+Axis{m}.I2tUmLayDrift(:);
    Axis{m}.TumLayCutoff(:,1:2)=0;
    for n=1:size(Axis{3,1},1)
        if Axis{m}.TumLayMinMax(n,1)<XYZ.TumMinMaxPixCenter(m,1)
            Axis{m}.TumLayCutoff(n,1)=XYZ.TumMinMaxPixCenter(m,1)-Axis{m}.TumLayMinMax(n,1);
            Axis{m}.TumLayMinMax(n,1)=XYZ.TumMinMaxPixCenter(m,1);
            Axis{m}.IumLayMinMax(n,1)=Axis{m}.IumLayMinMax(n,1)+Axis{m}.TumLayCutoff(n,1);
        end
        if Axis{m}.TumLayMinMax(n,2)>XYZ.TumMinMaxPixCenter(m,2)
            Axis{m}.TumLayCutoff(n,2)=Axis{m}.TumLayMinMax(n,2)-(XYZ.TumMinMaxPixCenter(m,2));
            Axis{m}.TumLayMinMax(n,2)=XYZ.TumMinMaxPixCenter(m,2);
            Axis{m}.IumLayMinMax(n,2)=Axis{m}.IumLayMinMax(n,2)-Axis{m}.TumLayCutoff(n,2);
        end
    end
    
    Wave1=(Axis{m}.IumLayMinMax(:,1)-XYZ.IumMinMax(m,1))./XYZ.Ires(m);
    Wave2=Wave1-ceil(Wave1);
    Axis{m}.IpixLayMinMax(:,1)=ceil(Wave1);
    
    Wave1=(Axis{m}.IumLayMinMax(:,2)-XYZ.IumMinMax(m,1))./XYZ.Ires(m);
    Axis{m}.IpixLayMinMax(:,2)=round(Wave1-Wave2);
    Axis{m}.IpixLayMinMax=int16(Axis{m}.IpixLayMinMax);
    
    XYZ.IpixMinMax(m,1)=min(Axis{m}.IpixLayMinMax(:,1));
    XYZ.IpixMinMax(m,2)=max(Axis{m}.IpixLayMinMax(:,2));
    Axis{m}.IpixRange=Axis{m}.IpixLayMinMax(:,2)-Axis{m}.IpixLayMinMax(:,1)+1;
    
    % determine where to cut and paste exactly cutStart is the pixel number of iLayPixMinMax at that layer minus the commen cutoff (iPixMinMax)
    Axis{m}.IpixCut(:,1)=Axis{m}.IpixLayMinMax(:,1)-XYZ.IpixMinMax(m)+1;
    Axis{m}.IpixCut(:,2)=Axis{m}.IpixLayMinMax(:,2)-XYZ.IpixMinMax(m)+1;
    
    % PasteStart is distance from tUmXYMinMax3 to the left border and divided
    % by the input file's resolution
    Axis{m}.TpixPaste(:,1)=ceil((Axis{m}.TumLayMinMax(:,1)+0.00001-XYZ.TumMinMax(m))./XYZ.Ires(m)); % so that 0 is treated as 1
    Axis{m}.TpixPaste=int16(Axis{m}.TpixPaste);
    Axis{m}.TpixPaste(:,2)=Axis{m}.TpixPaste(:,1)+Axis{m}.IpixRange(:)-1;
end

XYZ.IpixMinMax(3,1:2)=[min(Axis{3}.Ipix(:)),max(Axis{3}.Ipix(:))];

%% mirror if required
if exist('Rotate')~=1 || isnumeric(Rotate)
    Rotate='';
end
if ischar(Rotate)
    [Rotate]=variableExtract(Rotate,{'X';'Y';'Z'});
end
Out.Rotate=Rotate;

IpixMinMaxOrig=XYZ.IpixMinMax;
if Rotate.X==-1 % mirror along X
    keyboard;
    XYZ.IpixMinMax(1,1)=XYZ.Ipix(1)-XYZ.IpixMinMax(1,2);
    XYZ.IpixMinMax(1,2)=XYZ.Ipix(1)-IpixMinMaxOrig(1,1);
elseif Rotate.Y==-1 % mirror along Y
    keyboard;
    XYZ.IpixMinMax(2,1)=XYZ.Ipix(2)-XYZ.IpixMinMax(2,2);
    XYZ.IpixMinMax(2,2)=XYZ.Ipix(2)-IpixMinMaxOrig(2,1);
elseif Rotate.Z==-1 % mirror along Z
    keyboard;
    XYZ.IpixMinMax(3,1)=XYZ.Ipix(3)-XYZ.IpixMinMax(3,2);
    XYZ.IpixMinMax(3,2)=XYZ.Ipix(3)-XYZ.IpixMinMax(3,1);
elseif Rotate.Z==180 % rotate along Z
    % mirror along Y
    XYZ.IpixMinMax(2,1)=XYZ.Ipix(2)-XYZ.IpixMinMax(2,2)+1;
    XYZ.IpixMinMax(2,2)=XYZ.Ipix(2)-IpixMinMaxOrig(2,1)+1;
    % mirror along X
    XYZ.IpixMinMax(1,1)=XYZ.Ipix(1)-XYZ.IpixMinMax(1,2)+1;
    XYZ.IpixMinMax(1,2)=XYZ.Ipix(1)-IpixMinMaxOrig(1,1)+1;
end

if exist('OnlyMultiDimInfo')==1 % afterwards no more changes of XYZ
    Out.P=Axis;
    Out.U=XYZ;
    DataOut=[];
    Mask=[];
    return;
end
%% load the required input volume

if exist('DataIn')==1
    
elseif exist('DepthCorrectionInfo')~=1 || isempty(DepthCorrectionInfo)
    [DataIn]=im2Matlab_3(FilenameTotal,SourceChannel,SourceTimepoint,[],XYZ.IpixMinMax);
else
    for m=1:size(SourceChannel,1)
        if isstruct(DepthCorrectionInfo)
            J=DepthCorrectionInfo;
        else
            J=DepthCorrectionInfo{m};
        end
        J.FilenameTotal=FilenameTotal;
        J.TargetChannel=SourceChannel(m);
        [DataIn(:,:,:,1,m),~]=depthCorrection_6(J);
    end
    if isequal(XYZ.IpixMinMax,[[1;1;1],XYZ.Ipix])==0
        DataIn=DataIn(XYZ.IpixMinMax(1,1):XYZ.IpixMinMax(1,2),XYZ.IpixMinMax(2,1):XYZ.IpixMinMax(2,2),XYZ.IpixMinMax(3,1):XYZ.IpixMinMax(3,2),1,:);
    end
end

DataIn=permute(DataIn,[1,2,3,5,4]);


if exist('ChannelDeleteFlag')==1 && isempty(ChannelDeleteFlag)==0 % add empty stack for InterCalc==2
    DataIn(:,:,:,end+1)=0;
    Wave1=zeros(size(OrigSourceChannel,1),1);
    Wave1(ChannelDeleteFlag,1)=size(DataIn,4);
    Wave1(Wave1==0)=(1:size(SourceChannel,1)).';
    DataIn=DataIn(:,:,:,Wave1);
end

% import surfaces
if exist('SourceSurfaces')==1
    keyboard; % check if im2Matlab_3 correctly integrates the data
    for m=SourceSurfaces.'
        [SurfacesData]=im2Matlab_3(FilenameTotal,OrigSourceChannel{m,1},SourceTimepoint,'Surface',XYZ.IpixMinMax(3,1));
        DataIn(:,:,:,m)=SurfacesData(:,:,:);
    end
end

if Rotate.X==-1 % mirror along X
    keyboard; % Rotate adjusted for mirroring in Y
    DataIn=flip(DataIn,1);
elseif Rotate.Y==-1 % mirror along Y
    DataIn=flip(DataIn,2);
elseif Rotate.Z==-1 % mirror along Z
    keyboard; % Rotate adjusted for mirroring in Y
    DataIn=flip(DataIn,3);
elseif Rotate.Z==180 % rotate along Z
    DataIn=flip(DataIn,1);
    DataIn=flip(DataIn,2);
end

if exist('InterCalc')
    for m=1:size(InterCalc,1)
        if InterCalc{m,1}==1 % add 1 to the initial dataset before putting it in the driftcorrected environment
            InterCalc{m,3}=DataIn(:,:,:,m)+1;
        elseif InterCalc{m,1}==2 % threshold MetBlue by value 'Threshold' in BRratio
            VariableNames=varName2Col(OrigSourceChannel);
            Wave1=DataIn(:,:,:,VariableNames.MetBlue);
            Wave2=DataIn(:,:,:,VariableNames.BRratio);
            Wave1(Wave2<=InterCalc{m,2}.Threshold)=0;
            InterCalc{m,3}=Wave1;
            keyboard; % check if correctly works some changes on 2017.11.03
            DataIn(:,:,:,m)=InterCalc{m,3};
            clear Wave1; clear Wave2;
        elseif InterCalc{m,1}==2 % threshold Ch1 by value 'Threshold' in Ch2
            % subtract below 70th percentile slicewise
        elseif InterCalc{m,1}==3 % set everything below certain percentile slicewise to zero
            keyboard;
            Pix=size(Data3D);
            A5=prctile(reshape(Data3D,Pix(1)*Pix(2),Pix(3),1),Percentile,1).'; % sorts dataset such that each slice into one column, calculates percentile
        elseif InterCalc{m,1}==4 % set percentile to targetvalue
            Wave1=DataIn(:,:,:,m);
            Wave1=prctile(Wave1(:),InterCalc{m,2});
            DataIn(:,:,:,m)=DataIn(:,:,:,m)*(InterCalc{m,2}/double(Wave1));
        end
    end
%     for m=1:size(InterCalc,1)
%         if size(InterCalc,2)>2 && isempty(InterCalc{m,3})==0
%             DataIn(:,:,:,m)=InterCalc{m,3};
%         end
%     end
end

DataOut=zeros(XYZ.Tpix(1),XYZ.Tpix(2),XYZ.Tpix(3),size(DataIn,4),class(DataIn));
Mask=false(XYZ.Tpix(1),XYZ.Tpix(2),XYZ.Tpix(3));
%% apply IntrFitCoefs

for n=1:size(Axis{3,1},1)
    Tslice=nan(XYZ.TpixAtiRes(1),XYZ.TpixAtiRes(2),1,size(DataIn,4),'double');
    
    Xt1=Axis{1}.TpixPaste(n,1);
    Xt2=Axis{1}.TpixPaste(n,2);
    Yt1=Axis{2}.TpixPaste(n,1);
    Yt2=Axis{2}.TpixPaste(n,2);
    Zt1=Axis{3}.Tpix(n,1);
    
    Xs1=Axis{1}.IpixCut(n,1);
    Xs2=Axis{1}.IpixCut(n,2);
    Ys1=Axis{2}.IpixCut(n,1);
    Ys2=Axis{2}.IpixCut(n,2);
    Zs1=Axis{3}.IpixCut(n,1);
    if Zs1>size(DataIn,3); break; end;
    Tslice(Xt1:Xt2,Yt1:Yt2,1,:)=DataIn(Xs1:Xs2,Ys1:Ys2,Zs1,:);
    
    if size(Tslice,1)~=XYZ.Tpix(1) || size(Tslice,2)~=XYZ.Tpix(2)
%         if XYZ.TpixAtiRes(1)~=XYZ.Tpix(1) || XYZ.TpixAtiRes(2)~=XYZ.Tpix(2)
        if strcmp(Interpolation,'Nearest')
            Xi=round(linspace(1,XYZ.TpixAtiRes(1),XYZ.Tpix(1))).';
            Yi=round(linspace(1,XYZ.TpixAtiRes(2),XYZ.Tpix(2))).';
%             Tslice2=Tslice(Xi,Yi,1,:);
            Tslice=Tslice(Xi,Yi,1,:);
        elseif strcmp(Interpolation,'Bilinear')
%             Tslice2=imresize(Tslice,[XYZ.Tpix(1),XYZ.Tpix(2)],'bilinear');
            Tslice=imresize(Tslice,[XYZ.Tpix(1),XYZ.Tpix(2)],'bilinear');
        end
        
    else
%         Tslice2=Tslice;
    end
    
    DataOut(:,:,Zt1,:)=Tslice(:,:,1,:); % any nan-voxel is set to zero in dataOut
end
Out.U=XYZ;

% finish
W.DoReport='success';
Mask=[];
evalin('caller','global W;');
