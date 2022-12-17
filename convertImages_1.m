function convertImages_1()

FolderPath='\\Gnp42n\marvin\Finn\data\X0103 presentations\X0202\Files\BACEvsControl';
InputFiles=listAllFiles(FolderPath);

for m=1:size(InputFiles,1)
   TifImage=imread(InputFiles.Path2file{m,1});
%    ExportedImage=im2uint8(TifImage);
   TargetPath=[FolderPath,'\',InputFiles.Filename{m,1},'.png'];
   imwrite(TifImage,TargetPath);
end
