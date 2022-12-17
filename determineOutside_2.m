function determineOutside_2()
FileList=evalin('caller','FileList(:,''FilenameTotal'')');

for File=1:size(FileList,1)
    Path2file=[FileList.FilenameTotal{File},'_Outside.mat'];
    Path2file=getPathRaw(Path2file);
    Wave1=load(Path2file);
    
    FileList.SpotRatio(File,1)=Wave1.Container.Results.SpotDistanceRatio(end);
    FileList.MeanSpotDistance(File,1)=Wave1.Container.Results.MeanSpotDistance(end);
    FileList.Area(File,1)=Wave1.Container.Results.Area(end);
    FileList.NormalMinDist(File,1)=Wave1.Container.NormalMinDist;
    try; FileList.FitCoef(File,1:5)=Wave1.Container.Results.FitCoef(end,:); end;
    FileList.Results(File,1)={Wave1.Container.Results};
    FileList.SpotDistanceHistogram(File,1)={Wave1.Container.SpotDistanceHistogram};
end
A1=1;



return;
% % % FileList=listAllFiles('\\GNP90N\share\Finn\Raw data');
% % % 
% % % Wave1=strfind1(FileList.FilenameTotal,'_Outside.mat');
% % % FileList=FileList(Wave1,:);
% % % FileList=FileList(FileList.Datenum>datenum('2016.05.10 08:00','yyyy.mm.dd HH:MM'),:);
% % % FileList(:,{'Isdir','Bytes','Type','Filename'})=[];
% % % % Table=table;
% % % for File=1:size(FileList,1)
% % %     Wave1=load(FileList.Path2file{File});
% % %     if strcmp(fieldnames(Wave1),'Results')
% % %         FileList.Results(File,1)={Wave1.Results};
% % %     else
% % %         FileList.SpotRatio(File,1)=Wave1.Container.Results.SpotDistanceRatio(end);
% % %         FileList.MeanSpotDistance(File,1)=Wave1.Container.Results.MeanSpotDistance(end);
% % %         FileList.Area(File,1)=Wave1.Container.Results.Area(end);
% % %         FileList.NormalMinDist(File,1)=Wave1.Container.NormalMinDist;
% % %         %        Filelist.Rmse(File,1)=Wave1.Container.Rmse;
% % %         try; FileList.FitCoef(File,1:5)=Wave1.Container.Results.FitCoef(end,:); end;
% % %         FileList.Results(File,1)={Wave1.Container.Results};
% % %         FileList.SpotDistanceHistogram(File,1)={Wave1.Container.SpotDistanceHistogram};
% % %     end
% % % end
% % % 
% % % Filelist38b=FileList(strfind1(FileList.FilenameTotal,'38b'),:);
% % % Filelist64b=FileList(strfind1(FileList.FilenameTotal,'64b'),:);
% % % keyboard
% % % 
% % % Range=0.1;
% % % for m=1:size(Filelist38b,1)
% % %     FitCoef=Filelist38b.FitCoef(m,:).';
% % %     if FitCoef(1)<90 && FitCoef(2)>-0.0024-Range && FitCoef(2)<-0.0024+Range && FitCoef(4)>0.1-Range && FitCoef(2)<0.1+Range
% % %         Filelist38b.Outcome(m,1)=1;
% % %     else
% % %         Filelist38b.Outcome(m,1)=0;
% % %     end
% % % end
% % % 
% % % 
% % % % Filelist(:,{'Bytes','Isdir','Type','Filename'}) = [];
% % % OrigFilelist=FileList;
% % % FileList(FileList.NormalMinDist==0,:)=[];
% % % 
% % % 
% % % 
% % % for File=1:size(FileList,1)
% % %     FileList.SpotDistanceRatio(File,1)=FileList.MeanSpotDistance(File)/FileList.NormalMinDist(File);
% % % end
% % % 
% % % 
% % % 
% % % 
% % % Path=[FilenameTotalRatioB,'_Outside.mat'];
% % % Path=getPathRaw(Path);
% % % save(Path,'Container');
% % % 
% % % MessagePath=[num2str(uint8(Results.MeanSpotDistance(end))),'/',num2str(uint8(Con.NormalMinDist))];
% % % % if Results.MeanSpotDistance(end)<Con.NormalMinDist*0.5