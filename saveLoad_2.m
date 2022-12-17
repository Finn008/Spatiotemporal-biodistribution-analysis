function [Out]=saveLoad_2(Path2file)
global W;
m=0;
Time2LastChange=0;
LastChange=datenum(now);
WaitInterval=5;
while m>=0
    m=m+1;
    Fileinfo2add=listAllFiles(Path2file);
    if isempty(Fileinfo2add) % if file not present or deleted during loading
        Out=[];
        return;
    end
    if m==1
        Fileinfo2add.DatenumDiff=0;
        Fileinfo2add.BytesDiff=0;
        Fileinfo=Fileinfo2add;
        pause(5);
        continue
    end
    Fileinfo2add.DatenumDiff=Fileinfo2add.Datenum-Fileinfo.Datenum(end,1);
    Fileinfo2add.BytesDiff=Fileinfo2add.Bytes-Fileinfo.Bytes(end,1);
    Fileinfo=[Fileinfo;Fileinfo2add];
    if Fileinfo.BytesDiff(m,1)==0 && Fileinfo.DatenumDiff(m,1)==0 && Fileinfo.Bytes(end,1)~=0
        Time2LastChange=(datenum(now)-LastChange)*24*60*60;
    else
        LastChange=datenum(now);
        WaitInterval=10;
    end
    if exist('Out') && Time2LastChange>WaitInterval
        return;
    else
    end
    
    pause(5);
    if Time2LastChange>WaitInterval
        try
            Out=load(Path2file);
            Out=struct2cell(Out);
            Out=Out{1,1};
        catch % if file was changed meanwhile loading, therefore go through routine once more
            LastChange=datenum(now);
            clear Out;
        end
    end
    
end
