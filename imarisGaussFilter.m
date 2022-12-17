function imarisGaussFilter(Application,Channel,Sigma)

[Fileinfo]=getImarisFileinfo(Application);
Channel=strfind1(Fileinfo.ChannelList{1},Channel,1);
Application.GetImageProcessing.GaussFilterChannel(Application.GetDataSet,Channel-1,Sigma);
