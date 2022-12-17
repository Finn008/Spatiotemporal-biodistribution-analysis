function [Dystrophies,Data3D]=dystrophyDetection_Corona(FilenameTotal,Readout)
global Application;
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};

Settings={  '','SpFiPrctile','SpFiSubtrBackgr','IntPrctile';...
            'Bace1',50,'Multiply2500',70;...
            'Lamp1',50,'Multiply500',70;...
            'APP',50,'Multiply500',70};
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Outside]=im2Matlab_3(FilenameTotal,'Outside');
[Data3D]=im2Matlab_3(FilenameTotal,Readout);
if strfind1(Fileinfo.ChannelList{1},[Readout,'Corona'],1)==0
    [~,Data3D]=sparseFilter(Data3D,Outside,Res,10000,[200;200;1],[10;10;Res(3)],Settings{Readout,'SpFiPrctile'}{1},Settings{Readout,'SpFiSubtrBackgr'}{1});
end
Pix=size(Data3D).';

[Membership]=im2Matlab_3(FilenameTotal,'Membership');
[DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut');
PlaqueMapTotal=Membership.*uint16(DistInOut<=50);
clear Membership; clear DistInOut;
Threshold=prctile(Data3D(Outside==0),70);
clear Outside;
Dystrophies=Data3D>Threshold;

% in BACE1 first dilate and then erode
% erosion
Window1=[0.3;0.3]./Res(1:2);
Window1=round(Window1/2)*2+1;
Window1(Window1<3)=3;
Dystrophies=imerode(Dystrophies,ones(Window1.'));

% in Bace1 first 3D
% 2D connected component analysis
BW=bwconncomp(Dystrophies,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area<0.5,:)=[];
Dystrophies=zeros(Pix.','uint16');
Dystrophies(cell2mat(Table.IdxList))=1;

% correct for erosion
Dystrophies=imdilate(Dystrophies,ones(Window1.'));
Wave1=Data3D>Threshold;
Dystrophies(Wave1==0)=0;

% remove holes
BW=bwconncomp(1-Dystrophies,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Area=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Area<0.5,:);
Dystrophies(cell2mat(Table.IdxList))=1;

% 3D connected component analysis
BW=bwconncomp(Dystrophies,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<1,:)=[];
for m=1:size(Table,1)
    Table.PlaqueTouch(m,1)=max(PlaqueMapTotal(Table.IdxList{m}));
end
Dystrophies=zeros(Pix.','uint16');
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch==0)))=1;
Dystrophies(cell2mat(Table.IdxList(Table.PlaqueTouch>0)))=2;