function determineOutside()

Filelist=listAllFiles('\\GNP90N\share\Finn\Raw data');

Wave1=strfind1(Filelist.FilenameTotal,'_Outside.mat');
Filelist=Filelist(Wave1,:);
Filelist=Filelist(Filelist.Datenum>datenum('2016.05.10 08:00','yyyy.mm.dd HH:MM'),:);
Filelist(:,{'Isdir','Bytes','Type','Filename'})=[];
% Table=table;
for File=1:size(Filelist,1)
   Wave1=load(Filelist.Path2file{File}); 
   if strcmp(fieldnames(Wave1),'Results')
       Filelist.Results(File,1)={Wave1.Results};
   else
       Filelist.SpotRatio(File,1)=Wave1.Container.Results.SpotDistanceRatio(end);
       Filelist.MeanSpotDistance(File,1)=Wave1.Container.Results.MeanSpotDistance(end);
       Filelist.Area(File,1)=Wave1.Container.Results.Area(end);
       Filelist.NormalMinDist(File,1)=Wave1.Container.NormalMinDist;
%        Filelist.Rmse(File,1)=Wave1.Container.Rmse;
       try; Filelist.FitCoef(File,1:5)=Wave1.Container.Results.FitCoef(end,:); end;
       Filelist.Results(File,1)={Wave1.Container.Results};
       Filelist.SpotDistanceHistogram(File,1)={Wave1.Container.SpotDistanceHistogram};
   end
end

Filelist38b=Filelist(strfind1(Filelist.FilenameTotal,'38b'),:);
Filelist64b=Filelist(strfind1(Filelist.FilenameTotal,'64b'),:);
keyboard

Range=0.1;
for m=1:size(Filelist38b,1)
    FitCoef=Filelist38b.FitCoef(m,:).';
    if FitCoef(1)<90 && FitCoef(2)>-0.0024-Range && FitCoef(2)<-0.0024+Range && FitCoef(4)>0.1-Range && FitCoef(2)<0.1+Range
        Filelist38b.Outcome(m,1)=1;
    else
        Filelist38b.Outcome(m,1)=0;
    end
end


% Filelist(:,{'Bytes','Isdir','Type','Filename'}) = [];
OrigFilelist=Filelist;
Filelist(Filelist.NormalMinDist==0,:)=[];



for File=1:size(Filelist,1)
    Filelist.SpotDistanceRatio(File,1)=Filelist.MeanSpotDistance(File)/Filelist.NormalMinDist(File);
end




Path=[FilenameTotalRatioB,'_Outside.mat'];
Path=getPathRaw(Path);
save(Path,'Container');

MessagePath=[num2str(uint8(Results.MeanSpotDistance(end))),'/',num2str(uint8(Con.NormalMinDist))];
% if Results.MeanSpotDistance(end)<Con.NormalMinDist*0.5