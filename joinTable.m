function [Out]=joinTable(In)
Out=In{1};
for m=2:size(In,1)
    Range=size(Out,1)+1;
    Range(2,1)=Range+size(In{2},1)-1;
    for m2=In{m}.Properties.VariableNames
        Out(Range(1):Range(2),m2)=In{m}(:,m2);
    end
end
% keyboard;