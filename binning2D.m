function [data]=binning2D(data,rowBin,colBin)

rowNum=size(data,1)/rowBin;
colNum=size(data,2)/colBin;

data=reshape(data,rowBin,rowNum,colBin,colNum);
data=sum(data,1);
data=sum(data,3);
data=reshape(data,rowNum,colNum);