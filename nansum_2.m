function [Data]=nansum_2(Data,Dimension)

% if all values of one row are NaN then they remain NaN

NanRows=find(sum(isnan(Data),2)==size(Data,2));

Data=nansum(Data,2);
Data(NanRows)=NaN;