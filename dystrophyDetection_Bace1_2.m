% attention: on2016.1004 from Window2=[0.5;0.5;0.5]./Res; to Window2=[0.5;0.5]./Res;
function [Dystrophies,Bace1]=dystrophyDetection_Bace1_2(FilenameTotal)

[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};


[Bace1]=im2Matlab_3(FilenameTotal,'Bace1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
[~,Bace1]=sparseFilter(Bace1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply2500'); % previously Multiply500

Pix=size(Bace1).';

[Membership]=im2Matlab_3(FilenameTotal,'Membership');
[DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut');
PlaqueMapTotal=Membership.*uint16(DistInOut<=50);

Threshold=prctile(Bace1(Outside==0),70); % 5000
% % % % Threshold=5000; % instead of double of intensity at 50th percentile use directly one defined percentile as threshold
Dystrophies=Bace1>Threshold;


Window1=[0.3;0.3]./Res(1:2);
Window1=round(Window1/2)*2+1;
Window1(Window1<3)=3;
Dystrophies=imdilate(Dystrophies,ones(Window1.'));

Window2=[0.5;0.5]./Res(1:2);
Window2=round(Window2/2)*2+1;
Window2(Window2<3)=3;
Dystrophies=imerode(Dystrophies,ones(Window2.'));

BW=bwconncomp(Dystrophies,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<1,:)=[];
for m=1:size(Table,1)
    Table.PlaqueTouch(m,1)=max(PlaqueMapTotal(Table.IdxList{m}));
end
% Table(Table.PlaqueTouch==0,:)=[];
Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint16');
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch==0)))=1;
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch>0)))=2;

Window3=Window2-Window1+1;
Dystrophies=imdilate(Dystrophies,ones(Window3.'));
Wave1=Bace1>Threshold;
Dystrophies(Wave1==0)=0;

% remove holes
BW=bwconncomp(1-Dystrophies,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(Res(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area<0.5,:); % previously 1000
Dystrophies(cell2mat(Table.IdxList))=1;