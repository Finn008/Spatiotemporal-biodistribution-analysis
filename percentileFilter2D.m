function [DataPerc]=percentileFilter2D(Data,Percentile,Window,Res,ResCalc,Outside)
tic;
Pix=size(Data).'; if size(Pix,1)==2; Pix(3)=1; end;
Data=interpolate3D(Data,Res,ResCalc);
if exist('Outside')==1
    Data(Data==0)=1;
    Data(Data==65535)=65534;
    Min=0; % Min=min(Data(:));
    Max=65535; % Max=max(Data(:));
    Outside=uint8(interpolate3D(Outside,Res,ResCalc));
    Outside2Ind=find(Outside==1);
    Data(Outside2Ind(1:2:size(Outside2Ind,1)))=Min;
    Data(Outside2Ind(2:2:size(Outside2Ind,1)))=Max;
    clear Outside2Ind;
    DataPerc=medfilt3(Data,[Window;1]); % calculate median
    Outside(DataPerc==Min | DataPerc==Max)=2;
    Membership=zeros(size(Outside),'uint32');
    for Z=1:Pix(3)
        Wave1=logical(1-Outside(:,:,Z));
        if max(Wave1(:))==0 % if no voxel is present in this layer then use voxel of next or previous layer
            Membership(:,:,Z)=0;
        else
            [~,Wave1]=bwdist(Wave1,'quasi-euclidean');
            Membership(:,:,Z)=Wave1+prod(size(Wave1))*(Z-1);
        end
    end
    DataPerc(Membership>0)=DataPerc(Membership(Membership>0));
    DataPerc(Membership==0)=0;
    
    Data(Outside==1)=DataPerc(Outside==1);
end

Order=round(prod(Window)*Percentile/100);
for Z=1:Pix(3)
    DataPerc(:,:,Z)=ordfilt2(Data(:,:,Z),Order,ones(Window.'),'symmetric');
end
if exist('Outside')==1
    % if whole slice is outside then Membership in that whole slice is zero
    DataPerc(Outside==1&Membership~=0)=DataPerc(Membership(Outside==1&Membership~=0));
    DataPerc(Membership==0)=65535;
end
DataPerc=interpolate3D(DataPerc,[],[],Pix);

