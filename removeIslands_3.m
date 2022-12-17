function [Data3D,Islands]=removeIslands_3(Data3D,Connectivity,MinMaxVolume,Res3D)
Pix=size(Data3D).';
BW=bwconncomp(1-Data3D,Connectivity);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*Res3D;
Wave1=struct2table(regionprops(BW,'BoundingBox'));
Table.BoundingBox(:,1:6)=Wave1.BoundingBox;
clear BW;
if exist('MinMaxVolume')==1
    Table=Table(Table.Volume>=MinMaxVolume(1) & Table.Volume<MinMaxVolume(2),:);
end

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
Islands=zeros(size(Data3D),'uint8');
Islands(cell2mat(Table.IdxList))=1;
Data3D(Islands==1)=1;
