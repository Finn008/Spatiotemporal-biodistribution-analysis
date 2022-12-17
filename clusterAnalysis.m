function [MapVolume,MapDistInMax,MapIds]=clusterAnalysis(Mask,Res,RemoveIslandsThreshold,WatershedThreshold)

if exist('RemoveIslandsThreshold')==1 && isempty(RemoveIslandsThreshold)==0
    [Mask]=removeIslands_3(Mask,4,RemoveIslandsThreshold,prod(Res(:)));
end
    

J=struct;
J.InCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,Mask);
Distance=Out.DistInOut; clear Out;
clear Mask;

if exist('WatershedThreshold')~=1 || isempty(WatershedThreshold)
    WatershedThreshold=max(Distance(:));
end
Watershed=uint8(WatershedThreshold)-Distance; % previously 4
Watershed=single(watershed(Watershed,26));
Watershed(Distance==0)=0;

BW=bwconncomp(logical(Watershed),6);
clear Watershed;
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3));

MapIds=labelmatrix(BW);

keyboard; % check if accumarray_8 provides same results as accumarray_2
Wave1=accumarray_8(MapIds,Distance,@max);
Table.DistInMax(Wave1.Roi1,1)=Wave1.Value(Wave1.Roi1)/10;

Wave1=uint16(Table.DistInMax*10);
Wave1=Wave1(MapIds(MapIds>0));
MapDistInMax=MapIds;
MapDistInMax(MapIds>0)=Wave1; MapDistInMax=uint16(MapDistInMax);

Wave1=uint16(Table.Volume*10);
Wave1=Wave1(MapIds(MapIds>0));
MapVolume=MapIds;
MapVolume(MapIds>0)=Wave1; MapVolume=uint16(MapVolume);