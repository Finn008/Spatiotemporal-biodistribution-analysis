function Table=sparseDistanceCorrelation_2(LinInd,Data3D,Res,ResCalc,MaxDistanceUm)
PixOrig=size(Data3D).';
% exclude that summits in WatershedData have equal height
% % Data3D=double(Data3D);
% % Data3D(:)=Data3D(:)+linspace(0,0.01,prod(PixOrig)).';
   

Table=table;
Table.LinInd=LinInd;
[Table.PixXYZ(:,1),Table.PixXYZ(:,2),Table.PixXYZ(:,3)]=ind2sub(PixOrig,Table.LinInd);
if size(ResCalc,1)==1
    ResCalc=repmat(ResCalc,[3,1]);
end
InterpolationFactor=ResCalc./Res;
Table.PixXYZ=round(Table.PixXYZ./repmat(InterpolationFactor.',[size(Table,1),1]));
Table.PixXYZ(Table.PixXYZ==0)=1;

if isequal(Res,ResCalc)==0
    Data3D=interpolate3D_2(Data3D,Res,ResCalc,[],@max);
end


Pix=size(Data3D).';
Table.LinInd=sub2ind(Pix,Table.PixXYZ(:,1),Table.PixXYZ(:,2),Table.PixXYZ(:,3));
% Mask=zeros(Pix.'*2,'uint16'); Mask(Pix(1),Pix(2),Pix(3))=1;
MaxDistancePix=ceil(MaxDistanceUm./ResCalc);
% Mask=zeros(repmat((MaxDistancePix+1).'*2,[1,3]),'uint16');
Mask=zeros((MaxDistancePix).'*2+1,'uint16');
Mask(MaxDistancePix(1)+1,MaxDistancePix(2)+1,MaxDistancePix(3)+1)=1;
Mask=distanceMat_4(Mask,{'DistInOut'},ResCalc,min(ResCalc),1,0,0,'uint16');
Table.CutDataStart=Table.PixXYZ-repmat(MaxDistancePix.',[size(Table,1),1]);
Table.CutDataEnd=Table.PixXYZ+repmat(MaxDistancePix.',[size(Table,1),1]);

Table.CutStartOverhang=-double(Table.CutDataStart<=0).*(Table.CutDataStart-1);
Table.CutEndOverhang=-double(Table.CutDataEnd>repmat(Pix.',[size(Table,1),1])).*(repmat(Pix.',[size(Table,1),1])-Table.CutDataEnd);
Table.CutDataStart=Table.CutDataStart+Table.CutStartOverhang;
Table.CutDataEnd=Table.CutDataEnd-Table.CutEndOverhang;

Table.CutMaskStart=repmat(1,[size(Table,1),3])+Table.CutStartOverhang;
Table.CutMaskEnd=repmat(MaxDistancePix.'*2+1,[size(Table,1),1])-Table.CutEndOverhang;
Table.DataSize=Table.CutDataEnd-Table.CutDataStart+1;
Table.MaskSize=Table.CutMaskEnd-Table.CutMaskStart+1;

for m=1:size(Table,1)
    Data3DSel=Data3D(Table.CutDataStart(m,1):Table.CutDataEnd(m,1),Table.CutDataStart(m,2):Table.CutDataEnd(m,2),Table.CutDataStart(m,3):Table.CutDataEnd(m,3)); 
    Mask2=Mask(Table.CutMaskStart(m,1):Table.CutMaskEnd(m,1),Table.CutMaskStart(m,2):Table.CutMaskEnd(m,2),Table.CutMaskStart(m,3):Table.CutMaskEnd(m,3)); 
    Wave1=accumarray_9(Mask2,Data3DSel,@max);
    Table.Value(m,1:max(MaxDistancePix+1))=Wave1.Value1(1:max(MaxDistancePix+1)); % plus one because first value is distance 0
end
Table=Table.Value;

