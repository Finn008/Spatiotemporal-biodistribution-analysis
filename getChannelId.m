function [ID,ChannelList]=getChannelId(Application,ChannelNames)



ChannelNumber=Application.GetDataSet.GetSizeC;
for m = 1:ChannelNumber
    ChannelList{m,1}=char(Application.GetDataSet.GetChannelName(m-1));
    if strcmp(ChannelList{m,1},'(name not specified)')
        ChannelList{m,1}='empty';
    end
end
if exist('ChannelNames')==1 && isempty(ChannelNames)==0
    if ischar(ChannelNames)
        ChannelNames={ChannelNames};
    end
    for m = 1:size(ChannelNames,1)
        ID(m,1)=strfind1(ChannelList,ChannelNames{m},1);
%         Wave1=strcmp(ChannelList,ChannelNames{m}); Wave1=find(Wave1==1);
%         ID(m,1)=Wave1;
    end
else
    ID=[];
end