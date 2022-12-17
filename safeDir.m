function [Fileinfo]=safeDir(Path2file)

for m=1:20
    Fileinfo=dir(Path2file);
    if isempty(Fileinfo)==0
        break;
    end
    pause(0.5)
end

if isempty(Fileinfo) % file not present
    Type='File';
    return;
elseif strcmp(Fileinfo(1).name,'.') && strcmp(Fileinfo(2).name,'..') % '.' and '..'
    Type='Folder';
    if size(Fileinfo,1)==2 % file not present
        return;
    end
end

for m1=1:size(Fileinfo,1)
    IsNumeric(m1,1)=isnumeric(Fileinfo(m1,1).datenum);
    IsEmpty(m1,1)=isempty(Fileinfo(m1,1).datenum);
end
Fileinfo(IsNumeric==0|IsEmpty==1,:)=[];
