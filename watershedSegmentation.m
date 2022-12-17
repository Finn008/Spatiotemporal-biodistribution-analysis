function [Nuclei,LocalMaxima,WatershedDistance,Seeds]=watershedSegmentation(Nuclei,Version,Res,ResCalc,InitialSegmentation,Imdilation,IdentifyLocalMaximaExtent)

if exist('InitialSegmentation','Var')==1 && InitialSegmentation==1
    BW=bwconncomp(Nuclei,6);
    Nuclei=labelmatrix(BW);
    NucleiIDs=(1:BW.NumObjects).';
else
    NucleiIDs=unique(Nuclei);
    NucleiIDs(NucleiIDs==0)=[];
end

if exist('ResCalc','Var')~=1
    ResCalc=min(Res);
end
Pix=size(Nuclei).';
if exist('Imdilation','Var')==1
    Data3D=~imdilate(Nuclei,imdilateWindow(repmat(Imdilation,[3,1]),Res));
else
    Data3D=~logical(Nuclei);
end

[WatershedDistance]=distanceMat_4(Data3D,{'DistInOut'},Res,0.1,1,0,0,'uint16',ResCalc);
clear Data3D;
LocalMaxima=uint8(imregionalmax(WatershedDistance,6));
LocalMaxima(Nuclei==0)=0;

% [Window,Wave1]=imdilateWindow_2([6;6;6],repmat(ResCalc,[3,1]),1,'ellipsoid');
% Data3D=imfilter(WatershedDistance,double(Window)/sum(Window(:)));
% [LocalPerc1]=percentileFilter3D_3(WatershedDistance,90,Res,[0.5;0.5;0.5],Outside,0,[5;5;5]);
% Axons(Data3D<LocalPerc1)=0;

BW=bwconncomp(LocalMaxima,6);
Seeds=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Seeds.Volume=Seeds.NumPix*prod(Res(1:3));
Wave1=struct2table(regionprops(BW,'Centroid'));
Wave1.Centroid(:,1:3)=Wave1.Centroid(:,[2,1,3]);
Seeds.XYZpix=round(Wave1.Centroid);
Seeds.XYZum(:,1:3)=Wave1.Centroid.*repmat(Res.',[size(Seeds,1),1]);
Seeds.Ind=sub2ind(Pix,Seeds.XYZpix(:,1),Seeds.XYZpix(:,2),Seeds.XYZpix(:,3));
Seeds.Membership=Nuclei(Seeds.Ind);
Seeds.WatershedDistance=WatershedDistance(Seeds.Ind);
Seeds.WatershedDistance=single(Seeds.WatershedDistance)/10;
Seeds=sortrows(Seeds,'WatershedDistance','descend');

Seeds.Remove(:,1)=0;
% Seeds.Distance(:,1)=9999;

if exist('IdentifyLocalMaximaExtent','Var')==1 && isempty(IdentifyLocalMaximaExtent)~=1
    MaxDistance=ceil(max(Seeds.WatershedDistance));
    Seeds.WatershedFlow=sparseDistanceCorrelation(Seeds.Ind,WatershedDistance,Res,[1;1;1],MaxDistance)/10;
%     Seeds.WatershedFlow=sparseDistanceCorrelation(Seeds.Ind,WatershedDistance,Res,Res,MaxDistance)/10;
    for Seed=1:size(Seeds,1)
        Wave1=find(Seeds.WatershedFlow(Seed,2:end).'>Seeds.WatershedDistance(Seed)+0.0001,1);% two because first distance value is zero
        if isempty(Wave1)
            Wave1=MaxDistance;
        end
        Seeds.Radius(Seed,1)=Wave1-0.5; 
    end
end
% thresholds for plaque
Seeds.Remove(Seeds.Radius<Seeds.WatershedDistance/2)=1; % Seedpoint should be highest within a radius of half its size
Seeds.Remove(Seeds.Radius<5)=1; % Seedpoint should be the highest within 5µm
Seeds.Remove(Seeds.WatershedDistance<Imdilation+1)=1; % Structure should have at least 2 µm diameter (excluding imdilation)

for Nucleus=NucleiIDs.'
    Seeds2=Seeds(Seeds.Membership==Nucleus,{'XYZum';'WatershedDistance';'Remove'});
    Seeds2.ID=(1:size(Seeds2,1)).';
    
    for m=1:size(Seeds2,1)
        Ind=find(Seeds2.Remove==0);
        if isempty(Ind); break; end;
        Seeds2.Distance(Ind,1)=(sum((Seeds2.XYZum(Ind,:)-repmat(Seeds2.XYZum(Ind(1),:),[size(Ind,2),1])).^2,2)).^0.5;
        if strcmp(Version,'Sphere')
            Ind=find(Seeds2.Remove==0 & Seeds2.Distance<Seeds2.WatershedDistance(Ind(1))+1.5);
            Seeds2.Threshold(Ind)=((Seeds2.WatershedDistance(Ind(1))+1.5).^2-Seeds2.Distance(Ind).^2).^0.5;
            Seeds2.Remove(Ind)=uint16(Seeds2.Threshold(Ind)>Seeds2.WatershedDistance(Ind))*Ind(1);
        elseif strcmp(Version,'Linear')
        elseif strcmp(Version,'Radius')
            Ind=find(Seeds2.Remove==0 & Seeds2.Distance<=Seeds2.WatershedDistance(Ind(1)));
            Seeds2.Remove(Ind)=Ind(1);
        end
        Seeds2.Remove(Ind(1))=-1;
    end
    %     Nucleus
    if strfind1(Seeds2.Properties.VariableNames.','Distance',1)~=0 % else the Nucleus has no valid Seedpoint
        VariableNames={'ID';'Remove';'Distance'}; % ;'Threshold'
        Seeds(Seeds.Membership==Nucleus,VariableNames)=Seeds2(:,VariableNames);
    end
end

LocalMaxima(cell2mat(Seeds.IdxList(Seeds.Remove==-1)))=2;
Wave1=Nuclei;
% A2=max(WatershedDistance(:))-WatershedDistance;
% A1=imimposemin(max(WatershedDistance(:))-WatershedDistance,LocalMinima==2);

Nuclei=uint16(watershed(imimposemin(max(WatershedDistance(:))-WatershedDistance,LocalMaxima==2,6),6));
Nuclei(Wave1==0)=0;
