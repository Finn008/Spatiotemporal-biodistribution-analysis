function backupSearch()
global W;

PathBackup='\\GNP90N\share\Finn\Analysis\backup';

FilesList=listAllFiles(PathBackup);
FilesList=sortrows(FilesList,'Datenum','descend');
FileinfoList=table;
for m=1:50:size(FilesList,1)
    disp(FilesList.FilenameTotal{m,1});
%     I=loadProject;
    I=load(FilesList.Path2file{m,1});
    Wave1=strfind1(I.I.G.Fileinfo.FilenameTotal,'X156_M346_94b_Trace.ims');
    if Wave1==0
        disp('not found');
        continue;
    end
    Fileinfo=I.I.G.Fileinfo(Wave1,:);
    VariableNames=Fileinfo.Properties.VariableNames;
    FileinfoList(end+1,VariableNames)=Fileinfo(1,VariableNames);
%     FileinfoList=[FileinfoList,Fileinfo];
%     if isnan(Fileinfo.Results{1})==0
%         keyboard;
%     end
end
keyboard;