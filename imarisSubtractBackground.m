function imarisSubtractBackground(Application,Channel,Sigma)

[Fileinfo]=getImarisFileinfo(Application);
Channel=strfind1(Fileinfo.ChannelList{1},Channel,1);
% vDataSetIn=Application.GetDataSet; %% Current dataset
% vChannelIndex=0;
Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,Channel-1,Sigma);