function [Fileinfo]=getHD5Fileinfo(FilenameTotal)


[Path2file,Report]=getPathRaw(FilenameTotal);

Fileinfo=table;
DataSetInfo=h5info(Path2file,'/DataSetInfo');
Wave1={DataSetInfo.Groups.Name}.';
for m=1:size(Wave1,1)
    Wave1{m,1}=Wave1{m,1}(14:end);
end
% get Channelnames
DataSetInfo=struct2table(DataSetInfo.Groups,'RowNames',Wave1,'AsArray',1);

Wave1=DataSetInfo(strfind1(DataSetInfo.Name,'Channel '),:);
for m=1:size(Wave1,1)
    ChInd=Wave1.Name{m,1}(22:end);
    ChInd=str2num(ChInd)+1;
    Wave2=struct2table(Wave1.Attributes{m},'AsArray',1);
    Wave2.Properties.RowNames=Wave2.Name;
    Wave2=strjoin(Wave2.Value{'Name'}.','');
    ChannelList(ChInd,1)={Wave2};
end

Fileinfo.GetSizeC=size(ChannelList,1);
% get time info
DataSet=h5info(Path2file,'/DataSet');
Fileinfo.GetSizeT=size({DataSet.Groups(1).Groups.Name},2);
% Wave1=struct2table(DataSetInfo.Attributes{'TimeInfo'},'AsArray',1);
% Wave1.Properties.RowNames=Wave1.Name;
% Fileinfo.GetSizeT=str2num(strjoin(Wave1.Value{'DatasetTimePoints'}.',''));

% get pix dimension
Wave1=DataSetInfo.Attributes{'Image'};
Wave1=struct2table(Wave1,'RowNames',{Wave1.Name}.','AsArray',1);

GetSizeX=str2num(strjoin(Wave1.Value{'X'}.',''));
GetSizeY=str2num(strjoin(Wave1.Value{'Y'}.',''));
GetSizeZ=str2num(strjoin(Wave1.Value{'Z'}.',''));
GetExtendMinX=str2num(strjoin(Wave1.Value{'ExtMin0'}.',''));
GetExtendMinY=str2num(strjoin(Wave1.Value{'ExtMin1'}.',''));
GetExtendMinZ=str2num(strjoin(Wave1.Value{'ExtMin2'}.',''));
GetExtendMaxX=str2num(strjoin(Wave1.Value{'ExtMax0'}.',''));
GetExtendMaxY=str2num(strjoin(Wave1.Value{'ExtMax1'}.',''));
GetExtendMaxZ=str2num(strjoin(Wave1.Value{'ExtMax2'}.',''));

Fileinfo.Pix={[GetSizeX;GetSizeY;GetSizeZ]};
Fileinfo.UmStart={[GetExtendMinX;GetExtendMinY;GetExtendMinZ]};
Fileinfo.UmEnd={[GetExtendMaxX;GetExtendMaxY;GetExtendMaxZ]};
Fileinfo.Um={Fileinfo.UmEnd{1}-Fileinfo.UmStart{1}};
Fileinfo.Res={Fileinfo.Um{1}./Fileinfo.Pix{1}};

Fileinfo.ChannelList(1)={ChannelList};

SceneInfo=h5info(Path2file,'/Scene/Content');
if isempty(SceneInfo.Groups)==0
    SceneInfo=struct2table(SceneInfo.Groups,'AsArray',1);
    % get ObjectList
    for m=1:size(SceneInfo,1)
        Wave1=struct2table(SceneInfo.Attributes{m,1},'AsArray',1);
        Wave1.Properties.RowNames=Wave1.Name;
%         Wave1=struct2table(SceneInfo.Attributes{m,1},'RowNames',{SceneInfo.Attributes{m,1}.Name}.');
        
        if strfind1(SceneInfo.Name{m,1},'Surfaces')
            ObjectList(m,3)={'Surfaces'};
            ObjectList(m,1)=Wave1.Value('Name');
        elseif strfind1(SceneInfo.Name{m,1},'Points')
            ObjectList(m,3)={'Spots'};
            ObjectList(m,1)=Wave1.Value('Name');
        elseif strfind1(SceneInfo.Name{m,1},'Filaments')
            ObjectList(m,3)={'Filament'};
            ObjectList(m,1)={'unknown'};
        end
    end
    Fileinfo.ObjectList(1)={ObjectList};
end

% keyboard;
% Additional=table;
Wave1=h5read(Path2file,'/DataSet/ResolutionLevel 0/TimePoint 0/Channel 0/Data',[1,1,1],[1,1,1]);
Fileinfo.GetType(1)={class(Wave1)};
% keyboard;
% Wave1=h5info(Path2file,'/DataSet/ResolutionLevel 0/TimePoint 0/Channel 0/Data');
% 
% Additional.HD5Size=1;
