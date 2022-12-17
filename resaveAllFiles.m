function resaveAllFiles()
global W;
FileList=W.G.T.F{W.Task};
FileList=FileList(strfind1(FileList.BoutonDetect,'Do#'),:);

for File=1:size(FileList,1)
    [NameTable,SibInfo]=fileSiblings_3(FileList.Filename{File});
    FilenameTotalRatioA=NameTable{'RatioA','FilenameTotal'}{1};
    Fileinfo=getFileinfo_2(FilenameTotalRatioA);
    FilenameTotalFusedStack=[NameTable.Filename{'OriginalA'},'_Fused.ims'];
    J=struct('PixMax',Pix,'UmMinMax',[-double(Pix).*Res/2,double(Pix).*Res/2],'Path2file',W.PathImarisSample);
    Application=openImaris_2(J);
    Application.FileSave(getPathRaw(FilenameTotalFusedStack),'writer="Imaris5"');
    quitImaris(Application); clear Application;
    imarisSaveHDFlock(Application,Path2fileDriftCorr);
end

