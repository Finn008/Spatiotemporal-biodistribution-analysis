function [Distance]=distanceAlongPath(Data,Resolution)
Table=table;
Table.XYZ=Data;
Wave1=[0,0,0;Table.XYZ(2:end,:)-Table.XYZ(1:end-1,:)];
Table.InterDistance=(Wave1(:,1).^2+Wave1(:,2).^2+Wave1(:,3).^2).^0.5;
Table.Distance=cumsum(Table.InterDistance);

if exist('Resolution','Var')==1
    keyboard;
end
Distance=Table.Distance;