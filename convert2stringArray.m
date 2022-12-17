function [Out]=convert2stringArray(In)
Out=In;

for m=1:numel(Out)
    try
        IsString=ischar(Out{m});
        
    catch
        IsString=0;
    end
    if IsString==0
        Out(m)={''};
    end
end

% Wave1=cellfun(@iscell, Out, 'UniformOutput', false); Out(cell2mat(Wave1))={''}; % replace cellArrays
% Out=cellfun(@num2str, Out, 'UniformOutput', false);
% [Out]=replaceMixedCell(Out,'nan',{['']});
% [Out]=replaceMixedCell(Out,[],{['']});
