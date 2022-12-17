% file=all: check through raw data folders for new files
% file=specificFile: get info only on that file
function [Fileinfo,FileinfoInd,PathRaw]=getFileinfo_2(FilenameTotal,Speci)
global W;

W.CurrentFunction='GetFileInfo';
if exist('Speci')==1
    if isstruct(Speci)
        v2struct(Speci);
    else
        Application=Speci;
    end
end

if exist('Application')==0
    Application=[];
end
Fileinfo=[];
FileinfoInd=[];

if exist('FilenameTotal')==0
    FilenameTotal=W.G.Fileinfo.FilenameTotal{W.Row,1};
end
if iscell(FilenameTotal)
    FilenameTotal=FilenameTotal{1,1};
end

% search file in W.G.Fileinfo
[Ind]=strfind1(W.G.Fileinfo.FilenameTotal,FilenameTotal);
if Ind==0
    Ind=[];
else
    Ind=W.G.Fileinfo.Properties.RowNames(Ind);
    Fileinfo=W.G.Fileinfo(Ind,:);
    FileinfoInd=Ind;
end

[PathRaw,Report]=getPathRaw(FilenameTotal);
if exist('DeleteFile')==1 % delete Fileinfo entry in W.G.Fileinfo, provide PathRaw
    if isempty(Ind)==0
        iFileChanger('W.G.Fileinfo(Q1,:)',[],{'Q1',Ind});
    end
    return;
end

% remove duplicates
if size(Ind,1)>1
    disp(['ERROR: File was present more than once in Fileinfo. ',FilenameTotal]);
    Wave1=W.G.Fileinfo(Ind,:);
    IndRemove=Ind;
    [Wave2]=max(Wave1.Datenum);
    Ind=find(Wave1.Datenum==Wave2);
    if size(Ind,1)>1
        for m=1:size(Ind,1)
            ChangeDate(m,1)=datenum(Wave1.Date{m,1},'yyyy.mm.dd HH:MM:SS');
        end
        Ind=find(ChangeDate==max(ChangeDate(:)));
        if size(Ind,1)>1; keyboard; end;
    end
    IndRemove(Ind,:)=[];
    Ind=Wave1.Properties.RowNames(Ind,1);
    iFileChanger('W.G.Fileinfo(Q1,:)',[],{'Q1',IndRemove});
end

% get info on specific file
if Report==1
    Wave1=struct2table(dir(PathRaw));
    try
        Wave2=datenum(W.G.Fileinfo.Date(Ind),'yyyy.mm.dd HH:MM:SS')-datenum('2018.01.02 12:23:00','yyyy.mm.dd HH:MM:SS');
    catch
        Wave2=-1;
    end
    if isempty(Ind) || Wave1.datenum ~= W.G.Fileinfo.Datenum(Ind) || strfind1(W.G.Fileinfo.DoGetFileinfo(Ind),'Do#Go|') || Wave2<0 % || datenum(W.G.Fileinfo.Date(Ind),'yyyy.mm.dd HH:MM:SS')<datenum('2015.10.12 12:41:00','yyyy.mm.dd HH:MM:SS') % if newer version of file is present
        [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application);
    end
elseif Report==0
    if isempty(Application)==0
        [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application);
    end
end

evalin('caller','global W;');
