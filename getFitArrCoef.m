function [ind]=getFitArrCoef(filename,filenameList);
dbstop if error;

% get root name of filename
IndOf_=strfind(filename,'_'); 
if size(IndOf_,2)>1;
    RootFilename=filename(1:IndOf_(1,2)-1);
else
    RootFilename=filename;
end

ind=strfind(filenameList,RootFilename);
ind= ~cellfun(@isempty,ind);
ind=find(ind==1);

% if isempty(ind)
%     fitCoefs=zeros(3,3,'double');
% else
%     fitCoefs=filenameList{ind,7};
%     fitCoefRange=filenameList{ind,10};
% end