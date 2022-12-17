function [Output]=getNthNumeric(Array,MinMax)

if strcmp(class(Array),'uint64')
    Output=rem(Array,10^(MinMax(1)-1));
    Array=Array-Output;
    Array=Array/(10^(MinMax(1)-1));
    Output=rem(Array,10^(MinMax(2)-MinMax(1)+1));
%     Output=floor(double(Array)/10^(MinMax(1)-1));
%     Output=rem(Output,10^(MinMax(2)-MinMax(1)+1));
%     Output=cast(Output,class(Array));
else
    keyboard;
end
%     unique(Wave1)
%     A1=find(Wave1==2);