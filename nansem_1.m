% each n in one column
function [SEM]=nansem_1(Data)

Table=table;
Table.Data=Data;
Table.N=size(Data,2)-sum(isnan(Data),2);
Table.Mean=nanmean(Table.Data,2);
Table.Data2=Table.Data-repmat(Table.Mean,[1,size(Data,2)]);
Table.Data2=Table.Data2.^2;
Table.TotalDeviation=nansum(Table.Data2,2);
Table.TotalDeviation(Table.N<=1)=NaN;
Table.SEM=(Table.TotalDeviation.^0.5)./(Table.N-1);
Table.SD=(Table.TotalDeviation./(Table.N-1)).^0.5;

SEM=Table.SEM;
% for m=1:size(Table,1)
%     Wave1=Table.Data(m,:).';
%     Wave1(isnan(Wave1),:)=[];
%     if size(Wave1,1)>0
%         Table.Test(m,1)=std(Wave1);
%     end
% end
% Table.Test2=Table.Test-Table.SD;


% Table.AbsDev=mad(Data,[],2);

% Table.SD=(Table.AbsDev.^0.5)./(Table.N-1);
% Table.SEM=(Table.AbsDev./(Table.N-1)).^0.5;
% nonanx=Data(~isnan(Data));
% SEM=std(nonanx) / sqrt(size(nonanx,2));

