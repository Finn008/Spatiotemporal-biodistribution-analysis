function Outside=dystrophyDetection_Outside_Vglut1(Data3D,ResCalc)
PixCalc=size(Data3D).';
% global Application; global PixOrig;
Outside=Data3D<4000;

% Outside=imdilate(Outside,imdilateWindow([0.6;0.6],ResCalc)); % Outside 1

% Window2=imdilateWindow([1;1],ResCalc);
% Outside=imerode(Outside,Window2); % Outside 2

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

% 3D
BW=bwconncomp(Outside,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res3D=prod(ResCalc);
Table.Volume=Table.NumPix*Res3D;
Table=Table(Table.Volume>2500,:); % before 2016.12.22 Threshold 5000
% only regions touching top or bottom
for m=1:size(Table,1)
    Table.MinMaxIdx(m,1:2)=[min(Table.IdxList{m}),max(Table.IdxList{m})];
end
try; Table=Table(Table.MinMaxIdx(:,1)<(PixCalc(1)*PixCalc(2))|Table.MinMaxIdx(:,2)>(prod(PixCalc)-PixCalc(1)*PixCalc(2)),:); end; % try to catch cases in which no Outside present

Outside=zeros(size(Outside),'uint16');
Outside(cell2mat(Table.IdxList))=1;

% correct for erosion
Outside=imdilate(Outside,imdilateWindow([1;1],ResCalc));
% Wave1=Data3D<ChannelInfo.Threshold(Ch,1);
% Outside(Wave1==0)=0;

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