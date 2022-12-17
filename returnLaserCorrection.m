function [Out]=returnLaserCorrection(FilenameTotal,Channel)


[Fileinfo,FileinfoInd,PathRaw]=getFileinfo_2(FilenameTotal);
Results=Fileinfo.Results{1,1};
FieldNames=fieldnames(Results);
if strfind1(FieldNames,'Zeninfo')
    keyboard; % not since 2016.01.07, rename with ZenInfo
end

try
    LaserChange=Fileinfo.Results{1}.ZenInfo.ChannelInfo.Transmission(Channel,:);
catch % outdated
    LaserChange=Fileinfo.Results{1}.ZenInfo.Lasers.Transmission;
end
Pix=Fileinfo.Pix{1};
LaserRatio=min(LaserChange)/max(LaserChange);
if isnan(LaserRatio)
    LaserRatio=1;
end
LaserProfile=linspace(1,LaserRatio,Pix(3))*100;
Out=struct;
Out.LaserChange=LaserChange;
Out.LaserRatio=LaserRatio;
Out.LaserProfile=LaserProfile;