function [Out]=convert2uint16(In,DataClass)

if exist('DataClass')~=1
    DataClass='uint16';
end

if isnumeric(In)
   Out=cast(In,DataClass); 
%    Out=uint16(In);
elseif istable(In)
    VariableNames=In.Properties.VariableNames;
    RowNames=In.Properties.RowNames;
%     Out=uint16(table2array(In));
    Out=cast(table2array(In),DataClass); 
    Out=array2table(Out,'VariableNames',VariableNames,'RowNames',RowNames);
end