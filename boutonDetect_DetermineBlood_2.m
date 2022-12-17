function [Blood]=boutonDetect_DetermineBlood_2(VglutRed,Outside,OrigRes)


OrigPix=size(VglutRed).';
Um=OrigPix.*OrigRes;

Res=[0.4;0.4;0.4];


VglutRed=interpolate3D(VglutRed,OrigRes,Res);
Pix=size(VglutRed).';
Outside=interpolate3D(Outside,[],[],Pix);

% subtract the background
VglutRedBackground=sparseFilter(VglutRed,Outside>0,Res,10000,[25;25;Um(3)],[2;2;Um(3)],70);
MinMax=[min(VglutRedBackground(:));max(VglutRedBackground(:))];
VglutRedBackground=uint16(single(VglutRed)-single(VglutRedBackground)+single(MinMax(2)));
clear VglutRed;
for m=1:10
    VglutRedBackground=smooth3(VglutRedBackground,'box',[3,3,3],'symmetric');
end
VglutRedBackground=uint16(VglutRedBackground);


[Out1]=getHistograms_3([],VglutRedBackground,Outside==0);
Threshold1=Out1.Percentiles.a(20);

J=struct('DataOutput','AllPercentiles','Zres',Res(3));
[VglutRedPerc,HistogramInfo]=percentiler(VglutRedBackground,[],J);

Blood=(VglutRedBackground<Threshold1).*(VglutRedPerc<4).*logical(1-Outside);
clear VglutRedBackground; clear VglutRedPerc; clear Outside;

BW=bwconncomp(Blood,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(:));
Table=Table(Table.Volume>90,:);
Blood=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    Blood(Table.IdxList{m})=1;
end
Window=ones(round(2/Res(1)),round(2/Res(2)),1);
BloodCore=imerode(Blood,Window);

BW=bwconncomp(BloodCore,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(:));
Table=Table(Table.Volume>10,:);

BloodCore=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    BloodCore(Table.IdxList{m})=1;
end



BW=bwconncomp(Blood,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Area=Table.NumPix*prod(Res(1:2));

Table=Table(Table.Area>6,:);

for m=1:size(Table,1)
    Table.Core(m,1)=sum(BloodCore(Table.IdxList{m}));
end
clear BloodCore;

Table=Table(Table.Core>0,:);

Blood=false(Pix(1),Pix(2),Pix(3));
for m=1:size(Table,1)
    Blood(Table.IdxList{m})=1;
end

BW=bwconncomp(Blood,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(:));
Table=Table(Table.Volume>90,:);
Blood=false(Pix(1),Pix(2),Pix(3));
for m=1:size(Table,1)
    Blood(Table.IdxList{m})=1;
end

Blood=interpolate3D(Blood,[],[],OrigPix);
% keyboard; % chech sizes