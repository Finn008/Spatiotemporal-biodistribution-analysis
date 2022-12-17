function [XYZRange,ChunkSize]=gridding3D(Pix,Res,ChunkSize)
% Pix=size(Data3D).';
Um=Pix.*Res(1:size(Pix,1));
Dimensions=size(ChunkSize,1);

for m=1:Dimensions
    ChunkNumber(m,1)=round(Um(m)/ChunkSize(m));
    Range=round(linspace(1,Pix(m)+1,ChunkNumber(m)).');
    Range(1:end-1,2)=Range(2:end,1)-1;
    Range(end,:)=[];
    XYZRange(m,1)={Range};
end
ChunkSize=Um(1:Dimensions)./ChunkNumber;