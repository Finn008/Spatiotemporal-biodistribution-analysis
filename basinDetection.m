function [Mask,Distance,BasinMap,Table,Basins]=basinDetection(Mask,Outside,Res,Settings)
Pix=size(Mask).';
if isfield(Settings,'ResCalc')==0; Settings.ResCalc=0.2; end;
if isfield(Settings,'BasinThreshold')==0; Settings.BasinThreshold=40; end;
if isfield(Settings,'DistanceRes')==0; Settings.DistanceRes=0.1; end;
if isfield(Settings,'Border2void') && Settings.Border2void==1
    PixelAdd=ceil(Settings.BasinThreshold./Res);
    Wave1=false(Pix.'+PixelAdd.'*2);
    Wave1(PixelAdd(1)+1:PixelAdd(1)+Pix(1) , PixelAdd(2)+1:PixelAdd(2)+Pix(2) , PixelAdd(3)+1:PixelAdd(3)+Pix(3))=Mask;
    Mask=Wave1;
end

[Distance]=distanceMat_4(Mask,{'DistInOut'},Res,Settings.DistanceRes,1,0,0,'uint16',Settings.ResCalc);
timeTable('basinDetection_Distance');
if isempty(Outside)
    Outside=zeros(size(Mask),'uint8');
end
Distance(Outside==1)=0;
% Settings.BasinThreshold=40;
Basins=uint16(watershed(Settings.BasinThreshold-uint8(Distance),6));
% if isempty(Outside)
%     Basins(Mask==1)=0;
% else
Basins(Mask==1 | Outside==1)=0;
% end
BW=bwconncomp(logical(Basins),6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
% Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3));

Basins=labelmatrix(BW);

Wave1=accumarray_9(Basins,Distance,@max,[],[],[],{1,0});
Table.DistanceMax(Wave1.Roi1,1)=Wave1.Value1;

Wave1=accumarray_9(Basins,Distance,@mean,[],[],[],{1,0});
Table.DistanceMean(Wave1.Roi1,1)=Wave1.Value1;

TableSelection=Table(Table.DistanceMean<=Settings.ThresholdDistanceMean,:);

Mask(cell2mat(TableSelection.IdxList))=1;
Mask=imdilate(Mask,strel('sphere',3));
Mask=imerode(Mask,strel('sphere',3));
[Mask]=removeIslands_4(Mask,6,[0;1],Res);
if isfield(Settings,'ShowBasinMap')
%     Basins=labelmatrix(BW);
    if size(Settings.ShowBasinMap,2)>1; Settings.ShowBasinMap={Settings.ShowBasinMap}; end;
    for m=1:size(Settings.ShowBasinMap,1)
%         Wave1=uint16(ceil(Table.DistanceMax));
        Wave1=uint16(ceil(Table{:,Settings.ShowBasinMap{m}}));
        Wave1=Wave1(Basins(Basins>0));
        Wave2=Basins;
        Wave2(Basins>0)=Wave1;
        if size(Settings.ShowBasinMap,1)==1
            BasinMap=Wave2;
        else
            BasinMap(m,1)={Wave2};
        end
%         ex2Imaris_2(BasinMap,Application,'Microglia_DistanceMean');
    end
    
%     ex2Imaris_2(interpolate3D(Wave2,Res,Res2),FilenameTotalCrude,'Nuclei_Basins_DistanceMax');
    BasinMap=uint16(BasinMap);
end

if isfield(Settings,'Border2void') && Settings.Border2void==1
    Mask=Mask(PixelAdd(1)+1:PixelAdd(1)+Pix(1) , PixelAdd(2)+1:PixelAdd(2)+Pix(2) , PixelAdd(3)+1:PixelAdd(3)+Pix(3));
    Distance=Distance(PixelAdd(1)+1:PixelAdd(1)+Pix(1) , PixelAdd(2)+1:PixelAdd(2)+Pix(2) , PixelAdd(3)+1:PixelAdd(3)+Pix(3));
    BasinMap=BasinMap(PixelAdd(1)+1:PixelAdd(1)+Pix(1) , PixelAdd(2)+1:PixelAdd(2)+Pix(2) , PixelAdd(3)+1:PixelAdd(3)+Pix(3));
    Basins=Basins(PixelAdd(1)+1:PixelAdd(1)+Pix(1) , PixelAdd(2)+1:PixelAdd(2)+Pix(2) , PixelAdd(3)+1:PixelAdd(3)+Pix(3));
end
