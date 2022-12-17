function [Outside2D]=wholeSliceQuantification_Outside_MetBlue_2(Data2D,Res)

Percentiles=prctile_2(Data2D,(1:100).');
Deviation1=diff(smooth(smooth(smooth(double(Percentiles)))));
Deviation2=diff(smooth(smooth(smooth(Deviation1))));
[A1,Wave1]=min(Deviation2);
Threshold=Percentiles(Wave1)*1/2;
Inside2D=Data2D>Threshold;
Inside2D=imerode(Inside2D,imdilateWindow([3;3],Res));
BW=bwconncomp(Inside2D,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Volume>(2000*2000),:); % 2mm*2mm
Inside2D=false(size(Inside2D));
Inside2D(cell2mat(Table.IdxList))=1;
% remove holes within Inside
BW=bwconncomp(logical(1-Inside2D),4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Area=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Area<50^2,:); % previously 5, 1000
Inside2D(cell2mat(Table.IdxList))=1;
Outside2D=uint8(1-Inside2D);