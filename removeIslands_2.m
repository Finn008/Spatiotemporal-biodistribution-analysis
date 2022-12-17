% [Dystrophies]=removeIslands_2(Dystrophies,4,1,prod(Res(:)));
function [Data3D]=removeIslands_2(Data3D,Connectivity,MinVolume,Res3D)
Pix=size(Data3D).';
BW=bwconncomp(1-Data3D,Connectivity);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';

% Table=sortrows(Table,'Volume','descend');
if exist('MinVolume')==1
    Table.Volume=Table.NumPix*Res3D;
    Ind=find(Table.Volume>MinVolume);
%     Ind=[1;3;5];
%     Wave1=BW;
    BW.PixelIdxList=Table.IdxList(Ind).';
    BW.NumObjects=size(Ind,1);
else
    Ind=1:size(Table,1);
end
Wave1=struct2table(regionprops(BW,'BoundingBox'));
Table.BoundingBox(Ind,1:6)=Wave1.BoundingBox;
% Table=[Table,struct2table(regionprops(BW,'BoundingBox'))];
clear BW;

% island if connected to border
Table.BoundingBox(:,1:3)=Table.BoundingBox(:,1:3)+0.5;
Table.BoundingBox(:,4:6)=Table.BoundingBox(:,1:3)+Table.BoundingBox(:,4:6)-1;

Wave1=[1,1,1,Pix.'];
Table.BoundingBox=Table.BoundingBox-repmat(Wave1,[size(Table,1),1]);
if Connectivity==4
    Table.BorderTouch=min(abs(Table.BoundingBox(:,[1,2,4,5])),[],2)==0;
else
    Table.BorderTouch=min(abs(Table.BoundingBox),[],2)==0;
end
Table=Table(Table.BorderTouch==0,:);

for m=1:size(Table,1)
    Data3D(Table.IdxList{m})=1;
end
