function [Output]=dystrophyDetection_DepthIntensityProfile(FilenameTotal,ZenInfo,DataBrainArea)
keyboard; % discontinued 2018.01.04
[Fileinfo]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};

Data2Check={'MetBlue';'Vglut1';'Bace1';'Lamp1'};

ChannelInfo=ZenInfo.ChannelInfo;
ChannelInfo.Name=Fileinfo.ChannelList{1};
ChannelInfo=ChannelInfo(ismember(ChannelInfo.Name,Data2Check),:);

ResOrig=Res; PixOrig=Pix;
ResCalc=[0.2;0.2;0.4];
Wave1=Res<ResCalc;
if max(Wave1(:))==1
    ResCalc(Wave1==0)=Res(Wave1==0);
end

for Ch=1:size(ChannelInfo,1)
    ChannelName=ChannelInfo.Name{Ch};
    Data3D=im2Matlab_3(FilenameTotal,ChannelName);
    if isequal(ResOrig,ResCalc)~=1
        [Data3D,Out]=interpolate3D(Data3D,ResOrig,ResCalc);
%         Res=Out.Res;
    end
    EndVersion='Standard';
    if strcmp(ChannelName,'MetBlue')
        Percentile=50;
        TargetValue=1000;
        Threshold=500;
        EndVersion='SteepFallingRaw';
    end
    if strcmp(ChannelName,'Vglut1')
        Ind=strfind1(ChannelInfo.Name,'Vglut1',1);
        Percentile=50;
        TargetValue=8000;
        Threshold=4000;
    end
    if strcmp(ChannelName,'Lamp1')
        Percentile=50;
        TargetValue=1000;
        Threshold=1000;
    end
    Path2file=['\\GNP90N\share\Finn\Analysis\Output\DepthIntensityFitting\',ChannelName,'\',Fileinfo.Filename{1},'_',ChannelName,'.png'];
    [Data3D,Output]=depthIntensityFitting_6(Data3D,ResCalc,Percentile,TargetValue,[],DataBrainArea==0,Path2file,EndVersion);
%     depthIntensityFitting_3(Data,Res,Percentile,TargetValue,Masking,Outside,Filename,EndVersion);
    ChannelInfo.StartEndUm(Ch,1:2)=Output.StartEndUm;
    ChannelInfo.SliceThickness(Ch,1:2)=Output.SliceThickness;
    ChannelInfo.HalfDistance(Ch,1:size(Output.HalfDistance,1))=Output.HalfDistance;
    ChannelInfo.FitStDev(Ch,1:2)=Output.StDev;
    ChannelInfo.Data3D(Ch,1)={Data3D};
    ChannelInfo.Threshold(Ch,1)=Threshold;
    ChannelInfo.Percentile(Ch,1)=Percentile;
    ChannelInfo.PercentileProfile(Ch,1)={Output.PercentileProfile};
end


if strfind1(ChannelInfo.Name,'Vglut1',1)
    Ch=strfind1(ChannelInfo.Name,'Vglut1',1);
    
else
    keyboard;
end
