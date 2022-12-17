% VglutGreen: 3D-image of VGLUT1-Venus fluorescence intensity after deconvolution and background correction
% Exclude: 3D-Mask specifying parts located outside brain
% Res: Resolution of all three dimensions
% VglutRed: 3D-image of autofluorescence after deconvolution and background correction

function [BoutonList,BoutonIds,Dystrophies2,Dystrophies2Radius,VglutGreen,GRratio]=VglutVenusSegmentation(VglutGreen,Exclude,Res,VglutRed)

Pix=size(VglutGreen).'; % Determine pixel dimension of 3D-image
Um=Pix.*Res; % Determine size in µm of 3D-image

[Threshold]=prctile_2(VglutGreen,75,Exclude==0); % Calculate 75th percentile as threshold for selecting VGLUT1-Venus positive part of 3D-image
clear Exclude;
Mask=VglutGreen>Threshold;

[Mask]=removeIslands_3(Mask,4,[0;0.025],prod(Res(:))); % Excluded voxels that are entirely enclosed by included voxels are detected and included to account for noise
Distance=distanceMat_4(logical(1-Mask),'DistInOut',Res,0.1,1,0,0); % Apply 3D distance transformation to calculate the distance of each voxel to the outer surface of the VGLUT-Venus positive mask
clear Mask;

Watershed=uint8(10)-uint8(Distance); % Voxels that are located more than 1 µm (10 * 0.1 µm) from outer border of VGLUT1-Venus positive mask are set to maximally 1 µm. This is necessary to avoid oversegmentation
Watershed=single(watershed(Watershed,26)); % 3D segmentation of VGLUT1-Venus positive mask. The algoryhtm separates clusters of contiguous voxels along the ridge lines obtained from 3D distance transformation
Watershed(Distance==0)=0;

BW=bwconncomp(logical(Watershed),6); % Detect connected components (clusters)
clear Watershed;
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3)); % calculate Volume in µm^3 of each cluster
Wave1=struct2table(regionprops(BW,'Centroid'));
Table.Centroid=Wave1.Centroid; % calculate center of mass of each cluster
Table.Centroid(:,1:3)=Table.Centroid(:,[2,1,3]);
Table.XYZum(:,1:3)=Table.Centroid.*repmat(Res.',[size(Table,1),1]);
Table.XYZum=Table.XYZum-repmat(Um.'/2,[size(Table,1),1]);

BoutonIds=labelmatrix(BW); % generate 3D image mask assigning each voxel the ID of the cluster that it belongs to
clear BW;

% Calculate maximal area in XY. Due to the strong spherical aberation of two-photon microscopy small VGLUT1-Venus positive structures (synapses) appear as elongated ellipses with roughly 3 times the diameter in axial as compared to lateral direction. Therefore maximal area in XY is used to obtain radius of each cluster
Wave1=accumarray_8({BoutonIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXY=max(double(Wave1),[],2)*prod(Res(1:2));
Wave1=accumarray_8(BoutonIds,Distance,@max);
Table.DistInMax(Wave1.Roi1,1)=double(Wave1.Value)/10;

% Generate 3D-image in which each voxel is assigned the minimal radius of the cluster that it belongs to. The minimal radius is the minimal distance value obtained after 3D distance transformation.
Wave1=uint16(Table.DistInMax*10);
Wave1=Wave1(BoutonIds(BoutonIds>0));
Dystrophies2Radius=BoutonIds;
Dystrophies2Radius(BoutonIds>0)=Wave1; Dystrophies2Radius=uint16(Dystrophies2Radius);

% Equivalent to the previous definition of "Dystrophies2Radius" another 3D-image is generated in which each voxels is assigned the maximal volume of the cluster that it belongs to
Wave1=uint16(ceil(Table.Volume));
Wave1=Wave1(BoutonIds(BoutonIds>0));
Dystrophies2=BoutonIds;
Dystrophies2(BoutonIds>0)=Wave1; Dystrophies2=uint16(Dystrophies2);

% Determine the maximum VGLUT1-Venus intensity value of each cluster
Wave1=accumarray_8(BoutonIds,VglutGreen,@max);
Table.VglutGreenMax(Wave1.Roi1,1)=Wave1.Value;
Table.VglutGreenHWI=uint16(Table.VglutGreenMax/2);

% Use the half-width intensity of each individual cluster to narrow down the size of each cluster
Wave1=Table.VglutGreenHWI(BoutonIds(BoutonIds>0));
VglutGreenHWIbackground=BoutonIds;
VglutGreenHWIbackground(BoutonIds>0)=Wave1; VglutGreenHWIbackground=uint16(VglutGreenHWIbackground);
VglutGreenHWIbackground=VglutGreen<VglutGreenHWIbackground;
BoutonIds(VglutGreenHWIbackground==1)=0;
clear VglutGreenHWIbackground;

% After applying half-width intensity to norrow down the total size of VGLUT1-Venus positive clusters obtain the radius of each cluster from maximal area in lateral directions.
Wave1=accumarray_8({BoutonIds;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXYHWI=max(double(Wave1),[],2)*prod(Res(1:2));

% Calculate the minimum value of 3D distance transformation for each cluster
Wave1=accumarray_8(BoutonIds,Distance,@min);
clear Distance;
Table.DistInMin(Wave1.Roi1,1)=double(Wave1.Value)/10;
Table.DistInDiff=Table.DistInMax-Table.DistInMin;

% Determine the volume of each VGLUT1-Venus positive cluster after applying half-width intensity as limiting criterium.
Wave1=accumarray_8(BoutonIds,ones(Pix.','uint8'),@sum);
Table.VolumeHWI(Wave1.Roi1,1)=double(Wave1.Value)*prod(Res(:));

% For each cluster calculate the mean intensity of VGLUT1-Venus, autofluorescence and the ratio between both (GRratio).
GRratio=uint16(single(VglutGreen)./single(VglutRed)*2000);
IntensityData={'VglutGreen',VglutGreen;'VglutRed',VglutRed;'GRratio',GRratio};
clear VglutRed;
for m=1:size(IntensityData,1)
    Wave1=accumarray_8(BoutonIds,IntensityData{m,2},@mean);
    Table{Wave1.Roi1,[IntensityData{m,1},'Mean']}=Wave1.Value;
end
clear IntensityData;
% Obtain relevant information on VGLUT1-Venus positive clusters as table.
BoutonList=Table(:,{'ID','XYZum','AreaXY','AreaXYHWI','Volume','VolumeHWI','DistInMin','DistInMax','DistInDiff','VglutGreenMax','VglutGreenHWI','VglutGreenMean','VglutRedMean','GRratioMean','Centroid','NumPix'});

% Generate a 3D-image in which each Cluster-ID is assigned a random value between 2 and 256. This allows for visual quality control when monitoring the data in Imaris.
Wave1=find(BoutonIds==0);
BoutonIds=(double(BoutonIds)-floor(double(BoutonIds)/256)*256);
BoutonIds(Wave1)=0;

%% subfunction
% Calculates the percentile for a 3D-image.
% Inside: If necessary a 3D mask of type logical  can be used to limit the calculation to all voxels ascribed the value 1.
function [Result]=prctile_2(Data,Percentiles,Inside)
Data=Data(:);
if exist('Inside')==1
    Inside=Inside(:);
    Data=Data(Inside==1,:);
end
Data=sort(Data);

Ind=round(size(Data,1)*Percentiles/100);
Ind(Ind==0)=1;
if isempty(Data)
    Result=nan(size(Percentiles,1),1);
else
    Result=Data(Ind);
end


%% subfunction
% In a 3D-mask of type logical "Islands" are identified. These are clusters of voxels with value 0 that are entirely enclosed by voxels of value 1.
% MinMaxVolume: can be applied to limit the allowed volume of detected "Islands"
% In the output "Data3D" all detected Islands are set to value 1.
function [Data3D,Islands]=removeIslands_3(Data3D,Connectivity,MinMaxVolume,Res3D)
Pix=size(Data3D).';
BW=bwconncomp(1-Data3D,Connectivity);

Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*Res3D;
Wave1=struct2table(regionprops(BW,'BoundingBox'));
Table.BoundingBox(:,1:6)=Wave1.BoundingBox;
clear BW;
if exist('MinMaxVolume')==1
    Table=Table(Table.Volume>=MinMaxVolume(1) & Table.Volume<MinMaxVolume(2),:);
end
Table.BoundingBox(:,1:3)=Table.BoundingBox(:,1:3)+0.5;
Table.BoundingBox(:,4:6)=Table.BoundingBox(:,1:3)+Table.BoundingBox(:,4:6)-1;
Wave1=[1,1,1,Pix.'];
Table.BoundingBox=Table.BoundingBox-repmat(Wave1,[size(Table,1),1]);
if Connectivity==4
    Table.BorderTouch=min(abs(Table.BoundingBox(:,[1,2,4,5])),[],2)==0;
else
    Table.BorderTouch=min(abs(Table.BoundingBox),[],2)==0;
end
Table=Table(Table.BorderTouch==0,:);
Islands=zeros(size(Data3D),'uint8');
Islands(cell2mat(Table.IdxList))=1;
Data3D(Islands==1)=1;

%% subfunction
% Calculates 3D distance transformation with anisotropic resolution
function [DistInOut,Membership,Dist2Border]=distanceMat_4(Data3D,Output,Res,UmBin,OutCalc,InCalc,ZeroBin,DistanceBitType)

if exist('ZeroBin','var')==0
    ZeroBin=50;
end
if exist('DistanceBitType','var')==0
    DistanceBitType='uint8';
end
if exist('OutCalc')~=1
    OutCalc=0;
end
if exist('InCalc')~=1
    InCalc=0;
end
if exist('Output')~=1
    Output={'DistInOut';'Membership';'Dist2Border';};
end
if ischar(Output)
    Output={Output};
end

if exist('UmBin')~=1 || isempty(UmBin)
    UmBin=1;
end
Pix=[size(Data3D,1);size(Data3D,2);size(Data3D,3)];
if exist('Res')~=1
    Res=Um./Pix;
end
if exist('ResCalc')~=1
    ResCalc=min(Res(:));
end
PixCalc=round(Pix.*Res/ResCalc);

Xi=round(linspace(1,Pix(1),PixCalc(1)));
Yi=round(linspace(1,Pix(2),PixCalc(2)));
Zi=round(linspace(1,Pix(3),PixCalc(3)));
Xt=round(linspace(1,PixCalc(1),Pix(1)));
Yt=round(linspace(1,PixCalc(2),Pix(2)));
Zt=round(linspace(1,PixCalc(3),Pix(3)));

Dist2Border=[];
DistInOut=[];
Membership=[];

if strfind1(Output,'Membership',1)
end

cprintf('text','DistanceTransform: ');
Data3D=Data3D(Xi,Yi,Zi);
if OutCalc==1
    if strfind1(Output,'DistInOut',1) && strfind1(Output,'Membership',1)
        [DistInOut,Membership]=bwdist(Data3D,'quasi-euclidean');
    elseif strfind1(Output,'DistInOut',1)
        [DistInOut]=bwdist(Data3D,'quasi-euclidean');
    elseif strfind1(Output,'Membership',1)
        [Membership]=bwdist(Data3D,'quasi-euclidean');
    end
    if strfind1(Output,'DistInOut',1)
        DistInOut=cast(ceil(DistInOut(Xt,Yt,Zt)*ResCalc/UmBin),DistanceBitType); % convert pixel based distance into µm based distance
    end
    if strfind1(Output,'Membership',1)
        Membership(:)=Data3D(Membership(:));
        Membership=cast(Membership(Xt,Yt,Zt),DistanceBitType);
    end
end
if InCalc==1 && strfind1(Output,'DistInOut',1) % inside
    Data3D=logical(Data3D)==0; % invert so that everything outside plaque is set to 1
    [DistIn]=bwdist(Data3D,'quasi-euclidean'); % make distance transform for inside and store in Stack
    DistIn=cast(ceil(DistIn(Xt,Yt,Zt)*ResCalc/UmBin),DistanceBitType);
end
clear Data3D;
if strfind1(Output,'DistInOut',1)
    if OutCalc==1 && InCalc==1
        DistInOut=DistInOut+ZeroBin-(DistIn-UmBin);
    elseif OutCalc==1 && InCalc==0
        DistInOut=DistInOut+ZeroBin;
    elseif OutCalc==0 && InCalc==1
        DistInOut=DistIn+ZeroBin;
    end
    clear DistIn;
end
if strfind1(Output,'Dist2Border')
    Dist2Border=zeros(PixCalc(1),PixCalc(2),PixCalc(3),DistanceBitType);
    Dist2Border(1,:,:)=1; Dist2Border(end,:,:)=1; Dist2Border(:,1,:)=1; Dist2Border(:,end,:)=1; Dist2Border(:,:,1)=1; Dist2Border(:,:,end)=1;
    Dist2Border=bwdist(Dist2Border,'quasi-euclidean'); % make distance transform for inside and store in Stack
    Dist2Border=(cast((Dist2Border-1)*ResCalc/UmBin,DistanceBitType));
    Dist2Border=Dist2Border(Xt,Yt,Zt,:);
end
cprintf('text','\n');

%% subfunction
% Calculates the function specified in "Function" for all individual rois specified in "Rois"
function [Output]=accumarray_8(Rois,Data,Function,OutputFormat,AccumMethod,CountInstances)

if exist('OutputFormat')~=1
    OutputFormat='Table';
end

if istable(Rois)
    Wave1=table;
    for m=1:size(Rois,2)
        Wave1.Data(m,1)={Rois{:,m}};
    end
    Wave1.Name=Rois.Properties.VariableNames.';
    Rois=Wave1;
    clear Wave1;
elseif isnumeric(Rois)
    Wave1=table;
    Wave1.Data(1)={Rois};
    Wave1.Name(1)={'Roi1'};
    Rois=Wave1;
    clear Wave1;
elseif iscell(Rois)
    Rois=array2table(Rois,'VariableNames',{'Data';'Name'});
end
RoiNumber=size(Rois,1);

for Row=1:size(Rois,1)
    [Rois.Unique{Row},~,Rois.Data{Row}]=unique(Rois.Data{Row});
    Max=max(Rois.Data{Row});
    if Max<=255
        Rois.Data{Row}=uint8(Rois.Data{Row});
    elseif Max<=65535
        Rois.Data{Row}=uint16(Rois.Data{Row});
    elseif Max<=2^32-1
        Rois.Data{Row}=uint32(Rois.Data{Row});
    else
        keyboard;
    end
    Rois.Digits(Row,1)=size(num2str(round(Max)),2);
end

TotalDigits=sum(Rois.Digits);
Pix=size(Rois.Data{1,1}).';
Roi=zeros(Pix.','uint64');

for Row=1:size(Rois,1)
    Roi=Roi+uint64(Rois.Data{Row,1})*10^sum(Rois.Digits(Row+1:end)); % donot use double, otherwise weird summation problems!!!, rather try uint64
end

if max(Roi(:))==uint64(2^64); keyboard; end;
SparseRoi=Roi;
[UniqueRoi,~,Roi]=unique(Roi);
Rois(:,'Data') = [];
if isempty(Data)
    Data=[]; % in case an empty table is transferred
    Data=[{ones(Pix.','uint8'),'Count'};Data];
elseif isnumeric(Data)
    Data={Data};
elseif istable(Data)
    clear Wave1;
    if exist('CountInstances')==1 && strcmp(CountInstances,'CountInstances')
        Data.CountInstances(:,1)=1;
    end
    for m=1:size(Data,2)
        Wave1(m,1)={Data{:,m}};
    end
    Wave1(:,2)=Data.Properties.VariableNames.';
    Data=Wave1;
    clear Wave1;
end

if size(Data,2)==1
    Data(:,2)=strcat('Value',num2strArray_3((1:size(Data,1).')));
end

Data=array2table(Data,'VariableNames',{'Data';'Name'});

if exist('AccumMethod')~=1
    AccumMethod='NonSparse';
end
Output=table;
for Row=1:size(Data,1)
    if strcmp(Data.Name{Row,1},'CountInstances')
        Function=@nansum; % donot set back because is anyways the last Dataset
    end
    
    if strcmp(AccumMethod,'Sparse')
        keyboard; % attention! zero values in AccumArray are excluded!!!!
        AccumArray=accumarray(double(Roi(:)),full(double(Data.Data{Row,1}(:))),[],Function,[],true);
        Ind=find(AccumArray);
    elseif strcmp(AccumMethod,'NonSparse')
        AccumArray=accumarray(double(Roi(:)),full(double(Data.Data{Row,1}(:))),[],Function);
        Ind=(1:size(AccumArray,1)).';
    end
    if Row==1
        Output.LinRoi=Ind;
        Output{:,Data.Name{Row}}=AccumArray(Ind);
    else
        [~,Wave1]=ismember(Ind,Output.LinRoi);
        ZeroInd=find(Wave1==0);
        Wave1(ZeroInd)=(size(Output,1)+1:1:size(Output,1)+size(ZeroInd,1));
        Output.LinRoi(Wave1,1)=Ind;
        Output{Wave1,Data.Name{Row}}=AccumArray(Ind);
    end
    clear AccumArray;
end

Output.LinRoi=UniqueRoi(Output.LinRoi);
for m=1:RoiNumber
    MinMax=[sum(Rois.Digits(m+1:end))+1;sum(Rois.Digits(m:end))];
    Wave1=getNthNumeric(Output.LinRoi,MinMax);
    Wave1=Rois.Unique{m}(Wave1);
    Output{:,Rois.Name{m}}=Wave1;
end
clear Roi; clear Data;

if strcmp(OutputFormat,'2D')
    keyboard;
    OrigOutput=Output;
    Output=zeros(0,0,'uint32');
    for m=1:max(OrigOutput.Roi2)
        Ind=find(OrigOutput.Roi2==m);
        Output(OrigOutput.Roi1(Ind),m)=OrigOutput.Value(Ind);
    end
end
Output(:,'LinRoi')=[];
