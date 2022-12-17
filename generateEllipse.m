function [Window]=generateEllipse(PixDiameter,Res)

if exist('Res')
    PixDiameter=PixDiameter./Res;
end

PixDiameter=floor(PixDiameter/2)*2+1; % only ungrade
PixRadius=(PixDiameter)./2;

PixRadiusMax=max(PixRadius(:));
PixDiameterMax=2*PixRadiusMax;

PixRadiusInter=double(repmat(PixRadiusMax,[3,1])./PixRadius*PixRadiusMax);

X=linspace(-PixRadiusInter(1),PixRadiusInter(1),PixDiameterMax).';
Y=linspace(-PixRadiusInter(2),PixRadiusInter(2),PixDiameterMax);
Z=zeros(1,1,PixDiameterMax);
Z(:)=linspace(-PixRadiusInter(3),PixRadiusInter(3),PixDiameterMax);

X=repmat(X,[1,PixDiameterMax,PixDiameterMax]);
Y=repmat(Y,[PixDiameterMax,1,PixDiameterMax]);
Z=repmat(Z,[PixDiameterMax,PixDiameterMax,1]);

Window=sqrt(X.^2+Y.^2+Z.^2);
Window=Window<=PixRadiusMax;
Cut=[repmat(PixRadiusMax,[3,1])-PixRadius+1];
Cut(:,2)=repmat(PixDiameterMax,[3,1])-Cut(:,1)+1;
Window=Window(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));