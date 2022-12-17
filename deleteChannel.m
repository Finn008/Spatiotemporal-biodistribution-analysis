% drive with accessImarisManually(Application,struct('Function','DeleteChannel','ChannelList',ChannelsRemove));
function [Report]=deleteChannel(ChannelNames,Fileinfo)
for m=1:2
    inputemu('key_normal','\ALT'); pause(1);
    inputemu('key_normal','e'); pause(1);
    for m2=1:9
        inputemu('key_normal','\DOWN'); pause(0.2);
    end
    inputemu('key_normal','\ENTER'); pause(0.3);
    inputemu('key_ctrl','c'); pause(1);
    Report=safeClipboard('paste'); pause(0.5);
    if strcmp(Report(1:8),'Channel ')
        break;
    else
    end
end

if strcmp(Report(1:8),'Channel ')
    Report=1;
else
    Report=0;
    return;
end

ChannelNumber=size(Fileinfo.ChannelList{1},1);
if isnumeric(ChannelNames)
    ChannelNames=Fileinfo.ChannelList{1}(ChannelNames);
end
ChannelNames=findIntersection({Fileinfo.ChannelList{1};ChannelNames});
ChannelIds=strfind1(Fileinfo.ChannelList{1},ChannelNames,1);


for m=ChannelNumber:-1:1
    CurrentChannel=find(ChannelIds==m);
    if isempty(CurrentChannel)
        
    else
        inputemu('key_ctrl','c'); pause(1);
        ClipBoard=safeClipboard('paste'); pause(0.5);
        Path=['Channel ',num2str(ChannelIds(CurrentChannel)),' - ',ChannelNames{CurrentChannel}];
        if strcmp(ClipBoard,Path)
            inputemu('key_normal',' '); pause(0.5); % uncheck or check all Cells statistics
        else
            Report=0;
            return;
        end
    end
    if min(ChannelIds)==ChannelIds(CurrentChannel)
        break;
    end
    inputemu('key_normal','\UP'); pause(0.3);
end
inputemu('key_normal','\ENTER'); pause(0.3);
