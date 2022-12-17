% allows also numeric
function Out=findIntersection_2(Array1,Array2)

if exist('Array2')==1
    Array1={Array1;Array2};
end

if ischar(Array1{1,1}{1,1})
    for m=1:size(Array1{1,1},1)
        String=Array1{1,1}{m,1};
        for m2=2:size(Array1,1)
            Array(m,1)=strfind1(Array1{m2,1},String,1);
        end
    end
    Out=Array1{1,1}(Array>0,1);
elseif isnumeric(Array1{1,1}(1,1))
    keyboard;
end


