function [NameTable,Out]=fileSiblings_2(FilenameTotal)

% original:     2014.04.08_38b.lsm
% for deconvolution:       2014.04.08_38b_4decon.ims or .ids
% after deconvolution:       2014.04.08_38b_DeFin.ids
% for deconvolution calibration:        2014.04.08_38b_4deCal.ims
% after deconvolution calibration:        2014.04.08_38b_CalFin.ids
% after putting series together:        38_DriftCorr.ims
% after refining drift in series:        38_Trace.ims

Type=FilenameTotal(end-3:end);

if strfind1(Type,{'.lsm';'.czi'},1)
    Sibling='Original';
    OriginalFilenameTotal=FilenameTotal;
end

if strfind1(FilenameTotal,'_4decon')
    Sibling='ForDecon';
    OriginalFilenameTotal=regexprep(FilenameTotal,'_4decon','');
end
if strfind1(FilenameTotal,'_DeFin')
    Sibling='DeFin';
    OriginalFilenameTotal=regexprep(FilenameTotal,'_DeFin','');
end
if strfind1(FilenameTotal,'_4deCal')
    Sibling='ForDeCal';
    OriginalFilenameTotal=regexprep(FilenameTotal,'_4deCal','');
end
if strfind1(FilenameTotal,'_CalFin')
    Sibling='CalFin';
    OriginalFilenameTotal=regexprep(FilenameTotal,'_CalFin','');
end
if strfind1(FilenameTotal,'_Ratio')
    Sibling='Ratio';
    OriginalFilenameTotal=regexprep(FilenameTotal,'_Ratio','');
end
if exist('Sibling')==0
    Sibling=[];
    NameTable=[];
    ImageGroup=[];
    return;
end

OriginalFilename=OriginalFilenameTotal(1:end-4);
% extract family name
[FamilyName]=extractStringPart(OriginalFilename,'FileFamilyName');
FamilyName=['M',FamilyName];

if strcmp(OriginalFilename(end),'a')
    ImageGroup='a';
elseif strcmp(OriginalFilename(end),'b')
    ImageGroup='b';
end

NameTable=table;
NameTable('Original','Filename')={{OriginalFilename}};
% get original type
[FileType]=getFileType(OriginalFilename,{'.lsm';'.czi'});
NameTable('Original','Type')={{FileType}};
% [~,Lsm]=getPathRaw([OriginalFilename,'.lsm']);
% [~,Czi]=getPathRaw([OriginalFilename,'.czi']);
% if Lsm==1
%     NameTable('Original','Type')={{'.lsm'}};
% elseif Czi==1
%     NameTable('Original','Type')={{'.czi'}};
% end
[Path,A1]=getPathRaw([OriginalFilename,FileType]);
SizeOriginal=dir(Path);SizeOriginal=SizeOriginal.bytes/1000000000;
if strcmp(FileType,'.lsm') && SizeOriginal<4
    NameTable('ForDecon',:)=NameTable('Original',:);
else
    NameTable('ForDecon','Filename')={{[OriginalFilename,'_4decon']}};
    NameTable('ForDecon','Type')={{'.ids'}};
end
    
    

% [FileType]=getFileType([OriginalFilename,'_4decon'],{'.ims';'.ids'});
% if isempty(FileType)
%     NameTable('ForDecon','Type')={{'.ims'}};
% else
%     NameTable('ForDecon','Type')={FileType};
% end

NameTable('DeFin','Filename')={{[OriginalFilename,'_DeFin']}};
NameTable('DeFin','Type')={{'.ids'}};

NameTable('Ratio','Filename')={{[OriginalFilename,'_Ratio']}};
NameTable('Ratio','Type')={{'.ims'}};

NameTable('ForDeCal','Filename')={{[OriginalFilename,'_4deCal']}};
NameTable('ForDeCal','Type')={{'.ids'}};
for m=0:8
    NameTable(['CalFin',num2str(m)],'Filename')={{[OriginalFilename,'_CalFin',num2str(m)]}};
    NameTable(['CalFin',num2str(m)],'Type')={{'.ids'}};
end

NameTable('DriftCorr','Filename')={{[FamilyName,'_DriftCorr']}};
NameTable('DriftCorr','Type')={{'.ims'}};

NameTable('Trace','Filename')={{[FamilyName,'_Trace']}};
NameTable('Trace','Type')={{'.ims'}};

%% to all
NameTable.FilenameTotal=strcat(NameTable.Filename,NameTable.Type);

for m=1:size(NameTable,1)
%     disp(m);
    [Wave1,Wave2,Wave3]=getPathRaw(NameTable.FilenameTotal{m,1});
    NameTable.Path2file{m,1}=Wave1;
    NameTable.Report(m,1)=Wave2;
    NameTable.Datenum(m,1)=Wave3;
end
Out=struct;    
Out.Sibling=Sibling;
Out.ImageGroup=ImageGroup;
Out.FamilyName=FamilyName;
