function [FileList]=listAllFilesWithSubfolders(Drives)

Drives.PathOrig=Drives.Path2folder;

FileList=table;
for DriveId=1:1000000000000
%     if strfind(Drives.Path2folder{DriveId},'\\GNP91N\share2\Finn\Eva\Lamp1'); keyboard; end;
%     Drives.Path2folder{m,1}=[Drives.Path2folder{m,1},'\BackupRawData'];
    Files2add=listAllFiles(Drives.Path2folder{DriveId},2);
    
%     Wave1=strfind1(Drives.Path2folder,'Adrian');
%     Wave1=strfind1(Files2add.FilenameTotal,'Adrian');
%     Wave1=strfind1(Files2add.FilenameTotal,'..');
%     if Wave1(1)~=0;
%         keyboard;
%     end
    
    Ind=find(Files2add.Isdir==1);
    
    Drives2add=table(Files2add.Path2file(Ind,1),'VariableNames',{'Path2folder'});
    Drives2add.PathOrig(1:size(Drives2add,1),1)=Drives.PathOrig(DriveId,1);
%     repmat(Drives.PathOrig(DriveId,1),)
    Drives(size(Drives,1)+1:size(Drives,1)+size(Drives2add,1),{'Path2folder','PathOrig'})=Drives2add;
%     Drives.Path2folder(size(Drives,1)+1:size(Drives,1)+size(Ind,1),1)=Files2add.Path2file(Ind,1);
    Files2add(Ind,:)=[];
    
    for m=1:size(Files2add,1)
        Files2add.Path2file2(m,1)={Files2add.Path2file{m,1}(size(Drives.PathOrig{DriveId},2)+2:end)};
    end
    
%     if DriveId==1
%         FileList=Files2add;
%     else
    if size(Files2add,1)>0
        FileList=[FileList;Files2add];
    end
%     end
    
    DriveId=DriveId+1;
    if DriveId>size(Drives,1)
        break
    end
end
% keyboard;