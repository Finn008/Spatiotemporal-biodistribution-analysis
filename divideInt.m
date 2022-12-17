function [data1]=divideInt(data1,data2,factor)

for m=1:size(data1,3);
    slice1=single(data1(:,:,m));
    slice2=single(data2(:,:,m));
    ratioSlice=slice1./slice2*factor;
    data1(:,:,m)=uint16(ratioSlice(:,:));
end