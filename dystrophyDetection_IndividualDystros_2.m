% [~,~,Vglut1DystrophiesDiameter,~,Vglut1DystrophiesRadius,Vglut1]=dystrophyDetection_IndividualDystros_2(FilenameTotal,'Vglut1',FilenameTotalOrig,ChannelListOrig);
% ex2Imaris_2(Vglut1DystrophiesDiameter,FilenameTotal,'Global75&Local75&2D20/70&Watershed7');
% ex2Imaris_2(Vglut1,FilenameTotal,'VGLUT1&Sparse8');
% Application=openImaris_2(FilenameTotal,1);
% imarisSaveHDFlock(Application,FilenameTotal);
function [DystrophyList,DystrophyIds,DystrophiesDiameter,Dystrophies2Volume,Dystrophies2Radius,Data3D]=dystrophyDetection_IndividualDystros_2(FilenameTotal,Readout,FilenameTotalOrig,ChannelListOrig,Notes)
% % Application=openImaris_2(FilenameTotal,1);
Timer=datenum(now);
Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};


Settings={  '','SpFiPrctile','SpFiSubtrBackgr','IntPrctile';...
            'Vglut1',85,'Multiply10000',75;... % previously 75
            'Vglut1_InVivo',85,'Multiply5000',75;...
            'APPY188',50,'Multiply500',75};
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,Readout,1));
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
Pix=size(Data3D).';

Um=Pix.*Res;
% if exist('Notes')==1 && strcmp(Notes,'SkipSparseFilter')
[~,Data3D]=sparseFilter_2(Data3D,Outside,Res,10000,[30;30;8],[5;5;Res(3)],Settings{Readout,'SpFiPrctile'}{1},Settings{Readout,'SpFiSubtrBackgr'}{1}); % previously [30;30;30]
disp(['SparseFilter: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
% end
% Vglut1Corr=Data3D;
if strcmp(Readout,'Vglut1')
    [~,Wave1]=imdilateWindow([0.5;0.5;0.5],Res);
    Data3D=uint16(smooth3(Data3D,'gaussian',Wave1));
end
Threshold=prctile(Data3D(Outside==0),Settings{Readout,'IntPrctile'}{1});

Mask=Data3D>Threshold;

if strcmp(Readout,'Vglut1')
    % 2D local filter (to correct bright image slices)
    ResCalc=[1.5;1.5;Res(3)];
    [~,Window]=imdilateWindow([20;20;Res(3)],ResCalc,1); % 80 in 20^2 allows 8.9µm diameter structures; 90 in 20^2 allows 6.3µm diameter structures
    [Wave1]=percentileFilter3D(Data3D,70,Window,Res,ResCalc,Outside);
    Mask(Data3D<Wave1)=0;
    % 3D local filter
    ResCalc=[1.5;1.5;1.5];
    [~,Window]=imdilateWindow([10;10;10],ResCalc,1); % 75 in 10^3 allows 6.3µm diameter structures
    [Wave1]=percentileFilter3D(Data3D,75,Window,Res,ResCalc,Outside);
    Mask(Data3D<Wave1)=0;
    
    clear Wave1;
    disp(['PercentileFilter3D: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
end
clear Outside;

[Mask]=removeIslands_4(Mask,4,[0;5],Res);

Distance=distanceMat_4(logical(1-Mask),'DistInOut',Res,0.1,1,0,0);
disp(['DistanceTransformation: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
clear Mask;

Watershed=uint8(7)-uint8(Distance); % previously 10 and before that 4
Watershed=single(watershed(Watershed,26));
disp(['Watershed: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);
Watershed(Distance==0)=0;

BW=bwconncomp(logical(Watershed),6);
clear Watershed;
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table.Diameter=((Table.Volume*3/4/3.1415).^(1/3))*2;
Table.Diameter=round(Table.Diameter*10)/10;
Table.Diameter(Table.Diameter==0)=0.1;

Wave1=struct2table(regionprops(BW,'Centroid'));
Table.Centroid=Wave1.Centroid;
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
Table.XYZum=Table.XYZum-repmat(Um.'/2,[size(Table,1),1]);

DystrophyIds=labelmatrix(BW);
clear BW;
% get maximal area in XY
% keyboard; % check if accumarray_9 provides same results as accumarray_2
Wave1=accumarray_9({DystrophyIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXY=max(double(Wave1),[],2)*prod(Res(1:2));
Wave1=accumarray_9(DystrophyIds,Distance,@max,[],[],[],{1,0});
Table.DistInMax(Wave1.Roi1,1)=double(Wave1.Value1)/10;

% define Dystrophies2: Volume>20µm^3 and DistInMax>=1µm
Wave1=uint16(Table.Diameter*10);
Wave1=Wave1(DystrophyIds(DystrophyIds>0));
DystrophiesDiameter=DystrophyIds;
DystrophiesDiameter(DystrophyIds>0)=Wave1; DystrophiesDiameter=uint16(DystrophiesDiameter);

% define Dystrophies2: Volume>20µm^3 and DistInMax>=1µm
Wave1=uint16(Table.DistInMax*10);
Wave1=Wave1(DystrophyIds(DystrophyIds>0));
Dystrophies2Radius=DystrophyIds;
Dystrophies2Radius(DystrophyIds>0)=Wave1; Dystrophies2Radius=uint16(Dystrophies2Radius);

% include structures >20µm^3 into digits 3 to 5
Wave1=uint16(ceil(Table.Volume));
Wave1=Wave1(DystrophyIds(DystrophyIds>0));
Dystrophies2Volume=DystrophyIds;
Dystrophies2Volume(DystrophyIds>0)=Wave1; Dystrophies2Volume=uint16(Dystrophies2Volume);

Wave1=accumarray_9(DystrophyIds,Data3D,@max,[],[],[],{1,0});
Table.IntensityMax(Wave1.Roi1,1)=Wave1.Value1;
Table.HWI=uint16(Table.IntensityMax/2);

Wave1=Table.HWI(DystrophyIds(DystrophyIds>0));
HWIbackground=DystrophyIds;
HWIbackground(DystrophyIds>0)=Wave1; HWIbackground=uint16(HWIbackground); % background
HWIbackground=Data3D<HWIbackground;
DystrophyIds(HWIbackground==1)=0;
clear HWIbackground;

% get maximal area in XY
Wave1=accumarray_9({DystrophyIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXYHWI=max(double(Wave1),[],2)*prod(Res(1:2));

Wave1=accumarray_9(DystrophyIds,Distance,@min,[],[],[],{1,0});
clear Distance;
Table.DistInMin(Wave1.Roi1,1)=double(Wave1.Value1)/10;
Table.DistInDiff=Table.DistInMax-Table.DistInMin;

Wave1=accumarray_9(DystrophyIds,ones(Pix.','uint8'),@sum,[],[],[],{1,0});
Table.VolumeHWI(Wave1.Roi1,1)=double(Wave1.Value1)*prod(Res(:));

% GRratio=uint16(single(Data3D)./single(VglutRedCorr)*2000);
IntensityData={'Intensity',Data3D};
for m=1:size(IntensityData,1)
    Wave1=accumarray_9(DystrophyIds,IntensityData{m,2},@mean,[],[],[],{1,0});
    Table{Wave1.Roi1,[IntensityData{m,1},'Mean']}=Wave1.Value1;
end
clear IntensityData;
DystrophyList=Table(:,{'ID','XYZum','AreaXY','AreaXYHWI','Volume','VolumeHWI','DistInMin','DistInMax','DistInDiff','IntensityMax','HWI','IntensityMean','Centroid','NumPix'});

Wave1=find(DystrophyIds==0);

DystrophyIds=(double(DystrophyIds)-floor(double(DystrophyIds)/256)*256);
DystrophyIds(Wave1)=0;
disp(['Finished: ',num2str(round((datenum(now)-Timer)*24*60,1)),' min']); Timer=datenum(now);