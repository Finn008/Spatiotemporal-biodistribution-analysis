function [PlaqueMap,PlaqueData]=wholeSliceQuantification_PlaqueDetection_2(MetBlue,Outside)
% make the small median filter
Res2=[1.6;1.6;Res(3)];
MetBlueMedian2=interpolate3D(MetBlue,Res,Res2);
Outside2=interpolate3D(Outside,Res,Res2);
[Window,WindowPix]=imdilateWindow([10;10;Res(3)],Res2);

MetBlueMedian2=single(MetBlueMedian2);
MetBlueMedian2(Outside2==1)=NaN;
tic;
MetBlueMedian2=uint16(medfilt3(MetBlueMedian2,WindowPix.')); % 1min
disp(['medfilt3: ',num2str(toc/60),' min']);

MetBlueMedian=interpolate3D(MetBlueMedian2,[],[],Pix);

% calculate the 90th percentile
tic;
[MetBluePrc90,~]=sparseFilter_2(MetBlue,Outside,Res,5000,[250;250;2],[40;40;Res(3)],90,'Multiply1000'); % 1min % 80µm plaque diameter would make 10% of 250µm, 60µm plaque would make 190µm
%     [Data,OrigData]=sparseFilter_2(Data,Exclude,Res,VoxelNumber,FilterRadius,ResCalc,Percentile,SubtractBackground)
disp(['MetBluePrc90: ',num2str(toc/60),' min']);
MetBluePrc90=uint16(MetBluePrc90);

MetBlueRatio90ToRaw=uint16(single(MetBlue)./single(MetBluePrc90)*100);

% run medianfilter at several diameters (10, 20, 40, 60, 100, 250)

keyboard;

PlaqueMap=zeros(Pix.','uint8');
PlaqueMap(MetBlue>MetBluePrc90)=1;
PlaqueMap(MetBlue<=MetBlueMedian)=0;
PlaqueMap(MetBlue>=MetBluePrc90*2)=1;
PlaqueMap(Outside==1)=0;

tic;
BW=bwconncomp(PlaqueMap,6);
disp(['Segmentation: ',num2str(toc/60),' min']);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res(1:3));
Table.Radius=(Table.Volume*3/4/3.1415).^(1/3);
Table=Table(Table.Volume>=50,:);
% PlaqueData=Table;
PlaqueMap(:)=0;
PlaqueMap(cell2mat(Table.IdxList))=1;
BW=bwconncomp(PlaqueMap,6);
PlaqueMap=labelmatrix(BW);
clear BW;


Wave1=PlaqueMap(MetBlue>=MetBluePrc90*2);
Wave2=unique(Wave1); Wave2(Wave2==0)=[];
% =accumarray_8(interpolate3D(Mask,Res,[1.6;1.6;1.6]),(MetBlue>=MetBluePrc90*2),@max);
Table.CorePlaqueTouch(Wave2,1)=1;
Table=Table(Table.CorePlaqueTouch==1,:);

PlaqueMap(:)=0;
PlaqueMap(cell2mat(Table.IdxList))=1;
BW=bwconncomp(PlaqueMap,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res(1:3));
Table.Radius=(Table.Volume*3/4/3.1415).^(1/3);
% Table=Table(Table.Volume>=50,:);
PlaqueMap=labelmatrix(BW);
clear BW;

















FilenameTotalTest='Test6.ims';
ex2Imaris_2(MetBlueRatio90ToRaw,FilenameTotalTest,'MetBlueRatio90ToRaw');
imarisSaveHDFlock(FilenameTotalTest);
Application=openImaris_2(FilenameTotalTest,1);




MetBlueCorr=MetBlue;
MetBlueCorr(MetBlue<=MetBlueMedian)=0;
MetBlueCorr(MetBlue<=MetBluePrc90)=0;

%     MetBlueCorr=MetBlue;
% watershed: PlaqueCore=0, "Fibrils"=1, anything=2
WatershedData=zeros(Pix.','uint8')+2;
WatershedData(MetBlue>MetBluePrc90)=1;
WatershedData(MetBlue<=MetBlueMedian)=2;
WatershedData(MetBlue>=MetBluePrc90*2)=0;
WatershedData(Outside==1)=2;







keyboard;
WatershedDataOutput=watershed(WatershedData,6); % 14:56

WatershedDataOutput=WatershedData;
OrigWatershedData=WatershedData;
WatershedData(Distance==0)=0;
%     WatershedData=single(WatershedDistance);
%
% Wave1=floor(WatershedDistance/65535);
%     WatershedDistance2=uint16(WatershedDistance-(floor(WatershedDistance/65535)*65535));

%     WatershedData2=interpolate3D(WatershedData,Res,Res2);
%     [Application]=dataInspector3D({WatershedData2},Res2,{'WatershedData2'},[],'Test.ims',1);

%     PlaqueCore=MetBlue>(MetBluePrc90*2);



%     Wave1=uint8(4)-Distance;



ThresholdCorr=prctile_2(MetBlueCorr,90,Outside==0); % % % %
Threshold2=prctile_2(MetBlue,(98:0.1:100).',Outside==0);







%     [Application]=dataInspector3D({MetBlueCorr},Res,{'MetBlueCorr'},1,'Test5.ims',1);
[Application]=dataInspector3D({MetBlue;Outside;MetBlueMedian;MetBluePrc90;MetBlueCorr},Res,{'MetBlue';'Outside';'MetBlueMedian';'MetBluePrc90';'MetBlueCorr'},1,'Test6.ims',1);



ThresholdCorr=prctile_2(MetBlueCorr,90,Outside==0); % % % % Threshold=prctile_2(MetBlue,(80:2:100).',Outside==0);



% 1432 before






Xranges=(TilePix(1):TilePix(1):Pix(1)).'; Xranges=[Xranges-TilePix(1)+1,Xranges];
Yranges=(TilePix(2):TilePix(2):Pix(2)).'; Yranges=[Yranges-TilePix(2)+1,Yranges];
%     TileNumber=Pix(1:2)./TilePix;
[Window,WindowPix]=imdilateWindow([10;10;10],Res);
WindowPix=[7;7;7];

for X=1:size(Xranges,1)
    for Y=1:size(Yranges,1)
        tic;
        Chunk=MetBlue(Xranges(X,1):Xranges(X,2),Yranges(Y,1):Yranges(Y,2),:);
        Chunk=double(Chunk);
        Chunk(:)=NaN;
        Chunk=medfilt3(Chunk,WindowPix.'); % 2.2min
        %             MetBlueMedian(Xranges(X,1):Xranges(X,2),Yranges(Y,1):Yranges(Y,2),:)=Chunk;
        disp(['medfilt3: ',num2str(toc/60),' min']);
    end
end


% 2.2 min for 1024x1024
% 6.4 min for 4x as much data
% 2.5 min for double instead of uint16
% 4.0 min if double with NaN
% 0.25min uint16, kernel only in 2D
% 0.34min double with NaN, kernel only in 2D
% 0.65min double with NaN, kernel 7x7x7





%     Threshold=prctile_2(MetBlue,80,Outside==0)*4; % % % % Threshold=prctile_2(MetBlue,(80:2:100).',Outside==0);


% look at the data, 2000 is representing only 1% ?
% make a intensity histogram
%     A1=MetBlueCorr(Outside==0);
% % %     [CumSum,Histogram,Ranges]=cumSumGenerator(MetBlueCorr(Outside==0)); figure; plot(mean(Ranges,2),Histogram);

% allow 90%, morphological separateion using watershed
% allow as plaques only such that have intensity higher than 95th percentile



Wave1=500;
Center=round(Pix/2);
MetBlue2=MetBlue(Center(1)-Wave1:Center(1)+Wave1,Center(2)-Wave1:Center(2)+Wave1,:);
%     Threshold=prctile(MetBlue2,90);
[Window,WindowPix]=imdilateWindow([10;10;10],Res);
tic;
MetBlueMed1=medfilt3(MetBlue2,WindowPix.'); % 2min
disp(['medfilt3: ',num2str(toc/60),' min']);

tic;
MetBlueMed2=imfilter(MetBlue2,WindowPix.');
disp(['imfilter: ',num2str(toc/60),' min']);
% 10:41- 1010:43
MetBlueCorr2=MetBlue2-(MetBlueMed1+1);

[Application]=dataInspector3D({MetBlue2;MetBlueMed1;MetBlueCorr2},Res,{'MetBlue2';'MetBlueMed1';'MetBlueCorr2'},1,'Test.ims');
Application=openImaris_2('Test.ims',1);

PlaqueMap=MetBlue>=Threshold;


%     [PlaqueMap]=removeIslands_3(PlaqueMap,6,[0;10],prod(Res(:)));
Wave1=imclearborder(1-PlaqueMap,18); PlaqueMap=PlaqueMap+Wave1; clear Wave1;
disp(['RemoveIslands: ',num2str(toc/60),' min']);

Wave1=imerode(PlaqueMap,imdilateWindow([1;1;1],Res));
Wave1=imdilate(Wave1,imdilateWindow([1;1;1],Res));
PlaqueMap(Wave1==0)=0;

BW=bwconncomp(PlaqueMap,6);
disp(['Segmentation: ',num2str(toc/60),' min']);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res(1:3));
Table.Radius=(Table.Volume*3/4/3.1415).^(1/3);
Table=Table(Table.Radius>=3,:);
PlaqueData=Table;
PlaqueMap(:)=0;
PlaqueMap(cell2mat(Table.IdxList))=1;
BW=bwconncomp(PlaqueMap,6);
PlaqueMap=labelmatrix(BW);
clear BW;

return;
%%



% go on from here
keyboard;
Window1=[0.8;0.8]./Res(1:2);
Window1=round(Window1/2)*2+1;
Window1(Window1<3)=3;
BW=bwconncomp(Inside,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;






Inside=imerode(Inside,ones(Window1.'));

Inside=imdilate(Inside,ones(5,5));

BW=bwconncomp(Inside,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;

Table.Volume=Table.NumPix*prod(Res(1:2));
Table=Table(Table.Volume>(2000*2000*10),:);
Inside=zeros(size(Inside),'uint16');
for m=1:size(Table,1)
    %     for m=find(Table.Volume>=5000).'
    Inside(Table.IdxList{m})=1;
end



[Application]=dataInspector3D(MaxProjection,Res);
%     TestName='\\gnp90n\share\Finn\Raw data\Test.ims';



ex2Imaris_2(MetBlue2,'Test.ims','MetBlue2');
ex2Imaris_2(Inside,'Test.ims','Inside');
Application=openImaris_2('Test.ims'); Application.SetVisible(1);
imarisSaveHDFlock(Application,'Test.ims');
Application=openImaris_2('Test.ims'); Application.SetVisible(1);


[Application2]=dataInspector3D({MetBlue(:,:,20:21);MetBlueCorr(:,:,20:21);Outside(:,:,20:21)},Res,{'MetBlue';'MetBlueCorr';'Outside';},1,'Test.ims',0);