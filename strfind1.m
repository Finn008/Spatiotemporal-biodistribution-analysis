% Type defines if string must match completely or only part of it
function [Ind,SumArray]=strfind1(ArrayIn,SearchString,Type,Empty,SwitchOutput)
if exist('Type','var')==0 || isempty(Type)
    Type=0;
end
if iscell(SearchString)==0
    SearchString={SearchString};
end
if isnumeric(ArrayIn)
    ArrayIn=num2cell(ArrayIn);
elseif ischar(ArrayIn)
    ArrayIn={ArrayIn};
elseif istable(ArrayIn)
    ArrayIn=table2cell(ArrayIn);
end
Number=size(SearchString,1);

Wave1=cellfun(@iscell, ArrayIn, 'UniformOutput', false); ArrayIn(cell2mat(Wave1))={''}; % replace cellArrays
ArrayIn=cellfun(@num2str, ArrayIn, 'UniformOutput', false);
[ArrayIn]=replaceMixedCell(ArrayIn,'nan',{['']});
[ArrayIn]=replaceMixedCell(ArrayIn,[],{['']});
[SearchString]=replaceMixedCell(SearchString,'nan',{['']});
if Type==0
    for m=1:Number
        Wave1=strfind(ArrayIn,SearchString{m,1});
        Wave1 = ~cellfun(@isempty,Wave1); % strfind produces cell array while strcmp a logical array
        Array(:,:,m)=Wave1*m;
    end
elseif Type ==1
    
    for m=1:Number
        Array(:,:,m)=strcmp(ArrayIn,SearchString{m,1})*m;
    end
end

SumArray=sum(Array,3);
try
    [Ind,Col,Val]=find(SumArray);
    if size(Ind,2)>1 % because otherwise Ind entries are stored into columns instead of the rows
        Ind=Ind.';
        Ind(:,2)=Col.';
    else
        Ind(:,2)=Col;
    end
    Ind(:,3)=Val;
    Ind=sortrows(Ind,3);
    Ind(:,3)=[];
    
    if size(SumArray,2)==1
        Ind=Ind(:,1);
    end
    if isempty(Ind)
        Ind=0;
    end
catch
    Array=zeros(size(Array,1),1);
    Ind=0;
end

if exist('Empty')==1 && Empty==1 && Ind(1)==0
    Ind=[];
end
if exist('SwitchOutput','var')==1
    Wave1=Ind;
    Ind=SumArray;
    SumArray=Wave1;
end