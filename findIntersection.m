function Out=findIntersection(In)

for m=1:size(In{1,1},1)
    String=In{1,1}{m,1};
    for m2=2:size(In,1)
        Array(m,1)=strfind1(In{m2,1},String,1);
    end
end

Out=In{1,1}(Array>0,1);

