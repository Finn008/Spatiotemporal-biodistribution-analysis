function [BoutonList,BoutonIds,Dystrophies2,Dystrophies2Radius,VglutGreenCorr,GRratio]=boutonDetect_DetermineDystrophies_2(VglutGreen,Exclude,Res,VglutRedCorr,Notes)
tic;
Pix=size(VglutGreen).';
Um=Pix.*Res;
if exist('Notes')==1 && strcmp(Notes,'SkipVglutGreenCorr')
    [~,VglutGreenCorr]=sparseFilter(VglutGreen,Exclude,Res,10000,[30;30;30],[5;5;5],85,'Multiply8000'); % set 85 percentile to 12000, previously 50th to 8000
else
    VglutGreenCorr=VglutGreen;
end
clear VglutGreen;
[Wave1]=prctile_2(VglutGreenCorr,96,Exclude==0);
if Wave1==65535
    keyboard; % VglutGreenCorr oversaturated
end

[Threshold]=prctile_2(VglutGreenCorr,75,Exclude==0);
clear Exclude;
Mask=VglutGreenCorr>Threshold;

[Mask]=removeIslands_3(Mask,4,[0;5],prod(Res(:)));
% ramController(60,20,15);
disp(['Distance before: ',num2str(toc/60),' min']);
Distance=distanceMat_4(logical(1-Mask),'DistInOut',Res,0.1,1,0,0);
disp(['Distance after: ',num2str(toc/60),' min']);
clear Mask;

Watershed=uint8(10)-uint8(Distance); % previously 4
Watershed=single(watershed(Watershed,26));
disp(['Watershed after: ',num2str(toc/60),' min']);
Watershed(Distance==0)=0;

BW=bwconncomp(logical(Watershed),6);
clear Watershed;
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3));
Wave1=struct2table(regionprops(BW,'Centroid'));
Table.Centroid=Wave1.Centroid;
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
Table.XYZum=Table.XYZum-repmat(Um.'/2,[size(Table,1),1]);

BoutonIds=labelmatrix(BW);
clear BW;
% get maximal area in XY
% keyboard; % check if accumarray_9 provides same results as accumarray_2
Wave1=accumarray_9({BoutonIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXY=max(double(Wave1),[],2)*prod(Res(1:2));
Wave1=accumarray_9(BoutonIds,Distance,@max,[],[],[],{1,0});
% [Output]=accumarray_9(Rois,Data,Function,OutputFormat,AccumMethod,CountInstances,RoiExclude)
Table.DistInMax(Wave1.Roi1,1)=double(Wave1.Value1)/10;

% define Dystrophies2: Volume>20µm^3 and DistInMax>=1µm
Wave1=uint16(Table.DistInMax*10);
Wave1=Wave1(BoutonIds(BoutonIds>0));
Dystrophies2Radius=BoutonIds;
Dystrophies2Radius(BoutonIds>0)=Wave1; Dystrophies2Radius=uint16(Dystrophies2Radius);

% include structures >20µm^3 into digits 3 to 5
Wave1=uint16(ceil(Table.Volume));
Wave1=Wave1(BoutonIds(BoutonIds>0));
Dystrophies2=BoutonIds;
Dystrophies2(BoutonIds>0)=Wave1; Dystrophies2=uint16(Dystrophies2);

Wave1=accumarray_9(BoutonIds,VglutGreenCorr,@max,[],[],[],{1,0});
Table.VglutGreenMax(Wave1.Roi1,1)=Wave1.Value1;
Table.VglutGreenHWI=uint16(Table.VglutGreenMax/2);

Wave1=Table.VglutGreenHWI(BoutonIds(BoutonIds>0));
VglutGreenHWIbackground=BoutonIds;
VglutGreenHWIbackground(BoutonIds>0)=Wave1; VglutGreenHWIbackground=uint16(VglutGreenHWIbackground); % background
VglutGreenHWIbackground=VglutGreenCorr<VglutGreenHWIbackground;
BoutonIds(VglutGreenHWIbackground==1)=0;
clear VglutGreenHWIbackground;

% get maximal area in XY
Wave1=accumarray_9({BoutonIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXYHWI=max(double(Wave1),[],2)*prod(Res(1:2));

Wave1=accumarray_9(BoutonIds,Distance,@min,[],[],[],{1,0});
clear Distance;
Table.DistInMin(Wave1.Roi1,1)=double(Wave1.Value1)/10;
Table.DistInDiff=Table.DistInMax-Table.DistInMin;

Wave1=accumarray_9(BoutonIds,ones(Pix.','uint8'),@sum,[],[],[],{1,0});
Table.VolumeHWI(Wave1.Roi1,1)=double(Wave1.Value1)*prod(Res(:));

GRratio=uint16(single(VglutGreenCorr)./single(VglutRedCorr)*2000);
IntensityData={'VglutGreen',VglutGreenCorr;'VglutRed',VglutRedCorr;'GRratio',GRratio};
clear VglutRedCorr;
for m=1:size(IntensityData,1)
    Wave1=accumarray_9(BoutonIds,IntensityData{m,2},@mean,[],[],[],{1,0});
    Table{Wave1.Roi1,[IntensityData{m,1},'Mean']}=Wave1.Value1;
end
clear IntensityData;
try % remove if working for one time
    BoutonList=Table(:,{'ID','XYZum','AreaXY','AreaXYHWI','Volume','VolumeHWI','DistInMin','DistInMax','DistInDiff','VglutGreenMax','VglutGreenHWI','VglutGreenMean','VglutRedMean','GRratioMean','Centroid','NumPix'});
catch
    keyboard;
end

Wave1=find(BoutonIds==0);

BoutonIds=(double(BoutonIds)-floor(double(BoutonIds)/256)*256);
BoutonIds(Wave1)=0;
disp(['boutonDetect_DetermineDystrophies_2 finished: ',num2str(toc/60),' min']);