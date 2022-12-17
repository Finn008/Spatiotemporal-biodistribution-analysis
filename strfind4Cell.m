function [out]=strfind4Cell(string,array)
if iscell(array)==0
    array=num2cell(array);
end
array(cellfun(@(x) any(isnumeric(x)),array)) = {['']}; % replace any numeric with empty string
out = regexp(array,string);

for m=1:size(out,1)
    if isempty(out{m});
        out{m}=0;
    end
end

out=cell2mat(out);