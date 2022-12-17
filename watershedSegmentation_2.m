function [Nuclei,LocalMaxima,WatershedData,Seeds]=watershedSegmentation_2(Nuclei,Version,Res,WatershedData,TilingSettings)
timeTable('watershedSegmentation_Start');

if exist('TilingSettings','Var')==1 && isempty(Tiling)==0
    CalcSettings=struct('Version',Version,'WatershedData',WatershedData);
    [Wave1]=tiledProcessing_2(Nuclei,[],Res,TilingSettings,mfilename,CalcSettings);
    Nuclei=Wave1{1};
    LocalMaxima=Wave1{2};
    WatershedData=Wave1{3};
    Seeds=Wave1{4};
    clear Wave1;
    return;
end

if isfield(Version,'InitialSegmentation')==1 && Version.InitialSegmentation==1
    BW=bwconncomp(Nuclei,6);
    Nuclei=labelmatrix(BW);
    NucleiIDs=(1:BW.NumObjects).';
else
    NucleiIDs=unique(Nuclei);
    NucleiIDs(NucleiIDs==0)=[];
end

if isfield(Version,'ResCalc')==0
    Version.ResCalc=min(Res);
end
if isfield(Version,'WatershedType')~=1
    Version.WatershedType='Morphology';
end

Pix=size(Nuclei).';

if strfind1({'Morphology';'Intensity&Morphology'},Version.WatershedType,1)
    if isfield(Version,'Imdilation')==1
        Data3D=~imdilate(Nuclei,imdilateWindow(repmat(Version.Imdilation,[3,1]),Res));
    else
        Data3D=~logical(Nuclei);
    end
    if isfield(Version,'DistanceDimensionality')==0; Version.DistanceDimensionality='3D'; end;
% % %     keyboard; % tile this step or Segmentation in total
    [WatershedDistance]=distanceMat_4(Data3D,{'DistInOut'},Res,Version.WatershedUmBin,1,0,0,'uint16',Version.ResCalc,Version.DistanceDimensionality);
    timeTable('watershedSegmentation_DistanceMat');
    clear Data3D;
    if strfind1({'Morphology'},Version.WatershedType,1)
        WatershedData=WatershedDistance;
    elseif strfind1({'Intensity&Morphology'},Version.WatershedType,1)
        Wave1=uint16(WatershedDistance*(255/max(WatershedDistance(:))));
        Wave2=uint16(WatershedData*(255/max(WatershedData(:))));
        WatershedData=Wave1.*Wave2;
    end
end

LocalMaxima=uint8(imregionalmax(WatershedData,6));
LocalMaxima(Nuclei==0)=0;

BW=bwconncomp(LocalMaxima,6);
Seeds=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Seeds.Volume=Seeds.NumPix*prod(Res(1:3));
Wave1=struct2table(regionprops(BW,'Centroid'));
Wave1.Centroid(:,1:3)=Wave1.Centroid(:,[2,1,3]);
Seeds.XYZpix=round(Wave1.Centroid);
Seeds.XYZum(:,1:3)=Wave1.Centroid.*repmat(Res.',[size(Seeds,1),1]);
Seeds.Ind=sub2ind(Pix,Seeds.XYZpix(:,1),Seeds.XYZpix(:,2),Seeds.XYZpix(:,3));
Seeds.Membership=Nuclei(Seeds.Ind);
Seeds.WatershedData=WatershedData(Seeds.Ind);
if strfind1({'Morphology'},Version.WatershedType,1)
    Seeds.WatershedData=double(Seeds.WatershedData)*Version.WatershedUmBin;
end
Seeds=sortrows(Seeds,'WatershedData','descend');

if exist('WatershedDistance','Var')~=0 %strfind1({'Morphology';'Intensity&Morphology'},Version.WatershedType,1)
    Seeds.WatershedDistance=double(WatershedDistance(Seeds.Ind))*Version.WatershedUmBin;
    clear WatershedDistance;
end

Seeds.Remove(:,1)=0;
if strcmp(Version.Thresholds,'Plaque')
    Seeds.Remove(Seeds.WatershedDistance<=Version.Imdilation+0.8)=1; % Structure should have at least 2 µm diameter (excluding imdilation)
end

timeTable('watershedSegmentation_Seeds');

for Nucleus=NucleiIDs.'
    Seeds2=Seeds(Seeds.Membership==Nucleus,{'XYZum';'WatershedDistance';'WatershedData';'Remove'});
    Seeds2.ID=(1:size(Seeds2,1)).';
    
    for m=1:size(Seeds2,1)
        Ind=find(Seeds2.Remove==0);
        if isempty(Ind); break; end;
        Seeds2.Distance(Ind,1)=(sum((Seeds2.XYZum(Ind,:)-repmat(Seeds2.XYZum(Ind(1),:),[size(Ind,2),1])).^2,2)).^0.5;
        if strcmp(Version.SeedImpact,'Sphere')
            Ind=find(Seeds2.Remove==0 & Seeds2.Distance<Seeds2.WatershedDistance(Ind(1))+1.5);
            Seeds2.Threshold(Ind)=((Seeds2.WatershedDistance(Ind(1))+1.5).^2-Seeds2.Distance(Ind).^2).^0.5;
            Seeds2.Remove(Ind)=2;
        elseif strcmp(Version.SeedImpact,'Radius')
            Ind=find(Seeds2.Remove==0 & Seeds2.Distance<=Seeds2.WatershedDistance(Ind(1)));
            Seeds2.Remove(Ind)=2;
        end
        Seeds2.Remove(Ind(1))=255;
    end
    if strfind1(Seeds2.Properties.VariableNames.','Distance',1)~=0 % else the Nucleus has no valid Seedpoint
        VariableNames={'ID';'Remove';'Distance'}; % ;'Threshold'
        Seeds(Seeds.Membership==Nucleus,VariableNames)=Seeds2(:,VariableNames);
    end
end

%% analyse locality of each seed
if isfield(Version,'IdentifyLocalMaximaExtent')==1 && isempty(Version.IdentifyLocalMaximaExtent)~=1
    Ind=find(Seeds.Remove==255);
    Seeds2=Seeds(Ind,:);
    if Version.IdentifyLocalMaximaExtent==0 && strfind1({'Morphology';'Intensity&Morphology'},Version.WatershedType,1)
        MaxDistance=max(Seeds2.WatershedDistance);
    else
        MaxDistance=Version.IdentifyLocalMaximaExtent;
    end
    Res_SDC=Version.ResCalc;
    Seeds2.WatershedFlow=sparseDistanceCorrelation_2(Seeds2.Ind,WatershedData,Res,Res_SDC,MaxDistance);
    if strcmp(Version.WatershedType,'Morphology')
        Seeds2.WatershedFlow=Seeds2.WatershedFlow.*Version.WatershedUmBin;
    end
    
    for Seed=1:size(Seeds2,1)
        Wave1=find(Seeds2.WatershedFlow(Seed,2:end).'>Seeds2.WatershedData(Seed)+0.0001,1);% two because first distance value is zero
        if isempty(Wave1)
            Seeds2.Radius(Seed,1)=999999999999; 
        else
            Seeds2.Radius(Seed,1)=(Wave1-0.5)*Res_SDC;
        end
    end
%     WatershedData=uint16(WatershedData);
    
    timeTable('watershedSegmentation_IdentifyLocalMaximaExtent');
    % thresholds for plaque
    if strcmp(Version.Thresholds,'Plaque')
        Seeds2.Remove(Seeds2.Radius<Seeds2.WatershedDistance/2)=3; % Seedpoint should be highest within a radius of half its height
        Seeds2.Remove(Seeds2.Radius<5)=3; % Seedpoint should be the highest within 5µm
    elseif strcmp(Version.Thresholds,'Nuclei')
        Seeds2.Remove(Seeds2.Radius<Seeds2.WatershedDistance/1)=3; % Seedpoint should be highest within a radius of its height
    elseif strcmp(Version.Thresholds,'Nuclei2')
        Seeds2.Remove(Seeds2.Radius<3.5)=3; % Seedpoint should be highest within 3.5µm; Threshold max: 3.9µm
    elseif strcmp(Version.Thresholds,'Axons')
        Seeds2.Remove(Seeds2.Radius<Seeds2.WatershedDistance/1)=3; % Seedpoint should be highest within a radius of its height
    end
    Seeds.Remove(Ind,1)=Seeds2.Remove;
    Seeds.Radius(Ind,1)=Seeds2.Radius;
    Seeds.WatershedFlow(Ind,1:size(Seeds2.WatershedFlow,2))=Seeds2.WatershedFlow;
end

% an individual structure should have at least one seed point
for Nucleus=NucleiIDs.'
    if size(find(Seeds.Remove(Seeds.Membership==Nucleus)==255),1)==0
        Seeds.Remove(find(Seeds.Membership==Nucleus,1))=255;
    end
end

%%
timeTable('watershedSegmentation_SeedsSelection');

LocalMaxima(Seeds.Ind)=Seeds.Remove;

Wave1=Nuclei;
Nuclei=uint16(watershed(imimposemin(max(WatershedData(:))-WatershedData,LocalMaxima==255,6),6));
Nuclei(Wave1==0)=0;

Seeds.Membership2=Nuclei(Seeds.Ind);
Seeds=Seeds(Seeds.Remove==255,:);

Wave1=label2idx(Nuclei).';
Seeds.IdxList=Wave1(Seeds.Membership2);
Seeds.Volume=cellfun(@numel,Seeds.IdxList)*prod(Res(:));

Seeds.Diameter=(Seeds.Volume*3/4/pi).^(1/3)*2;
Seeds=sortrows(Seeds,'Membership2');
if strfind1(Seeds.Properties.VariableNames.','WatershedFlow') % put WatershedFlow column to the right
    Wave1=Seeds.WatershedFlow;
    Seeds=removevars(Seeds,'WatershedFlow');
    Seeds.WatershedFlow=Wave1;
end
timeTable('watershedSegmentation_End');