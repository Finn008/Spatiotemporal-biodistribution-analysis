function [Window,DiameterPix]=imdilateWindow_2(DiameterUm,Res,Min3Pix,Morphology)

if size(Res,1)==1
    Res=repmat(Res,[3,1]);
end

DiameterPix=double(DiameterUm)./Res(1:size(DiameterUm,1));
DiameterPix=floor(DiameterPix/2)*2+1;
if exist('Min3Pix')==0 || isempty(Min3Pix) || Min3Pix==1
    DiameterPix(DiameterPix<3)=3;
end
RadiusPix=(DiameterPix-1)/2;
if exist('Morphology','Var')==0 || isempty(Morphology)
    Window=ones(DiameterPix.');
    %     Morphology='cuboid';
elseif strcmp(Morphology,'sphere') && min(RadiusPix)==max(RadiusPix)
    Wave1=strel(Morphology,RadiusPix(1));
    Window=Wave1.Neighborhood;
elseif strcmp(Morphology,'ellipsoid')
    %Ranges
    Xbase=1:2*RadiusPix(1)+1;
    Ybase = 1:2*RadiusPix(2)+1;
    Zbase = 1:2*RadiusPix(3)+1;
    [Xm,Ym,Zm]=ndgrid(Xbase,Ybase,Zbase);
    
    %Centers
    Xc=RadiusPix(1)+1;
    Yc=RadiusPix(2)+1;
    Zc=RadiusPix(3)+1;
    Mask = ( ((Xm-Xc).^2/(RadiusPix(1).^2)) + ((Ym-Yc).^2/(RadiusPix(2).^2)) + ((Zm-Zc).^2/(RadiusPix(3).^2)) <= 1 ) ;
%     mask = ( ((xm-xc).^2/(xr.^2)) + ((ym-yc).^2/(yr.^2)) + ((zm-zc).^2/(zr.^2)) <= 1 ) ; 
    Wave1=strel('arbitrary',Mask);
    Window=Wave1.Neighborhood;
else
    keyboard;
end

