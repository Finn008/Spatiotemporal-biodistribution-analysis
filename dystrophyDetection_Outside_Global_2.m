function Outside=dystrophyDetection_Outside_Global_2(ChannelInfo,Settings,ChannelName,ResCalc,PixOrig)

global ShowIntermediateSteps;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    global ChannelTable;
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
%     Application=FilenameTotal;
% else
%     ShowIntermediateSteps=0;
end

Data3D=ChannelInfo.Data3D{strfind1(ChannelInfo.Name,ChannelName,1),1};
PixCalc=size(Data3D).';

if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Data3D,[],[],PixOrig),Application,'Outside_RawData'); end

Outside=Data3D<Settings{ChannelName,'IntThreshold'}{1};
% Wave1=strfind1(ChannelInfo.Name,'MetBlue',1);
% if Wave1~=0
if strfind1(ChannelInfo.Name,'MetBlue',1) % include plaques if present
    Wave1=ChannelInfo.Data3D{strfind1(ChannelInfo.Name,'MetBlue',1),1};
    Outside(Wave1>=prctile(Wave1(:),96))=0;
end

if strfind1({'NAB228';'DAPI';'Iba1'},ChannelName) % sparse
    Inside=Outside==0;
    % get Area dimensions in 2D
    BW=bwconncomp(Inside,4);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res2D=prod(ResCalc(1:2));
    Table.Area=Table.NumPix*Res2D;
    Table=Table(Table.Area>(0.2*0.2*4),:); % 700: 26x26µm, previously 1000
    Inside=zeros(size(Inside),'uint16');
    Inside(cell2mat(Table.IdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Inside,[],[],PixOrig),Application,'Outside_After2D'); end;
    Dilation=Settings{ChannelName,'Dilation'}{1};
    Inside=imdilate(Inside,imdilateWindow([Dilation;Dilation],ResCalc));
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Inside,[],[],PixOrig),Application,'Outside_AfterDilation'); end;
    
    % remove holes in 2D
    BW=bwconncomp(1-Inside,4);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res2D=prod(ResCalc(1:2));
    Table.Area=Table.NumPix*Res2D;
    Table=Table(Table.Area<35^2,:);
    Inside(cell2mat(Table.IdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Inside,[],[],PixOrig),Application,'Outside_AfterHoleRemoval'); end;
    
    % remove holes in 3D
    BW=bwconncomp(1-Inside,6);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res2D=prod(ResCalc(1:2));
    Table.Volume=Table.NumPix*Res2D;
    Table=Table(Table.Volume<25^3,:);
    Inside(cell2mat(Table.IdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Inside,[],[],PixOrig),Application,'Outside_AfterHoleRemoval3D'); end;
    
    Inside=imerode(Inside,imdilateWindow([Dilation;Dilation],ResCalc));
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Inside,[],[],PixOrig),Application,'Outside_AfterErosion'); end;
    Outside=Inside==0;
else % nonsparse
    
    % get Area dimensions in 2D
    BW=bwconncomp(Outside,4);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res2D=prod(ResCalc(1:2));
    Table.Area=Table.NumPix*Res2D;
    Table=Table(Table.Area>700,:); % 700: 26x26µm, previously 1000
    Outside=zeros(size(Outside),'uint16');
    Outside(cell2mat(Table.IdxList))=1;
    % if ShowIntermediateSteps==1; dataInspector3D(interpolate3D(uint16(single(Outside)./single(Threshold)*100),Res,Res2),Res2,'MetBlueBackgroundRatio',1,FilenameTotalCrude,0);end;
    
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Outside,[],[],PixOrig),Application,'Outside_After2D'); end;
    
    % 3D
    BW=bwconncomp(Outside,6);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res3D=prod(ResCalc);
    Table.Volume=Table.NumPix*Res3D;
    Table=Table(Table.Volume>2500,:);
    % only regions touching top or bottom
    for m=1:size(Table,1)
        Table.MinMaxIdx(m,1:2)=[min(Table.IdxList{m}),max(Table.IdxList{m})];
    end
    try; Table=Table(Table.MinMaxIdx(:,1)<(PixCalc(1)*PixCalc(2))|Table.MinMaxIdx(:,2)>(prod(PixCalc)-PixCalc(1)*PixCalc(2)),:); end; % try to catch cases in which no Outside present
    
    Outside=zeros(size(Outside),'uint16');
    Outside(cell2mat(Table.IdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Outside,[],[],PixOrig),Application,'Outside_After3D'); end;
    
    % dilate
    Outside=imdilate(Outside,imdilateWindow([1;1],ResCalc));
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Outside,[],[],PixOrig),Application,'Outside_AfterDilation'); end;
    
    % remove holes
    BW=bwconncomp(1-Outside,4);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Res2D=prod(ResCalc(1:2));
    Table.Area=Table.NumPix*Res2D;
    Table=Table(Table.Area<64,:); % previously 5, 1000
    Outside(cell2mat(Table.IdxList))=1;
    if ShowIntermediateSteps==1; ex2Imaris_2(interpolate3D(Outside,[],[],PixOrig),Application,'Outside_AfterHoleRemoval'); end;
end

if ShowIntermediateSteps==1
% %     imarisSaveHDFlock(Application);
% %     Application=openImaris_4(Application,1,1);
% %     keyboard;
end