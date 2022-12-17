function [First,Last]=firstLastNonzero_4(Input,Type,ReplaceMinusOne)

Pix=size(Input).';

if exist('Type')~=1
   Type='None'; 
end

if strcmp(Type,'None')
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
end

if strcmp(Type,'Total')
    Dimensions=ndims(Input);
    for Dim=1:Dimensions
        Wave1=(1:Dimensions).';
        Wave1(Wave1==Dim,:)=[];
        Wave1=sumdims(Input,Wave1);
        
        NonZero=find(Wave1~=0);
        if isempty(NonZero)==0
            if NonZero(1)==1
                First(Dim,1)=-1;
            else
                First(Dim,1)=NonZero(1);
            end
            if NonZero(end)==size(Input,Dim)
                Last(Dim,1)=-1;
            else
                Last(Dim,1)=NonZero(end);
            end
        else
            First(Dim,1)=0;
            Last(Dim,1)=0;
        end
        
    end
    if exist('ReplaceMinusOne')==1
        First(First==-1)=0;
        Last(Last==-1)=Pix(Last==-1);
    end
end
