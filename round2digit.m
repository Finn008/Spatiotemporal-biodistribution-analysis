function [Out]=round2digit(In)
for m=1:size(In,1)
   Out{m,1}= sprintf('%.1f',In(m,1));
end