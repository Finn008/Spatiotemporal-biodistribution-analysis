function [ind]=findInd(array,string)
keyboard; % not used since 2017.02.21
wave1=strcmp(array,string);
ind=find(wave1==1);
if isempty(ind)
    ind=NaN;
end
