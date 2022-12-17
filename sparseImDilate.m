function [Data3D]=sparseImDilate(LinInd,DiaUm,Pix,Res)
Table=table;
Table.LinInd=LinInd;
Table.DiaUm=DiaUm;

Data3D=zeros(Pix.','uint16');

Kernels=table;
Kernels.DiaUm=unique(Table.DiaUm);
for Dia=1:size(Kernels,1)
    [Kernels.Shape{Dia,1},Kernels.Pix(Dia,1:3)]=imdilateWindow_2(repmat(Kernels.DiaUm(Dia),[3,1]),Res,1,'ellipsoid');
    KernelPix=Kernels.Pix(Dia,1:3).';
    Wave2=repmat((1:KernelPix(1)).',[1,KernelPix(2),KernelPix(3)]);
    Wave2=Wave2+repmat((0:Pix(1):(KernelPix(2)-1)*Pix(1)),[KernelPix(1),1,KernelPix(3)]);
    Wave2=Wave2+repmat(permute((0:prod(Pix(1:2)):(KernelPix(3)-1)*prod(Pix(1:2))).',[3,2,1]),[KernelPix(1),KernelPix(2),1]);
    % center on pixel(1,1,1)
    Wave2=Wave2-floor(KernelPix(1)/2)-floor(KernelPix(2)/2)*Pix(1)-floor(KernelPix(3)/2)*Pix(1)*Pix(2);
    Kernels.PixelIdxList{Dia,1}=Wave2(Kernels.Shape{Dia,1});
    
    Ind=find(Table.DiaUm==Kernels.DiaUm(Dia));
    for Seed=1:size(Ind,1)
        Wave1=Table.LinInd(Ind(Seed))+Kernels.PixelIdxList{Dia,1}-1;
        Wave1(Wave1<1 | Wave1>prod(Pix))=[];
        Data3D(Wave1)=1; % Ind(Seed);
%         WatershedDistance(Wave1)=0;
    end
end