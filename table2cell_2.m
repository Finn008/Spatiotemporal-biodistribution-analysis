function [Output]=table2cell_2(Input)

Fields=Input.Properties.VariableNames.';
for m=1:size(Fields,1)
    Wave1=Input{:,Fields{m,1}};
    if isnumeric(Wave1) || islogical(Wave1)
        Wave1=num2cell(Wave1);
    elseif ischar(Wave1)
        Wave1=cellstr(Wave1);
    end
    Wave1=[repmat(Fields(m,1),[1,size(Wave1,2)]);Wave1];
    if m==1
        Output=Wave1;
    else
        Output=[Output,Wave1];
    end
    
end
% Input=Output;