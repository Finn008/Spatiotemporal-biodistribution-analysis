function [Autofluo2,VglutRedCorr]=boutonDetect_DetermineAutofluorescence(VglutRed,Exclude,Res)
Timer=datenum(now);
Pix=size(VglutRed).';
Um=Pix.*Res;

[~,VglutRedCorr]=sparseFilter(VglutRed,Exclude>0,Res,10000,[30;30;30],[5;5;5],70,'Multiply2000'); % set 70th to 2000, previously 50th to 10000 % few 84a files are saturated at percentile 99.9 currently
disp(['Autofluo1: ',datestr(now,'HH:MM')]);
clear VglutRed;
% [Wave1]=prctile_2(VglutRedCorr,99.9,Exclude==0);
% if Wave1==65535
%     keyboard; % VglutGreenCorr oversaturated
% end

clear VglutRed;
PercentileThreshold=99.5;
[Threshold]=prctile_2(VglutRedCorr,PercentileThreshold,Exclude==0);
if Threshold==65535
    keyboard; % VglutGreenCorr oversaturated
end
Autofluo2=VglutRedCorr>Threshold;
BW=bwconncomp(Autofluo2,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Volume=Table.NumPix*prod(Res(1:3));
Table=Table(Table.Volume>1,:);

Autofluo2=zeros(Pix(1),Pix(2),Pix(3),'uint8');
Autofluo2(cell2mat(Table.IdxList))=1;

% for m=1:size(Table,1)
%     Autofluo2(Table.IdxList{m})=1;
% end

