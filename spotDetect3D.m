function Table=spotDetect3D(Data3D,Outside,Res,Percentile,FilenameTotal,IntensityData)

Pix=size(Data3D).';
% Application=openImaris_2(FilenameTotal);Application.SetVisible(1);
Threshold=prctile(Data3D(Outside==0),Percentile);

Mask=Data3D>Threshold;
% close islands
[Mask]=removeIslands_3(Mask,4,[0;0.4*0.2*0.2],prod(Res(:)));

% ex2Imaris_2(Mask,Application,'Mask');

J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,1-Mask);
Distance=Out.DistInOut; clear Out;
% ex2Imaris_2(Distance,Application,'Distance');

WatershedDistance=uint8(10)-Distance; % previously 4
% WatershedDistance=uint8(4)-Distance;
WatershedDistance=single(watershed(WatershedDistance));
% WatershedDistance=single(WatershedDistance);
WatershedDistance(Distance<=1)=0;
WatershedDistance2=WatershedDistance-floor(WatershedDistance/65536)*65536; % WatershedDistance2=WatershedDistance-floor(WatershedDistance/255)*255+1;WatershedDistance2(WatershedDistance==0)=0;
% ex2Imaris_2(WatershedDistance2,Application,'Membership');
% Wave1=floor(WatershedDistance/65535);

% Wave1=floor(WatershedDistance/65536);
% WatershedDistance2=WatershedDistance-Wave1*65536;
% WatershedDistance2=uint16(WatershedDistance-(floor(WatershedDistance/65535)*65535));

BW=bwconncomp(WatershedDistance,26);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Wave1=struct2table(regionprops(BW,'Centroid'));
Table.Position(:,1:3)=(Wave1.Centroid-1).*repmat(Res.',[size(Table,1),1]);
Table.Position(:,1:3)=Table.Position(:,[2,1,3]);
clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>(0.25*0.25*0.4),:);

Membership=zeros(Pix.','single');
% % % Boutons(cell2mat(Table.IdxList))=1;
for m=1:size(Table,1)
    Membership(Table.IdxList{m})=m;
end
keyboard; % check if accumarray_8 provides same results as accumarray_2
[Wave1]=accumarray_8(Membership,Distance,@max);
Table.MinRadius(Wave1.Roi1,1)=Wave1.Value/10;
[Wave1]=accumarray_8(Membership,IntensityData,@max);
Table.IntensityMax(Wave1.Roi1,1)=Wave1.Value;
[Wave1]=accumarray_8(Membership,IntensityData,@mean);
Table.IntensityMean(Wave1.Roi1,1)=Wave1.Value;
[Wave1]=accumarray_8(Membership,IntensityData,@median);
Table.IntensityMedian(Wave1.Roi1,1)=Wave1.Value;
[Wave1]=accumarray_8(Membership,Outside,@mean);
Table.Outside(Wave1.Roi1,1)=Wave1.Value;



ex2Imaris_2(Membership,FilenameTotal,'BoutonIds');
BoutonMinRadius=zeros(Pix.','uint16');
for m=1:size(Table,1)
    BoutonMinRadius(Table.IdxList{m})=Table.MinRadius(m)*10;
end
ex2Imaris_2(BoutonMinRadius,FilenameTotal,'BoutonMinRadius');
Table(:,'IdxList') = [];
% keyboard; % remove IdxList from output

% [CumSum,Histogram,Ranges]=cumSumGenerator(Table.MinRadius,(0:0.1:2).');
% [CumSum,Histogram,Ranges]=cumSumGenerator(Table.Volume,(0:0.1:2).');


