function reduceIbackup()

% now - 1 week: everything
% 1 week - 1 month: 2 per day
% 1 month - open end: 1 per week

Path2Backup='\\GNP90N\share\Finn\Analysis\backup';

Now=datenum(now);
Wave1=(7:0.5:29.5).';
Wave2=(30:7:365*5).';


Filelist=table;
Filelist.Days=[Wave1;Wave2];

for m=1:size(Filelist,1)
    Filelist.Date(m,1)={datestr(Now-Filelist.Days(m,1),'yyyy.mm.dd HH:MM')};
end

AllFiles=listAllFiles(Path2Backup);

for m=1:size(AllFiles,1)
    
end

A1=1;