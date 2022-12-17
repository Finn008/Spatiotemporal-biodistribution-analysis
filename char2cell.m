function [Out]=char2cell(In)
Out=cell(1,1);
for m=1:size(In,2)
    Out(m,1)={In(1,m)};
end