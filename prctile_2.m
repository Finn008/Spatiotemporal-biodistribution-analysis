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


