function Out=generateSurfaceMatlab(Data3D,In)

v2struct(In);
Pix=size(Data3D).';
if exist('ErodeWindow')==1
    Data3Dout=imerode(Data3D,ErodeWindow);
else
    Data3Dout=Data3D;
end
BW=bwconncomp(Data3Dout,Connectivity(1));
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
% clear BW;
Table.Volume=Table.NumPix*prod(Res(1:3));
Table=Table(Table.Volume>ThreshVolume,:);
Table=sortrows(Table,'Volume','descend');


if exist('CenterOfMass')==1
    %     BW=bwconncomp(Data3Dout>0,Connectivity(1));
    %     Table=table;
    %     Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    %     Table.IdxList=BW.PixelIdxList.';
    %     Table.Volume=Table.NumPix*prod(Res(1:3));
    %     OrigBW=BW;
    BW.NumObjects=size(Table,1);
    BW.PixelIdxList=Table.IdxList.';
    CenterOfMass=regionprops(BW,'centroid');
    CenterOfMass=cat(1,CenterOfMass.Centroid);
    CenterOfMass=[CenterOfMass(:,2),CenterOfMass(:,1),CenterOfMass(:,3)];
    %     Table.CenterOfMass=cat(1,CenterOfMass.Centroid);
    Table.CenterOfMass=CenterOfMass.*repmat(Res.',[size(Table,1),1]);
    %     Table.CenterOfMass=Table.CenterOfMass.*-repmat(FitCoef.',[size(ListB,1),1]);
end

% for m=1:size(Table,1)
%     Table.MaxDist(m,1)=max(Distance(Table.IdxList{m}));
% end
% Table=Table(Table.MaxDist>1,:);
Data3Dout=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    %     Data3Dout(Table.IdxList{m})=Table.MaxDist(m);
    Data3Dout(Table.IdxList{m})=m;
end

if exist('ErodeWindow')==1
    Data3Dout=imdilate(Data3Dout,ErodeWindow);
    Data3Dout(Data3D==0)=0;
    %     Data3Dout=Data3D.*logical(Data3Dout);
end

% if exist('CenterOfMass')==1
%     BW=bwconncomp(Data3Dout>0,Connectivity(1));
%     Table=table;
%     Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
%     Table.IdxList=BW.PixelIdxList.';
%     Table.Volume=Table.NumPix*prod(Res(1:3));
%     CenterOfMass=regionprops(BW,'centroid');
%     Table.CenterOfMass=cat(1,CenterOfMass.Centroid);
%
%     Table.CenterOfMass=Table.CenterOfMass.*repmat(Res.',[size(Table,1),1]);
% %     Table.CenterOfMass=Table.CenterOfMass.*-repmat(FitCoef.',[size(ListB,1),1]);
% end

Table(:,'IdxList')=[];

Out=struct;
Out.Data3D=Data3Dout;
Out.Table=Table;