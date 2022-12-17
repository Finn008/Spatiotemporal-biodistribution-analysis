function [fMean,fNumber]=finnsMean()

input=rand(5,5);
input(:,3)=NaN;
dataNumber=input; dataNumber(:)=1;
dataNumber(isnan(input))=0; 
fNumber=sum(dataNumber,2);
input(isnan(input))=0;
fMean=sum(input,2);
fMean=fMean./fNumber;