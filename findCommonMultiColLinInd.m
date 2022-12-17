function [Ind1,Ind2]=findCommonMultiColLinInd(Table1,Table2)

Table=[Table1;Table2];
Rois=table;
for Var=1:size(Table,2)
    Rois.Data(Var,1)={Table{:,Var}};
    [Rois.Unique{Var},~,Rois.Data{Var}]=unique(Rois.Data{Var});
    Rois.Max(Var,1)=round(max(Rois.Data{Var}));
% % %     if Max<=255
% % %         Rois.Data{Var}=uint8(Rois.Data{Var});
% % %     elseif Max<=65535
% % %         Rois.Data{Var}=uint16(Rois.Data{Var});
% % %     else
% % %         keyboard;
% % %     end
    Rois.Digits(Var,1)=size(num2str(Rois.Max(Var,1)),2);
end

Pix=size(Rois.Data{1,1}).';
Table.LinInd=zeros(Pix.','uint64');

for Row=1:size(Rois,1)
    Table.LinInd=Table.LinInd+uint64(Rois.Data{Row,1})*10^sum(Rois.Digits(Row+1:end));
end
if max(Table.LinInd(:))==uint64(2^64); keyboard; end;
Ind1=Table.LinInd(1:size(Table1,1));
Ind2=Table.LinInd(size(Table1,1)+1:end);