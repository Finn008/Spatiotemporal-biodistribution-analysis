function generate2DImageFrom3D()

global W;
FolderPath=[W.G.PathOut,'\2DImageFrom3D'];
FileList=W.G.T.F{5,1};
for File=1:size(FileList,1)
    if isnan(FileList.BoutonDetect{File}); continue; end;
    [NameTable,SibInfo]=fileSiblings_3([FileList.Filename{File}]);
    if isempty(NameTable) || NameTable{'DeFinA','Report'}==0
        continue;
    end
    FilenameTotal=NameTable{'DeFinA','FilenameTotal'};
    Fileinfo=getFileinfo_2(FilenameTotal);
    Pix=Fileinfo.Pix{1};
    PixSelection=[1,Pix(1);1,Pix(2);round(Pix(3)/2),round(Pix(3)/2)];
    [Data2D]=im2Matlab_3(FilenameTotal,2,1,[],PixSelection);
    
    Threshold=prctile(Data2D(:),97);
    Wave1=double(Data2D)/double(Threshold)*256;
    
    TargetPath=[FolderPath,'\',NameTable{'DeFinA','Filename'}{1},'.jpg'];
    imwrite(uint8(Wave1),TargetPath);
end
