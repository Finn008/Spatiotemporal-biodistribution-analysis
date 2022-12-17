function [XY,XZ,YZ,All]=intensityProjection_2(Data3D,Res,GapUm,Version)

if exist('Version','Var')==0
    Version='MaxIntensity';
end

CoordinateSystem='Standard';
% % % CoordinateSystem='Matlab'; % X in columns and wrong direction, Y in rows but correct direction
if strcmp(CoordinateSystem,'Standard')
    Data3D=permute(Data3D,[2,1,3]);
    Data3D=Data3D(size(Data3D,1):-1:1,:,size(Data3D,3):-1:1);
end
Pix=size(Data3D).';
GapPix=GapUm/Res(1);

if strcmp(Version,'MaxIntensity')
    XY=max(Data3D,[],3);
    All=XY;
    XZ=interpolate3D(permute(max(Data3D,[],1),[3,2,1]),[Res(3);Res(1);1],[Res(1);Res(2);1]);
    All(size(All,1)+GapPix:size(All,1)+GapPix-1+size(XZ,1),:)=XZ;
    YZ=interpolate3D(permute(max(Data3D,[],2),[1,3,2]),[Res(1);Res(3);1],[Res(1);Res(2);1]);
    All(1:size(YZ,1),size(All,2)+GapPix:size(All,2)+GapPix-1+size(YZ,2),:)=YZ;
end
if strcmp(Version,'Center')
    Um=Pix.*Res;
    PixRanges=round([Um/2-1,Um/2+1]./repmat(Res,[1,2]));
    XY=max(Data3D(:,:,PixRanges(3,:)),[],3);
    All=XY;
    XZ=interpolate3D(permute(max(Data3D(PixRanges(1,:),:,:),[],1),[3,2,1]),[Res(3);Res(1);1],[Res(1);Res(2);1]);
    All(size(All,1)+GapPix:size(All,1)+GapPix-1+size(XZ,1),:)=XZ;
    YZ=interpolate3D(permute(max(Data3D(PixRanges(1,:),:,:),[],2),[1,3,2]),[Res(1);Res(3);1],[Res(1);Res(2);1]);
    All(1:size(YZ,1),size(All,2)+GapPix:size(All,2)+GapPix-1+size(YZ,2),:)=YZ;
end