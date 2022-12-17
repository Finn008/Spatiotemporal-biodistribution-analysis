function dystrophyDetection_IntensityCorrection(ChannelNames)
global ChannelTable;

[Outside]=im2Matlab_3(ChannelTable.TargetFilename{'Outside'},'Outside');
[Fileinfo,Ind,PathRaw]=getFileinfo_2(ChannelTable.SourceFilename{ChannelNames{1}});
Res=Fileinfo.Res{1};

for Ch=1:size(ChannelNames,1)
    [Data3D]=im2Matlab_3(ChannelTable.SourceFilename{ChannelNames{Ch}},ChannelTable.SourceChannelName{ChannelNames{Ch}});
    
    [~,Data3D]=percentileFilter3D_3(Data3D,70,Res,[2;2;Res(3)],Outside,400,[200;200;1],1);
    ex2Imaris_2(Data3D,ChannelTable.TargetFilename{ChannelNames{Ch}},ChannelNames{Ch});
end