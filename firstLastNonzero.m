function [First,Last]=firstLastNonzero(Input);
First=0; Last=0;
for m=1:size(Input,1);
    if Input(m)~=0;
        First=m;
        break;
    end
end


for m=size(Input,1):-1:1;
    if Input(m)~=0;
        Last=m;
        break;
    end
end


