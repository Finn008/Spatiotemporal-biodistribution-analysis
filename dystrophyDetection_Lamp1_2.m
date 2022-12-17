function [Dystrophies,Lamp1]=dystrophyDetection_Lamp1_2(FilenameTotal)

[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};


[Lamp1]=im2Matlab_3(FilenameTotal,'Lamp1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
[~,Lamp1]=sparseFilter(Lamp1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply500'); % previously Multiply500
Pix=size(Lamp1).';

[Membership]=im2Matlab_3(FilenameTotal,'Membership');
[DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut');
PlaqueMapTotal=Membership.*uint16(DistInOut<=50);


% Threshold=prctile(Lamp1(Outside==0),70); % 5000
% Threshold=5000;
Threshold=prctile(Lamp1(Outside==0),70);
Dystrophies=Lamp1>Threshold;


% Window1=[0.3;0.3]./Res(1:2);
% Window1=round(Window1/2)*2+1;
% Window1(Window1<3)=3;
% Dystrophies=imdilate(Dystrophies,ones(Window1.'));

% Window2=[0.8;0.8]./Res(1:2);
Window2=[0.3;0.3]./Res(1:2);
Window2=round(Window2/2)*2+1;
Window2(Window2<3)=3;
Dystrophies=imerode(Dystrophies,ones(Window2.'));

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
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch==0)))=1;
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch>0)))=2;

% Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint16');
% for m=1:size(Table,1)
%     Dystrophies(Table.IdxList{m})=1;
% end

Dystrophies=imdilate(Dystrophies,ones(Window2.'));

Wave1=Lamp1>Threshold;
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
for m=1:size(Table,1)
    Dystrophies(Table.IdxList{m})=1;
end
