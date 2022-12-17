function [First,Last]=firstLastNonzero_2(Input,Dimension)
First=0; Last=0;

Size=size(Input,Dimension);
Input=abs(Input);
% IsZero=false(Size,1);
if Dimension==1
    IsZero=nansum(nansum(Input,2),3);
end
NonZero=find(IsZero~=0);
if isempty(NonZero)==0
    First=NonZero(1);
    Last=NonZero(end);
end