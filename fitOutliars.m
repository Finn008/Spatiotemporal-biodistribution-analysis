function [FitData,Exclusion,Outliars]=fitOutliars(Xaxis,Yaxis,FitType,OutliarPercentage,SmoothingParam)

OutliarNumber=round(size(Xaxis,1)*OutliarPercentage)/100;
Exclusion=zeros(size(Xaxis,1),1);
for m=1:OutliarNumber
    Fit = fit(Xaxis,Yaxis,FitType,'SmoothingParam',SmoothingParam,'Exclude',Exclusion);
    FitData=feval(Fit,Xaxis);
    Error=abs(FitData-Yaxis);
    try; Error(Outliars(:,1))=0; end;
    [A1,Outliars(m,1)]=max(Error);
    Exclusion(Outliars(m,1))=1;
end

A1=1;
