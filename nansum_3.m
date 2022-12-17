function [Data]=nansum_3(Data,Dimension)

if Dimension==2
elseif Dimension==1
    Data=Data.';
else
    keyboard;
end

% if all values of one row are NaN then they remain NaN

NanRows=find(sum(isnan(Data),2)==size(Data,2));

Data=nansum(Data,2);
Data(NanRows)=NaN;

if Dimension==1
    Data=Data.';
end