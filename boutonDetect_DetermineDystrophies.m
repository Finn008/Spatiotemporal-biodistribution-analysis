function [Dystrophies,VglutGreenPerc]=boutonDetect_DetermineDystrophies(VglutGreen,Outside,Blood,Res)
% Timer=datenum(now);
Pix=size(VglutGreen).';
Um=Pix.*Res;

Exclude=Outside>0|Blood==1;
clear Blood; clear Outside;
VglutGreenBackground=sparseFilter(VglutGreen,Exclude,Res,10000,[25;25;Um(3)],[2;2;Um(3)],85);

MinMax=[min(VglutGreenBackground(:));max(VglutGreenBackground(:))];
VglutGreenBackground=uint16(single(VglutGreen)-single(VglutGreenBackground)+single(MinMax(2)));
clear ExactVglutGreen;

% Wave1=VglutGreenBackground;
% Wave1(Exclude)=NaN;
% Wave2=prctile(Wave1(:),80);
% [Out1]=getHistograms_3([],VglutGreenBackground,Exclude==0);

[Threshold1]=prctile_2(VglutGreenBackground,80,Exclude==0);
clear Exclude;
% Threshold1=Out1.Percentiles.a(80);

% Timer=datenum(now);
J=struct('DataOutput','AllPercentiles','Zres',Res(3));
[VglutGreenPerc]=percentiler(VglutGreenBackground,Exclude,J); % 49min
% disp(['Percentiler: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);

Dystrophies=VglutGreenBackground>Threshold1&VglutGreenPerc>80;
clear VglutGreenBackground;
% determine areas
% Timer=datenum(now);
[Dystrophies]=removeIslands_3(Dystrophies,4,[0;1],prod(Res(:)));
% disp(['Imclearborder: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);
% Timer=datenum(now);
[Distance]=distanceMat2D(1-Dystrophies); % 22min
% disp(['Distance: ',num2str(round((datenum(now)-Timer)*24*60)),'min']);
BW=bwconncomp(Dystrophies,4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Area=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Area>3,:);

for m=1:size(Table,1)
    Table.MaxDist(m,1)=max(Distance(Table.IdxList{m}));
end
Table=Table(Table.MaxDist>1,:);
Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint8');
for m=1:size(Table,1)
    Dystrophies(Table.IdxList{m})=Table.MaxDist(m);
end

BW=bwconncomp(logical(Dystrophies),6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Volume=Table.NumPix*prod(Res(1:3));
Table=Table(Table.Volume>3,:);

for m=1:size(Table,1)
    Table.MaxDist(m,1)=max(Distance(Table.IdxList{m}));
end


clear Distance;
Table=Table(Table.Volume>5,:);
Dystrophies=zeros(Pix(1),Pix(2),Pix(3),'uint8');
for m=1:size(Table,1)
    Dystrophies(Table.IdxList{m})=1;
end
