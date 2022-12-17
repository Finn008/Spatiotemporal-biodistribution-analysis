function ratioPlaque_InterPlaqueDistance(FilenameTotal)


PathTotalResults=regexprep(FilenameTotal,'_Trace.ims','_RatioResults.mat');
[PathTotalResults,Report]=getPathRaw(PathTotalResults);
if Report==1
    TotalResults=load(PathTotalResults);
    TotalResults=TotalResults.TotalResults;
else
    keyboard;
end

Fileinfo=getFileinfo_2(FilenameTotal);
Pix=Fileinfo.Pix{1};
Res=Fileinfo.Res{1};
UmStart=Fileinfo.UmStart{1};
Timepoints=Fileinfo.GetSizeT;

for Time=1:Timepoints
    [PlaqueMap]=im2Matlab_3(FilenameTotal,'Membership',Time);
    [DistInOut]=im2Matlab_3(FilenameTotal,'DistInOut',Time);
    
    PlaqueMap(DistInOut>50)=0;
    [Table]=xyzDistanceAmorph_2(PlaqueMap,Res,UmStart);
    
    for Pl=1:size(Table,1)
        TotalResults.TracePlaqueData.Data{Pl,1}.MinDistance(Time,1)=Table.MinDistance(Pl,1);
        TotalResults.TracePlaqueData.Data{Pl,1}.Distances(Time,1)=Table.Distances(Pl,1);
    end
end

save(PathTotalResults,'TotalResults');
