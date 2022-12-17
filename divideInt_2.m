function [Data1]=divideInt_2(Data1,Data2,Factor,Type)

DataType=class(Data1);
if exist('Type')~=1
    Type='/';
end
Factor=single(Factor);
% if isequal(size(Data1),size(Data2))==0
Xi=round(linspace(1,size(Data2,1),size(Data1,1))).';
Yi=round(linspace(1,size(Data2,2),size(Data1,2))).';
Zi=round(linspace(1,size(Data2,3),size(Data1,3))).';
%     A1=Data2(Xi,Yi,Zi(m));
%     A2=interpolate3D_3(Data2(:,:,589),size(Slice1).');
%     Data2(:,:,m)
% end
for m=1:size(Data1,3)
    Slice1=single(Data1(:,:,m));
    Slice2=single(Data2(Xi,Yi,Zi(m)));
%     Slice2=single(Data2(:,:,m));
%     Slice2=single(interpolate3D_3(Data2(:,:,m),size(Slice1).'));
    if strcmp(Type,'/')
        RatioSlice=Slice1./Slice2*Factor;
    elseif strcmp(Type,'*')
        RatioSlice=Slice1.*Slice2*Factor;
    end
    Data1(:,:,m)=cast(RatioSlice(:,:),DataType);
end