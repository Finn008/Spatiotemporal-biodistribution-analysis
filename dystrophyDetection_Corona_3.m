function [Dystrophies,Data3D,Outside]=dystrophyDetection_Corona_3(Readout)
global ChannelTable; global NameTable;
Fileinfo=getFileinfo_2(ChannelTable{Readout,'SourceFilename'});
Res=Fileinfo.Res{1};

Settings={  '','SpFiPrctile','SpFiSubtrBackgr','IntPrctile','MinVolume';...
    'Bace1',50,'Multiply2500',70,8;...
    'Lamp1',50,'Multiply500',80,50;...
    'APPY188',50,'Multiply500',70,50;...
    'PSync',50,'Multiply1000',95,40;...
    'Ubiquitin',50,'Multiply500',70,1;...
    };
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(ChannelTable.SourceFilename{Readout},ChannelTable.SourceChannelName{Readout});
Fileinfo=getFileinfo_2(ChannelTable.TargetFilename{Readout});
if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=uint8(im2Matlab_3(ChannelTable{'Outside','TargetFilename'},'Outside'));
else
    Outside=zeros(size(Data3D),'uint8');
end

[~,Data3D]=sparseFilter(Data3D,Outside,Res,10000,[200;200;1],[10;10;Res(3)],Settings{Readout,'SpFiPrctile'}{1},Settings{Readout,'SpFiSubtrBackgr'}{1});
Pix=size(Data3D).';

Threshold=prctile(Data3D(Outside==0),Settings{Readout,'IntPrctile'}{1});
% clear Outside;
if strfind1({'Bace1';'Ubiquitin'},Readout)
    [~,Wave1]=imdilateWindow([0.5;0.5;0.5],Res);
    Data3D=uint16(smooth3(Data3D,'gaussian',Wave1));
end
Dystrophies=Data3D>Threshold;

Dystrophies=imopen(Dystrophies,imdilateWindow([0.3;0.3],Res));
Wave1=Data3D>Threshold; Dystrophies(Wave1==0)=0;

% 2D connected component analysis
BW=bwconncomp(Dystrophies,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area<1,:)=[];
Dystrophies=zeros(Pix.','uint16');
Dystrophies(cell2mat(Table.IdxList))=1;

% remove holes
BW=bwconncomp(1-Dystrophies,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Area=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Area<0.2,:);
Dystrophies(cell2mat(Table.IdxList))=1;

% erosion followed by dilation
imopen(Dystrophies,imdilateWindow([1;1;1],Res));

% correct for dilation
Wave1=Data3D>Threshold; Dystrophies(Wave1==0)=0;

% 3D connected component analysis
BW=bwconncomp(Dystrophies,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<=Settings{Readout,'MinVolume'}{1},:)=[];
Dystrophies=zeros(Pix.','uint16');
Dystrophies(cell2mat(Table.IdxList))=1;

% % BW=bwconncomp(Dystrophies,6);
% % Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
% % Table.Volume=Table.NumPix*prod(Res(1:3));
% % Dystrophies=labelmatrix(BW);
% % Wave1=uint16(Table.Volume);
% % Wave1=Wave1(Dystrophies(Dystrophies>0));
% % Dystrophies(Dystrophies>0)=Wave1; Dystrophies=uint16(Dystrophies);


