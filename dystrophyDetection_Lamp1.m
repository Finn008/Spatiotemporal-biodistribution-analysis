function [Dystrophies,Lamp1]=dystrophyDetection_Lamp1(FilenameTotal,Pix,Res)

[Lamp1]=im2Matlab_3(FilenameTotal,'Lamp1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
[~,Lamp1]=sparseFilter(Lamp1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply500');


[Membership]=im2Matlab_3(FilenameTotal,'Membership');
[DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut');
PlaqueMapTotal=Membership.*uint16(DistInOut<=50);


Threshold=prctile(Lamp1(Outside==0),70);
Dystrophies=Lamp1>Threshold;

Dystrophies=imerode(Dystrophies,ones(3,3,3));

BW=bwconncomp(Dystrophies,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<1,:)=[];
for m=1:size(Table,1)
    Table.PlaqueTouch(m,1)=max(PlaqueMapTotal(Table.IdxList{m}));
end
Table(Table.PlaqueTouch==0,:)=[];
Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    Dystrophies(Table.IdxList{m})=1;
end

BW=bwconncomp(Dystrophies,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area<0.5,:)=[];
Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    Dystrophies(Table.IdxList{m})=1;
end
ex2Imaris_2(Dystrophies,FilenameTotal,'Lamp1Corona');
ex2Imaris_2(Lamp1,FilenameTotal,'Lamp1');