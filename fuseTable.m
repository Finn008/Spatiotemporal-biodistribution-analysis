function [T1]=fuseTable(T1,T2)

T1Names=T1.Properties.VariableNames.';
T2Names=T2.Properties.VariableNames.';
T2RowNumber=size(T2,1);

for m=1:T2RowNumber
    Ind=size(T1,1)+1;
    for m2=T2.Properties.VariableNames
        T1(Ind,m2)=T2(m,m2);
    end
end