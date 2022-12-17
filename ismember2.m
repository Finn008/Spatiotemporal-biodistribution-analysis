% specifies the positions within Array2 of the IDs found in Array1 
function [Ind]=ismember2(Array1,Array2)
[Wave1,Ind]=ismember(Array1,Array2);
if min(Wave1)==0
    A1=find(Wave1==0);
    keyboard; % some IDs that are present in Array1 are not found in Array2
end
Ind=Ind(Wave1);
