function [Data3D]=removeIslands(Data3D,Connectivity)
Pix=size(Data3D).';
BW=bwconncomp(1-Data3D,Connectivity);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table=[Table,struct2table(regionprops(BW,'BoundingBox'))];
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
