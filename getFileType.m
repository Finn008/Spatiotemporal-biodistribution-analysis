function [FileType]=getFileType(Filename,PossibleTypes)
global W;

FileType=cell(0,1);
for m=PossibleTypes.'
    [~,Report]=getPathRaw(strcat(Filename,m));
    if Report==1
        FileType(size(FileType,1)+1,1)=m;
    end
end
if size(FileType,1)>1 % File exists with different types
%     W.ErrorMessage=['Function: getFileType(), Error: File exists with different types: ',Filename];
    A1=asdf; % File exists with different types
elseif size(FileType,1)==0 % File does not exist
%     FileType='.xxx';
%     W.ErrorMessage=['Function: getFileType(), Error: File does not exist: ',Filename];
    A1=asdf; % File does not exist
else
    FileType=FileType{1};
end