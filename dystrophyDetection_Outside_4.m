function [Outside]=dystrophyDetection_Outside_4(FilenameTotal,ZenInfo,DataBrainArea)
DataBrainArea=[];
global W;

[Fileinfo]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

Data2Check={'MetBlue';'Vglut1';'Bace1';'Lamp1'};

ChannelInfo=ZenInfo.ChannelInfo;
ChannelInfo.Name=Fileinfo.ChannelList{1};
ChannelInfo=ChannelInfo(ismember(ChannelInfo.Name,Data2Check),:);





for Ch=1:size(ChannelList,1)
    ChannelName=ChannelInfo.Name{Ch};
    Data3D=im2Matlab_3(FilenameTotal,ChannelName);
    
    ResCalc=[0.2;0.2;0.4];
    Wave1=Res<ResCalc;
    if max(Wave1(:))==1
        ResOrig=Res;
        ResCalc(Wave1==0)=Res(Wave1==0);
        PixOrig=Pix;
        [Data3D,Out]=interpolate3D(Data3D,Res,ResCalc);
        Res=Out.Res;
        Pix=Out.Pix;
    end
    
    if strcmp(ChannelName,'MetBlue')
%         ImportChannel='MetBlue';
        Percentile=50;
        TargetValue=1000;
        Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1},'SteepFallingRaw');
        [OrigData,Output]=depthIntensityFitting_3(Data,Res,Percentile,TargetValue,Masking,Outside,Filename,EndVersion)
        Threshold=500;
    end
    
    
    if exist('ResOrig')~=0
        Outside=interpolate3D(Outside,[],[],PixOrig);
    end
end


if strfind1(ChannelInfo.Name,'Vglut1',1)
    Ind=strfind1(ChannelInfo.Name,'Vglut1',1);
    ImportChannel='Vglut1';
    Percentile=50;
    TargetValue=8000;
    Threshold=4000;
end
Application=openImaris_2(FilenameTotal,1,0);


if strfind1(ChannelList,'Lamp1',1)
    %     keyboard;
    ImportChannel='Lamp1';
    Percentile=50;
    TargetValue=1000;
    Threshold=1000;
    Data3D=depthIntensityFitting_2(Data3D,Res,Percentile,TargetValue,[],DataBrainArea==0,Fileinfo.Filename{1});
end