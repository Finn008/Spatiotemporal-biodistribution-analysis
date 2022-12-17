function [DystrophyData,DystrophiesDiameter]=dystrophyDetection_IndividualDystros_3(DystrophyData,Outside,Res,Settings)
global ShowIntermediateSteps;
global ChannelTable;
if exist('ShowIntermediateSteps','Var') && ShowIntermediateSteps==1
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
else
    ShowIntermediateSteps=0;
end

Pix=size(DystrophyData).';
Um=Pix.*Res;
[~,DystrophyData]=percentileFilter3D_3(DystrophyData,Settings.CorrPrctile{1},Res,[2;2;Res(3)],Outside,Settings.CorrFactor{1},[60;60;8],1);
timeTable('Dystrophy: PercentileFilter3D');
if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyData,Application,'Dystrophy_AfterpercentileFilter3D'); end
if strcmp(Settings.Name{1},'Vglut1')
    [~,Wave1]=imdilateWindow([0.5;0.5;0.5],Res);
    DystrophyData=uint16(smooth3(DystrophyData,'gaussian',Wave1));
end
Threshold=prctile(DystrophyData(Outside==0),Settings.ThreshPrctile{1})*2; % 95 7065

Mask=DystrophyData>Threshold;

ResCalc=[1.5;1.5;Res(3)];
[~,Window]=imdilateWindow([20;20;Res(3)],ResCalc,1); % 80 in 20^2 allows 8.9µm diameter structures; 90 in 20^2 allows 6.3µm diameter structures
[Wave1]=percentileFilter3D(DystrophyData,70,Window,Res,ResCalc,Outside);
Mask(DystrophyData<Wave1)=0;

if strcmp(Settings.Name{1},'Vglut1')
    % 2D local filter (to correct bright image slices)
    ResCalc=[1.5;1.5;Res(3)];
    [~,Window]=imdilateWindow([20;20;Res(3)],ResCalc,1); % 80 in 20^2 allows 8.9µm diameter structures; 90 in 20^2 allows 6.3µm diameter structures
    [Wave1]=percentileFilter3D(DystrophyData,70,Window,Res,ResCalc,Outside);
    Mask(DystrophyData<Wave1)=0;
    % 3D local filter
    ResCalc=[1.5;1.5;1.5];
    [~,Window]=imdilateWindow([10;10;10],ResCalc,1); % 75 in 10^3 allows 6.3µm diameter structures
    [Wave1]=percentileFilter3D(DystrophyData,75,Window,Res,ResCalc,Outside);
    Mask(DystrophyData<Wave1)=0;
    
    clear Wave1;
end

[Mask]=removeIslands_4(Mask,4,[0;5],Res);
BW=bwconncomp(logical(Mask),6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.Volume=Table.NumPix*prod(Res(1:3));
Table(Table.Volume<0.3^3,:)=[];

Settings.SegmentationType{1}='None';
if strcmp(Settings.SegmentationType{1},'SofisticatedSegmentation')
    Table(Table.Volume<0.5^3,:)=[];
    BW.PixelIdxList=Table.IdxList.'; BW.NumObjects=size(BW.PixelIdxList,2);
    Mask=labelmatrix(BW);
    
    WatershedData=double(DystrophyData);
    [Window,Wave1]=imdilateWindow_2([0.6;0.6;0.6],Res,1,'ellipsoid'); % previously 4µm cube
    for m=1:5
        WatershedData(Mask==0)=0;
        WatershedData=imfilter(WatershedData,double(Window)/sum(Window(:)));
    end
    % identify seed loci and watershed from intensity
    Version=struct('SeedImpact','Radius','Thresholds','Dystrophies','WatershedUmBin',0.1,'WatershedType','Intensity&Morphology','IdentifyLocalMaximaExtent',8);
    [DystrophyIds,LocalMaxima,~,Table]=watershedSegmentation_2(Mask,Version,Res,WatershedData);
    if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyIds,Application,'Dystrophies_IDs'); end;
end
if strcmp(Settings.SegmentationType{1},'SimpleWatershed')
    Distance=distanceMat_4(logical(1-Mask),'DistInOut',Res,0.1,1,0,0);
    timeTable('Dystrophy: DistanceTransformation');
    clear Mask;
    if Settings.WatershedMax{1}==0; Settings.WatershedMax{1}=max(Distance(:));end;
    Watershed=uint8(Settings.WatershedMax{1})-uint8(Distance); % previously 10 and before that 4
    Watershed=double(watershed(Watershed,6));
    timeTable('Dystrophy: Watershed');
    Watershed(Distance==0)=0;
end
if strcmp(Settings.SegmentationType{1},'None')

end

Table.ID=(1:size(Table,1)).';

Table.Diameter=((Table.Volume*3/4/3.1415).^(1/3))*2;
Table.Diameter=round(Table.Diameter*10)/10;
Table.Diameter(Table.Diameter==0)=0.1;

BW.PixelIdxList=Table.IdxList.'; BW.NumObjects=size(BW.PixelIdxList,2);

Wave1=struct2table(regionprops(BW,'Centroid'));
Table.Centroid=Wave1.Centroid;
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
Table.XYZum=Table.XYZum-repmat(Um.'/2,[size(Table,1),1]);

DystrophyIds=labelmatrix(BW);
clear BW;

% get maximal area in XY
Wave1=accumarray_9({DystrophyIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXY=max(double(Wave1),[],2)*prod(Res(1:2));
if exist('Distance','Var')
    Wave1=accumarray_9(DystrophyIds,Distance,@max,[],[],[],{1,0});
    Table.DistInMax(Wave1.Roi1,1)=double(Wave1.Value1)/10;
end

% generate DystrophiesDiameter
Wave1=uint16(Table.Diameter*10);
Wave1=Wave1(DystrophyIds(DystrophyIds>0));
DystrophiesDiameter=DystrophyIds;
DystrophiesDiameter(DystrophyIds>0)=Wave1; DystrophiesDiameter=uint16(DystrophiesDiameter);

FurtherMeasurements=0;
if FurtherMeasurements==1
    % generate Dystrophies2Radius
    Wave1=uint16(Table.DistInMax*10);
    Wave1=Wave1(DystrophyIds(DystrophyIds>0));
    Dystrophies2Radius=DystrophyIds;
    Dystrophies2Radius(DystrophyIds>0)=Wave1; Dystrophies2Radius=uint16(Dystrophies2Radius);
    
    % generate Dystrophies2Volume
    Wave1=uint16(ceil(Table.Volume));
    Wave1=Wave1(DystrophyIds(DystrophyIds>0));
    Dystrophies2Volume=DystrophyIds;
    Dystrophies2Volume(DystrophyIds>0)=Wave1; Dystrophies2Volume=uint16(Dystrophies2Volume);
    
    Wave1=accumarray_9(DystrophyIds,DystrophyData,@max,[],[],[],{1,0});
    Table.IntensityMax(Wave1.Roi1,1)=Wave1.Value1;
    Table.HWI=uint16(Table.IntensityMax/2);
    
    Wave1=Table.HWI(DystrophyIds(DystrophyIds>0));
    HWIbackground=DystrophyIds;
    HWIbackground(DystrophyIds>0)=Wave1; HWIbackground=uint16(HWIbackground); % background
    HWIbackground=DystrophyData<HWIbackground;
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
    IntensityData={'Intensity',DystrophyData};
    for m=1:size(IntensityData,1)
        Wave1=accumarray_9(DystrophyIds,IntensityData{m,2},@mean,[],[],[],{1,0});
        Table{Wave1.Roi1,[IntensityData{m,1},'Mean']}=Wave1.Value1;
    end
    clear IntensityData;
    DystrophyList=Table(:,{'ID','XYZum','AreaXY','AreaXYHWI','Volume','VolumeHWI','DistInMin','DistInMax','DistInDiff','IntensityMax','HWI','IntensityMean','Centroid','NumPix'});
    
    Wave1=find(DystrophyIds==0);
    
    DystrophyIds=(double(DystrophyIds)-floor(double(DystrophyIds)/256)*256);
    DystrophyIds(Wave1)=0;
    
end

if ShowIntermediateSteps==1; ex2Imaris_2(DystrophyIds,Application,'Dystrophy_DystrophyIds'); end
if ShowIntermediateSteps==1; ex2Imaris_2(DystrophiesDiameter,Application,'Dystrophy_Diameter'); end

DystrophiesDiameter(Outside==1)=0;
DystrophyData(Outside==1)=0;
