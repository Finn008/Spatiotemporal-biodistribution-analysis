function [Table]=calcDistance3D(Table,In)
try; v2struct(In); end;

Table=array2table(Table,'VariableNames',{'X','Y','Z'});

MeanNumber=5;
for m=1:size(Table,1)
    if exist('Zband')
        Selection=Table(Table.Z>Table.Z(m)-Zband/2&Table.Z<Table.Z(m)+Zband/2,:);
        Wave1=sort(((Selection.X-Table.X(m)).^2+(Selection.Y-Table.Y(m)).^2+(Selection.Z-Table.Z(m)).^2).^0.5);
    else
        Wave1=sort(((Table.X-Table.X(m)).^2+(Table.Y-Table.Y(m)).^2+(Table.Z-Table.Z(m)).^2).^0.5);
    end
    try
        Table.MinDist(m,1)=mean(Wave1(2:MeanNumber));
    catch
        Table.MinDist(m,1)=mean(Wave1(2:end));
    end
end
