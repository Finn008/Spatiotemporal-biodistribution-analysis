function [Dystrophies,Vglut1]=dystrophyDetection_IndividualDystros(FilenameTotal,Readout,FilenameTotalOrig,ChannelListOrig)
% [BoutonList,BoutonIds,Dystrophies2,Dystrophies2Radius,Vglut1Corr,GRratio]=boutonDetect_DetermineDystrophies_2(Vglut1,Outside,Res,VglutRedCorr,Notes)
Application=openImaris_2(FilenameTotal,1);
Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};


Settings={  '','SpFiPrctile','SpFiSubtrBackgr','IntPrctile';...
            'Vglut1Venus',85,'Multiply5000',70;...
            'APPY188',50,'Multiply500',70};
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,Readout,1));
% [Vglut1]=im2Matlab_3(FilenameTotal,'Vglut1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
Pix=size(Data3D).';
%% 
% tic;
% Pix=size(Vglut1).';
Um=Pix.*Res;
% if exist('Notes')==1 && strcmp(Notes,'SkipVglut1Corr')
% [~,Vglut1Corr]=sparseFilter_2(Vglut1,Outside,Res,10000,[30;30;30],[5;5;Res(3)],85,'Multiply8000'); % set 85 percentile to 12000, previously 50th to 8000
[~,Data3D]=sparseFilter_2(Data3D,Outside,Res,10000,[30;30;30],[5;5;Res(3)],Settings{Readout,'SpFiPrctile'}{1},Settings{Readout,'SpFiSubtrBackgr'}{1});

% 


% [~,Bace1]=sparseFilter(Bace1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply2500'); % previously Multiply500
% sparseFilter_2(Data,Exclude,Res,VoxelNumber,FilterRadius,ResCalc,Percentile,SubtractBackground)
% else
%     Vglut1Corr=Vglut1;
% end
clear Vglut1;

[Threshold]=prctile_2(Vglut1Corr,75,Outside==0);
clear Outside;
Mask=Vglut1Corr>Threshold;
ex2Imaris_2(Mask,Application,'Test');

[Mask]=removeIslands_3(Mask,4,[0;5],prod(Res(:)));
ex2Imaris_2(Mask,Application,'Test1');
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

Wave1=accumarray_9(BoutonIds,Vglut1Corr,@max,[],[],[],{1,0});
Table.Vglut1Max(Wave1.Roi1,1)=Wave1.Value1;
Table.Vglut1HWI=uint16(Table.Vglut1Max/2);

Wave1=Table.Vglut1HWI(BoutonIds(BoutonIds>0));
Vglut1HWIbackground=BoutonIds;
Vglut1HWIbackground(BoutonIds>0)=Wave1; Vglut1HWIbackground=uint16(Vglut1HWIbackground); % background
Vglut1HWIbackground=Vglut1Corr<Vglut1HWIbackground;
BoutonIds(Vglut1HWIbackground==1)=0;
clear Vglut1HWIbackground;

% get maximal area in XY
Wave1=accumarray_9({BoutonIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXYHWI=max(double(Wave1),[],2)*prod(Res(1:2));

Wave1=accumarray_9(BoutonIds,Distance,@min,[],[],[],{1,0});
clear Distance;
Table.DistInMin(Wave1.Roi1,1)=double(Wave1.Value1)/10;
Table.DistInDiff=Table.DistInMax-Table.DistInMin;

Wave1=accumarray_9(BoutonIds,ones(Pix.','uint8'),@sum,[],[],[],{1,0});
Table.VolumeHWI(Wave1.Roi1,1)=double(Wave1.Value1)*prod(Res(:));

GRratio=uint16(single(Vglut1Corr)./single(VglutRedCorr)*2000);
IntensityData={'Vglut1',Vglut1Corr;'VglutRed',VglutRedCorr;'GRratio',GRratio};
clear VglutRedCorr;
for m=1:size(IntensityData,1)
    Wave1=accumarray_9(BoutonIds,IntensityData{m,2},@mean,[],[],[],{1,0});
    Table{Wave1.Roi1,[IntensityData{m,1},'Mean']}=Wave1.Value1;
end
clear IntensityData;
try % remove if working for one time
    BoutonList=Table(:,{'ID','XYZum','AreaXY','AreaXYHWI','Volume','VolumeHWI','DistInMin','DistInMax','DistInDiff','Vglut1Max','Vglut1HWI','Vglut1Mean','VglutRedMean','GRratioMean','Centroid','NumPix'});
catch
    keyboard;
end

Wave1=find(BoutonIds==0);

BoutonIds=(double(BoutonIds)-floor(double(BoutonIds)/256)*256);
BoutonIds(Wave1)=0;
disp(['boutonDetect_DetermineDystrophies_2 finished: ',num2str(toc/60),' min']);

return;
%% DystrophyDetection BACE1
[~,Vglut1]=sparseFilter(Vglut1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply2500'); % previously Multiply500


[Membership]=im2Matlab_3(FilenameTotal,'Membership');
[DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut');
PlaqueMapTotal=Membership.*uint16(DistInOut<=50);

% Threshold=prctile(Vglut1(Outside==0),70); % 5000
Threshold=5000; % instead of double of intensity at 50th percentile use directly one defined percentile as threshold
Dystrophies=Vglut1>Threshold;


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

% Dystrophies(cell2mat(Table.IdxList))=1;
% for m=1:size(Table,1)
%     Dystrophies(Table.IdxList{m})=1;
% end

Window3=Window2-Window1+1;
Dystrophies=imdilate(Dystrophies,ones(Window3.'));

Wave1=Vglut1>Threshold;
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
% for m=1:size(Table,1)
%     Dystrophies(Table.IdxList{m})=1;
% end


