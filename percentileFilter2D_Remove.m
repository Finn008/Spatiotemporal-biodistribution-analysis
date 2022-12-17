function [DataPerc]=percentileFilter2D(Data,Percentile,Window,Res,ResCalc,Outside)
tic;
Pix=size(Data).'; if size(Pix,1)==2; Pix(3)=1; end;
Data=interpolate3D(Data,Res,ResCalc);
if exist('Outside')==1
    Data(Data==0)=1; % to make space for min and max value
    Data(Data==65535)=65534;
    Min=0; % Min=min(Data(:));
    Max=65535; % Max=max(Data(:));
    Outside=uint8(interpolate3D(Outside,Res,ResCalc));
    Outside2Ind=find(Outside==1);
    Data(Outside2Ind(1:2:size(Outside2Ind,1)))=Min; % distribute Min and Max values equally over all Outside voxels
    Data(Outside2Ind(2:2:size(Outside2Ind,1)))=Max;
    clear Outside2Ind;
    DataPerc=medfilt3(Data,[Window;1]); % calculate median
    Outside(DataPerc==Min | DataPerc==Max)=2; % determine all Outside voxels that lack enough Inside voxels to calculate the median
    for Z=1:Pix(3) % for all Outside-NaN voxels use the value of the closest voxel
        Wave1=1-logical(Outside(:,:,Z));
        if max(Wave1(:))==0 % if no voxel is present in this layer then use voxel of next or previous layer
            Wave1=reshape(uint32(1:prod(size(Wave1))),[size(Wave1,1),size(Wave1,2)]);
            Z=Z+1;
            
        else
            [~,Wave1]=bwdist(Wave1,'quasi-euclidean');
        end
        Membership(:,:,Z)=Wave1+prod(size(Wave1))*(Z-1);
    end
    DataPerc=DataPerc(Membership);
    
    Data(Outside==1)=DataPerc(Outside==1);
end

Order=round(prod(Window)*Percentile/100);
for Z=1:Pix(3)
    DataPerc(:,:,Z)=ordfilt2(Data(:,:,Z),Order,ones(Window.'),'symmetric');
end
if exist('Outside')==1
    DataPerc(Outside==1)=DataPerc(Membership(Outside==1));
end
DataPerc=interpolate3D(DataPerc,[],[],Pix);

