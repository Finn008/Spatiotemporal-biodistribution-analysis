function evaReadFiles()

Path2Folder='\\GNP90N\share\Finn\Raw data\Eva';
InputFiles=listAllFiles(Path2Folder);
OutputTable=table;
OutputTable.FilenameTotal=InputFiles.FilenameTotal;

SurfaceNames={'plaque dimension';'dys dimension';'intensity max';'intensity background'};
for File=1:size(InputFiles,1)
    disp(File);
    Application=openImaris_2(InputFiles.Path2file{File});
    try
        for m=1:size(SurfaceNames,1)
            Wave1=getObjectInfo_2(SurfaceNames{m,1},[],Application);
            SurfaceNames(m,2)={Wave1};
        end
        
        OutputTable.PlaqueArea(File,1)=SurfaceNames{1,2}.ObjInfo.Area;
        OutputTable.DystrophyArea(File,1)=SurfaceNames{2,2}.ObjInfo.Area;
        OutputTable.DystrophyPlaqueRatio(File,1)=OutputTable.DystrophyArea(File,1)/OutputTable.PlaqueArea(File,1);
        
        ChannelNames=SurfaceNames{3, 2}.ChannelNames;
        Wave1=strfind1(ChannelNames,'Ch2-T3');
        OutputTable.DystrophyIntensity(File,1)=SurfaceNames{3,2}.ObjInfo.IntensityMean(1,Wave1);
        OutputTable.BackgroundIntensity(File,1)=SurfaceNames{4,2}.ObjInfo.IntensityMean(1,Wave1);
        OutputTable.IntensityFactor(File,1)=SurfaceNames{3,2}.ObjInfo.IntensityMean(1,Wave1)/SurfaceNames{4,2}.ObjInfo.IntensityMean(1,Wave1);
    end
    quitImaris(Application);
end
keyboard;
ex2ex_2(OutputTable,[Path2Folder,'\Results.xlsx']);