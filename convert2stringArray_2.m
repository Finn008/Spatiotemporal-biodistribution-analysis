function [Out]=convert2stringArray_2(In)
Out=In;

for m=1:numel(Out)
    DataType=class(Out{m});
    if strcmp(DataType,'char')
        
    elseif strcmp(DataType,'double')
        Out(m)={num2str(Out{m})};
    else
        keyboard;
        Out(m)={''};
    end
%     try
%         IsString=ischar(Out{m});
%     catch
%         IsString=0;
%     end
%     if IsString==0
%         Out(m)={''};
%     end
end

% Wave1=cellfun(@iscell, Out, 'UniformOutput', false); Out(cell2mat(Wave1))={''}; % replace cellArrays
% Out=cellfun(@num2str, Out, 'UniformOutput', false);
% [Out]=replaceMixedCell(Out,'nan',{['']});
% [Out]=replaceMixedCell(Out,[],{['']});
