function [Table]=xyzDistanceAmorph(Data3D,Res,UmStart)
PlaqueIDs=unique(Data3D(:));
% PlaqueIDs(PlaqueIDs==0,:)=[];

Table=regionprops('table',Data3D,'centroid');
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
if exist('UmStart')==1
    Table.XYZum=Table.XYZum+repmat(UmStart.',[size(Table,1),1]);
end

for Pl=PlaqueIDs.'
    Table2=table;
    Table2.Distance=xyzDistance(Table.XYZum(Pl,:).',Table.XYZum.');
    
    PlaqueMask=uint8(PlaqueMapTotal(:,:,:,Time)==Pl);
    Table.PlaqueDistance
end