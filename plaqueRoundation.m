function PlaqueMask2=plaqueRoundation(PlaqueMask,PixCenter,CutStart,Res,Radius,PlaqueChPl)

PixMask=[size(PlaqueMask,1);size(PlaqueMask,2);size(PlaqueMask,3)];
% PixCenterMask=PixCenter(3)-CutStart(3);
PixCenterMask=PixCenter-CutStart;

CentralBand=[PixCenterMask(3)-floor(2.5/Res(3));PixCenterMask(3)+ceil(2.5/Res(3))];
CentralBand(CentralBand<1)=1;
CentralBand(CentralBand>PixMask(3))=PixMask(3);
XYmaxProjection=max(PlaqueMask(:,:,CentralBand(1):CentralBand(2)),[],3);
XYmaxProjection=imdilate(XYmaxProjection,ones(ceil(3/Res(1))));

% A1=sum(PlaqueMask(:));
PlaqueChPl=PlaqueChPl.*repmat(XYmaxProjection,[1,1,PixMask(3)]).*PlaqueMask;
% A2=A1-sum(PlaqueMask(:));

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

