function imarisRenameChannel(Application,Old,New)

Fileinfo=getImarisFileinfo(Application);
Ind=strfind1(Fileinfo.ChannelList{1},Old);
Application.GetDataSet.SetChannelName(Ind-1,New);