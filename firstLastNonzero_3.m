function [First,Last]=firstLastNonzero_3(Input,Type)

if exist('Type')~=1
   Type='None'; 
end
First=zeros(size(Input,3),size(Input,2));
Last=First;
Input=abs(Input);
Input(isnan(Input))=0;
for Y=1:size(Input,2)
    for Z=1:size(Input,3)
        NonZero=find(Input(:,Y,Z)~=0);
        if isempty(NonZero)==0
            First(Z,Y)=NonZero(1);
            Last(Z,Y)=NonZero(end);
        end
    end
end
if strcmp(Type,'Total')
   First=min(First(:)); 
   Last=max(Last(:));
end



% Size=size(Input,Dimension);
% IsZero=nansum(nansum(Input,2),3);
% 
%     
% NonZero=find(IsZero~=0);
% if isempty(NonZero)==0
%     First=NonZero(1);
%     Last=NonZero(end);
% end