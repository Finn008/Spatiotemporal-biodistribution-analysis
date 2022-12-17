function qualityControlImage(Data3D,Mask,FilenameTotal)


MaxProjection=max(Data3D,[],3);
Wave1=double(prctile(MaxProjection(:),99.99));
MaxProjection=uint16(MaxProjection/(Wave1/65535));
Colormap=repmat(linspace(0,1,65535).',[1,3]);
Image=ind2rgb(gray2ind(MaxProjection,65535),Colormap);
% if isempty(MicrogliaSoma)
Mask2D=uint16(max(Mask,[],3));
% else
%     Microglia2D=uint16(max(MicrogliaFibers+2*uint8(MicrogliaSoma),[],3));
% end
Colormap=[0,1,1;1,0,1];
Image(find(Mask2D~=0))=Colormap(Mask2D(Mask2D~=0),1).*double(MaxProjection(Mask2D~=0))/65535;
Image(find(Mask2D~=0)+prod(size(Image(:,:,1))))=Colormap(Mask2D(Mask2D~=0),2).*double(MaxProjection(Mask2D~=0))/65535;
Image(find(Mask2D~=0)+2*prod(size(Image(:,:,1))))=Colormap(Mask2D(Mask2D~=0),3).*double(MaxProjection(Mask2D~=0))/65535;
[Path,Report]=getPathRaw([FilenameTotal,'_QualityControl_Microglia.tif']);
imwrite(Image,Path);