function extractFileChannels(Path2file)

Path2file=mfilename('fullpath');
Wave1=strfind(Path2file,'\');
Path2file=Path2file(1:Wave1(end));
FileList=listAllFiles(Path2file);

convertCzi2bmp(FileList);

FolderList=listAllFiles(Path2file,1);
for m=1:size(FolderList,1)
    FileList=listAllFiles(FolderList.Path2file{m});
    convertCzi2bmp(FileList);
end



function convertCzi2bmp(FileList) % convert all czi files into bmp
% keyboard;
for m=1:size(FileList,1)
    if strcmp(FileList.Type{m},'.czi')
        for Ch=1:3
            [Data3D(:,:,Ch)]=imreadBF_3(FileList.Path2file{m},[],[],Ch);
            Path=regexprep(FileList.Path2file{m},'.czi',['_',num2str(Ch),'.bmp']);
            Max=permute(max(max(Data3D,[],1),[],2),[3,2,1]);
            imwrite(double(Data3D(:,:,Ch))/double(Max(Ch)),Path);
        end
        
    end
end
