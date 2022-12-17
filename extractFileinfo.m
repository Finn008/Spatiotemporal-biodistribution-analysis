function [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application,QuitImaris)
global W;
if exist('QuitImaris')~=1
    if exist('Application')==1 && isempty(Application)==0
        QuitImaris=0;
    else
        QuitImaris=1;
    end
end
if iscell(FilenameTotal)
    FilenameTotal=FilenameTotal{1};
end
[PathRaw,Report]=getPathRaw(FilenameTotal);
GeneralFileinfo=struct2table(dir(PathRaw));
if isempty(GeneralFileinfo) % what happens if ImarisInfo has to be extracted but no  file present yet under PathRaw (from merge3D)
    GeneralFileinfo=table;
    GeneralFileinfo.name=FilenameTotal;
    GeneralFileinfo.date=datestr(0,'dd-mmm-yyyy HH:MM:SS');
    GeneralFileinfo.bytes=0;
    GeneralFileinfo.isdir=0;
    GeneralFileinfo.datenum=0;
end
[Ind]=strfind1(W.G.Fileinfo.FilenameTotal,FilenameTotal);
if Ind==0
    Ind=uniqueInd(W.G.Fileinfo,[1;8]);
    Fileinfo=emptyRow(W.G.Fileinfo(1,:));
else
    Ind=W.G.Fileinfo.Properties.RowNames{Ind};
    Fileinfo=W.G.Fileinfo(Ind,:);
end
%% set general data (before ims extract because othewise type not known for umStart and umEnd adjustment
Fileinfo.FilenameTotal{1}=GeneralFileinfo.name;
Fileinfo.Filename{1}=GeneralFileinfo.name(1:end-4);
Fileinfo.Type{1}=GeneralFileinfo.name(end-3:end);
Fileinfo.Date{1}=datestr(datenum(now),'yyyy.mm.dd HH:MM:SS');
Fileinfo.MB=GeneralFileinfo.bytes/1000000;
Fileinfo.Datenum=GeneralFileinfo.datenum; % set to  exactly same date as file save date, other wise if corrupt file is replaced by older correct one then Fileinfo would not be refreshed

if exist('Application')==1 && isempty(Application)==0
    [Fileinfo2add]=getImarisFileinfo(Application);
    if QuitImaris==1
        quitImaris(Application);
    end
elseif strfind1('.ims',Fileinfo.Type{1},1)
    [Fileinfo2add]=getHD5Fileinfo(FilenameTotal); % because objects not yet read out by getBFinfo
elseif strfind1({'.ids';'.lsm';'.czi'},Fileinfo.Type{1},1)
    [Fileinfo2add,ZenInfo,OmeMetaData,OriginalMetaData]=getBFinfo(FilenameTotal);
    if isempty(ZenInfo)==0; Fileinfo.Results{1}.ZenInfo=ZenInfo; end
    Fileinfo.Results{1}.OmeMetaData=OmeMetaData;
    Fileinfo.Results{1}.OriginalMetaData=OriginalMetaData;
else
    keyboard;
end

Fileinfo=combine2tables(Fileinfo,Fileinfo2add);
Fileinfo.DoGetFileinfo{1}='Do#Done|';

iFileChanger('W.G.Fileinfo(Q1,:)',Fileinfo,{'Q1',Ind});

FileinfoInd=Ind;