function [Table]=sortrows_2(Table,SortOrder)

if exist('SortOrder')~=1
    SortOrder=Table.Properties.VariableNames.';
end

for m=size(SortOrder,1):-1:1
    Table=sortrows(Table,SortOrder{m});
end