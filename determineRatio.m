function [ratio]=determineRatio(data4D,volume2exclude,cutOffThresholds)

% generate ratiometric data
data4D(data4D==0)=1; % set dark spots to 1 so that you can calculate the ratio
ratio=divideInt(data4D(:,:,:,1),data4D(:,:,:,2),1000); % set 1000 to ratio of 1

% set pixels of excluded volume to zero
if exist('volume2exclude','var') && isempty(volume2exclude)==0
    wave1=volume2exclude;
    wave1(volume2exclude==0)=1;
    wave1(volume2exclude~=0)=0;
    volume2exclude=uint16(wave1);
    for m=1:3;
        ratio=ratio.*volume2exclude;
    end
end

if exist('cutOffThresholds','var') && isempty(cutOffThresholds)==0
    ratio(data4D(:,:,:,1)<cutOffThresholds(1,1))=0; % 200
    ratio(data4D(:,:,:,2)<cutOffThresholds(2,1))=0; % 800
end
% ratio(:)=ratio(:)*100; % set 10000 to 100%