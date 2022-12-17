function [Outside]=dystrophyDetection_Outside(Outside,Res)

% first make 3D
BW=bwconncomp(Outside,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res3D=prod(Res);
Table.Volume=Table.NumPix*Res3D;
Table=Table(Table.Volume>5000,:);
Outside=zeros(size(Outside),'uint16');
for m=1:size(Table,1)
    %     for m=find(Table.Volume>=5000).'
    Outside(Table.IdxList{m})=1;
end

% get Area dimensions in 2D
BW=bwconncomp(Outside,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(Res(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area>1000,:);
Outside=zeros(size(Outside),'uint16');
for m=1:size(Table,1)
% % %     Outside(Table.IdxList{m})=Table.Area(m);
    Outside(Table.IdxList{m})=1;
end

% Outside=imdilate(Outside,ones(Window,Window));
% Outside=imdilate(Outside,ones(3,3));