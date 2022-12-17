function [Boutons,Table]=synaptosomes_spotDetection(Data3D,Res,VolumeThreshold)

Pix=size(Data3D).';
Threshold=prctile(Data3D(:),80);

Boutons=Data3D>Threshold;
Boutons=removeIslands_3(Boutons,4,[0;0.005],prod(Res(:)));
Boutons=imerode(Boutons,ones(3,3));

% first make 3D
BW=bwconncomp(Boutons,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';

Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>VolumeThreshold,:);
clear BW;

Boutons=zeros(Pix.','uint16');
Boutons(cell2mat(Table.IdxList))=1;

% % % % Boutons=imdilate(Boutons,ones(3,3));
% % % % Wave1=VglutGreen>Threshold;
% % % % Boutons(Wave1==0)=0;

BoutonSeparation='MorphologyBased';
if strcmp(BoutonSeparation,'MorphologyBased')
    [Boutons]=removeIslands_3(Boutons,4,[0;0.008],prod(Res(:)));
    J=struct;
    J.OutCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Res=Res;
    J.UmBin=0.1;
    [Out]=distanceMat_2(J,1-Boutons);
    Distance=Out.DistInOut; clear Out;
    clear Mask;
    
    Watershed=uint8(max(Distance(:)))-Distance; % previously 4
    Watershed=single(watershed(Watershed,26));
    Watershed(Distance==0)=0;
    
elseif strcmp(BoutonSeparation,'IntensityBased')
    Window=[5,5,3];
    VglutGreenSmooth=smooth3(Data3D,'box',Window);
    VglutGreenSmooth(Boutons==0)=0;
    
    Watershed=watershed(max(VglutGreenSmooth(:))-VglutGreenSmooth,6);
    Watershed(Boutons==0)=0;
end
BW=bwconncomp(Watershed,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>0.15,:);

Boutons=zeros(Pix.','uint16');
for Bouton=1:size(Table,1)
    Boutons(Table.IdxList{Bouton})=Bouton;
end