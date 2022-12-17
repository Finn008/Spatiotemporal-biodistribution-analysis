function toBeDeconvoluted()
global l;
% uigetfile('*.m', 'Select Multiple Files', 'MultiSelect', 'on' );
fileinfo=l.g.fileinfo;
for m=1:size(fileinfo,1);
    if strcmp(fileinfo(m).type, {'.lsm'}) && strcmp(fileinfo(m).DoGetFileInfo, {'toBeDeconvoluted'});
        wave1=find(strcmp({fileinfo.filenameTotal},{[fileinfo(m).filename,'.ids']})==1);
        if isempty(wave1);
            pathSource=[l.g.pathRaw,'\',fileinfo(m).filenameTotal];
            pathDestination=[l.g.pathRaw,'\','toBeDeconvoluted\',fileinfo(m).filenameTotal];
            copyfile(pathSource,pathDestination);
            disp(['toBeDeconvoluted: ',pathSource]);
            l.g.fileinfo(m).DoGetFileInfo='toBeDeconvoluted_done';
        end
    end
end

