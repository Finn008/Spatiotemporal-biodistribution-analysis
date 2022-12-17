function [Mask]=dystrophyDetection_Microglia_TotalMap(Iba1,Iba1Perc,Outside,Pix,Res,Application)




[~,Iba1Corr]=sparseFilter(Iba1,Outside,Res,100,[100;100;1],[10;10;Res(3)],70,'Multiply1000');
[Data,OrigData]=sparseFilter(Data,Exclude,Res,VoxelNumber,FilterRadius,ResCalc,Percentile,SubtractBackground)

Threshold=70;
Mask=Iba1Perc>Threshold;

BW=bwconncomp(Mask,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<=0.12,:)=[]; % everything small as pixel

Ind=cell2mat(Table.IdxList);
Mask=zeros(Pix(1),Pix(2),Pix(3),'uint16');
Mask(Ind)=1;

BW=bwconncomp(Mask,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));

Table(Table.Volume<=50,:)=[];

Ind=cell2mat(Table.IdxList);
Mask=zeros(Pix.','uint16');
Mask(Ind)=1;