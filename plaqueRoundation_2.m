function PlaqueMask2=plaqueRoundation_2(PlaqueMask,PixCenter,CutStart,Res,Radius,PlaqueChPl)

OrigPlaqueMask=PlaqueMask;
PixMask=[size(PlaqueMask,1);size(PlaqueMask,2);size(PlaqueMask,3)];
PixCenterMask=PixCenter-CutStart;

% % % % Wave1=OrigPlaqueMask(:,:,PixCenterMask(3)); Wave1=sum(Wave1(:))*prod(Res(1:2));
% % % % Radius=(Wave1/pi)^0.5;

CentralBand=[PixCenterMask(3)-floor(2.5/Res(3));PixCenterMask(3)+ceil(2.5/Res(3))];
CentralBand(CentralBand<1)=1;
CentralBand(CentralBand>PixMask(3))=PixMask(3);
XYmaxProjection=max(PlaqueMask(:,:,CentralBand(1):CentralBand(2)),[],3);
XYmaxProjection=imdilate(XYmaxProjection,ones(ceil(3/Res(1))));

PlaqueChPl=PlaqueChPl.*repmat(XYmaxProjection,[1,1,PixMask(3)]).*PlaqueMask;

Table=table;
Table.Zpix=(1:PixMask(3)).';
Table.Distance=abs(PixCenter(3)-CutStart(3)-Table.Zpix)*Res(3);
Wave1=Radius-Table.Distance;
Table.Radius(Wave1>0,1)=(Radius.^2-Table.Distance(Wave1>0).^2).^0.5;
Table.AllowedPixel=floor(pi*Table.Radius.^2/prod(Res(1:2)));

for m=1:size(Table,1)
    if Table.AllowedPixel(m)==0
        PlaqueMask(:,:,m)=0;
        continue;
    end
    Slice=PlaqueChPl(:,:,m);
    Wave1=table;
    Wave1.Idx=find(PlaqueMask(:,:,m)==1);
    Wave1.Intensity=Slice(Wave1.Idx);
    Wave1=sortrows(Wave1,'Intensity','descend');
    Slice(:)=0;
    Slice(Wave1.Idx(1:min([Table.AllowedPixel(m);size(Wave1,1)])))=1;
    PlaqueMask(:,:,m)=Slice;
end

PlaqueMask2=imclearborder(1-PlaqueMask,18);
PlaqueMask2=PlaqueMask+PlaqueMask2;


return;
global Application;
ex2Imaris_2(PlaqueMask2,Application,'Test');



for m=1:size(PlaqueMask,3)
    Distance=abs(PixCenter(3)-CutStart(3)-m+1)*Res(3);
    if Distance<=Radius
        RadiusM=(Radius^2-Distance^2)^0.5;
    else
        PlaqueMask(:,:,m)=0;
        continue; % RadiusM=0;
    end
    Area=pi*RadiusM^2;
    AreaPix=round(Area/prod(Res(1:2)));
    Slice=PlaqueChPl(:,:,m);
    %                 Slice=uint8(PlaqueMask(:,:,m)).*PlaqueChPl(:,:,m);
    PixRemove=prod(PixMask(1:2))-AreaPix;
    if PixRemove>0
        [~,Wave1]=sort(Slice(:));
        Slice(Wave1(1:PixRemove).')=0;
        PlaqueMask(:,:,m)=uint8(logical(Slice));
    end
end

% remove islands
PlaqueMask2=imclearborder(1-PlaqueMask,18);
PlaqueMask2=PlaqueMask+PlaqueMask2;

if sum(PlaqueMask2(:))>sum(PlaqueMask(:))*1.1
    keyboard;
end

