function [ChannelName]=getBFinfo_ChannelName(OriginalMetaData,Type,Ch)


if strcmp(Type,'.lsm')
    SearchStrings={'ChannelName #'};
elseif strcmp(Type,'.czi')
    SearchStrings={'ImageChannelName #'};
%     [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
%     SearchStrings=SearchStrings(max(Wave1(:)),1);
end

Path=[SearchStrings{1},num2str(Ch)];
Ind=strfind1(OriginalMetaData.Tag,Path);

ChannelName=OriginalMetaData.Value{Ind};
