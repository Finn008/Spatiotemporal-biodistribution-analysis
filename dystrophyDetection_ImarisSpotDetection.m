function [ChannelList]=dystrophyDetection_ImarisSpotDetection(FilenameTotal)


ChannelList={  'Name','Diameter','LowerManual','LowerAuto','GrowingType';...
    'EF1A',[0.7,0.7,1.4],30,0,0;...
    'PSD95',[0.5,0.5,1.4],30,0,0;...
    };
ChannelList=array2table(ChannelList(2:end,:),'VariableNames',ChannelList(1,:),'RowNames',ChannelList(2:end,1));

[Fileinfo]=getFileinfo_2(FilenameTotal);
ChannelList(ismember(ChannelList.Name,Fileinfo.ChannelList{1})==0,:)=[];
% ChannelNames=Fileinfo.ChannelList{1};
Application=openImaris_2(FilenameTotal);

for Ch=1:size(ChannelList,1)
    ChannelName=ChannelList.Name{Ch};
    J=struct;
    J.Application=Application;
    J.ObjectType='Spot';
    J.Channel=ChannelName;
    J.SurfaceName=[ChannelName,'_Spots'];
    J.RGBA=[0.5,1,0,0];
    %     J.SurfaceFilter=['"Quality" above automatic threshold'];
    J.DiaXYZ=ChannelList{ChannelName,'Diameter'}{1};
    J.Background=1;
    J.RegionsFromLocalContrast=1;
    J.LowerManual=ChannelList{ChannelName,'LowerManual'}{1};
    J.LowerAuto=ChannelList{ChannelName,'LowerAuto'}{1};
    J.GrowingType=ChannelList{ChannelName,'GrowingType'}{1};
    generateSurface3(J);
    [ChannelList.Statistics(Ch,1)]={getObjectInfo_2([ChannelName,'_Spots'],[],Application)};
end

imarisSaveHDFlock(Application,FilenameTotal);