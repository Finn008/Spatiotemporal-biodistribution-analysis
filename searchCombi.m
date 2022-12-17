function [ind]=searchCombi(strings,arrays)

% check if combination of given strings is already present in the given array

[wave,wave1]=strfind1(arrays(:,1),strings{1});
% wave1 = ~cellfun(@isempty,wave1);
[wave,wave2]=strfind1(arrays(:,2),strings{2});
% wave2 = ~cellfun(@isempty,wave2);
wave3=wave1+wave2;
ind=find(wave3==2); % where is the reference file located in DriftInfo
if isempty(ind);
    ind=0;
end
