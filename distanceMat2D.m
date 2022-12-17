function [Distance]=distanceMat2D(Data3D,Res)


for m=1:size(Data3D,3)
    Distance(:,:,m)=uint16(bwdist(Data3D(:,:,m),'quasi-euclidean'));
end

if exist('Res')
    Distance=Distance.*Res;
end