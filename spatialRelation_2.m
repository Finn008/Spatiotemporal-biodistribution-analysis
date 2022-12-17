function [FileList,TimeList,Output]=spatialRelation_2(Filename,ReferenceFilenameGlobal)
global W;
F=W.G.T.F{W.Task};
FileId=strfind1(W.G.T.F{W.Task}.Filename,Filename,1);
Wave1=eval(['{''',regexprep(F.Family{FileId},';',''';'''),'''}']);

Wave1=strfind1(F.Family,Wave1{1});
FileList=table;
FileList.Filename=F.Filename(Wave1);
FileList.Time=F.TargetTimepoint(Wave1);
FileList.MouseId=F.MouseId(Wave1);
FileList.Rotate=F.Rotate(Wave1);
FileList.Family=F.Family(Wave1);
try; FileList.Relation=F.Relation(Wave1); end;
FileList.Family(:,1)={'96b'};
FileList.Relation(1:17,1)=1;
FileList.Relation(18:end,1)=2;

% FileList.Family(1:17,1)={'96b'};
% FileList.Family(18:end,1)={'97a;96b'};


MouseId=FileList.MouseId(1);
MouseInfo=W.G.T.F2{W.Task};
MouseInfo=MouseInfo(MouseInfo.MouseId==MouseId,:);

global AllFiles;
if isempty(AllFiles)
    AllFiles=table;
    for m=1:size(W.G.PathRaw,1)
        Wave1=listAllFiles(W.G.PathRaw.Path{m});
        if size(Wave1,1)>0
            AllFiles(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;
        end
    end
end



% go through all files
for File=1:size(FileList,1)
    Wave1=eval(['{''',regexprep(FileList.Family{File},';',''';'''),'''}']);
    FileList.Family(File,1:size(Wave1,1))=Wave1.';
    Wave1=strfind1(AllFiles.FilenameTotal,FileList.Filename{File});
    FileList.Siblings(File,1)={AllFiles.FilenameTotal(Wave1)};
    FileList.Fileinfo(File,1)={getFileinfo_2([FileList.Filename{File,1},'.ims'])};
end

% identify Trace file
TraceFamily=FileList.Family{1,1};
FilenameTrace=[W.G.T.TaskName{W.Task},'_M',num2str(MouseId),'_',TraceFamily,'_Trace.ims'];
FileinfoTrace=getFileinfo_2(FilenameTrace);
MultiDimInfo=FileinfoTrace.Results{1}.MultiDimInfo;




% go through Rel1 files (that are traced over time)
for File=find(FileList.Relation==1).'
    Timepoint=FileList.Time(File);
%     FileList.FitCoefTrace2B(File,1)={-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs};
    FileList.Rel1toFirstRel1(File,1)={-MultiDimInfo.MetBlue{Timepoint,1}.U.FitCoefs};
%     FileList.RotateTrace2B(File,1)={MultiDimInfo.MetBlue{Timepoint,1}.Rotate};
    % find connected files
    Table=table;
%     Wave1=find(FileList.Time<FileList.Time(File) & strcmp(FileList.Family(:,1),FileList.Family(File,1)));
    Wave1=find(FileList.Time<FileList.Time(File) & FileList.Relation==1); [~,Wave2]=max(FileList.Time(Wave1));
    Table(end+1,{'Relation';'Filename'})=[{'Before'},{FileList.Filename(Wave1(Wave2))}];
    
%     Wave1=find(FileList.Time>FileList.Time(File) & strcmp(FileList.Family(:,1),FileList.Family(File,1)));
    Wave1=find(FileList.Time>FileList.Time(File) & FileList.Relation==1); [~,Wave2]=min(FileList.Time(Wave1));
    Table(end+1,{'Relation';'Filename'})=[{'After'},{FileList.Filename(Wave1(Wave2))}];
    
%     Wave1=find(FileList.Time==FileList.Time(File) & strcmp(FileList.Family(:,2),FileList.Family(File,1)));
    Wave1=find(FileList.Time==FileList.Time(File) & FileList.Relation==2);
    Table(end+1,{'Relation';'Filename'})=[{'Synchron'},{FileList.Filename(Wave1)}];
    Table(isempty_2(Table.Filename),:)=[];
    %     Synchron=FileList.Filename(Wave1);
    
    FileList.Connected(File,1)={Table};
end



% go through other files
 for File=find(FileList.Relation==2).'
%     FollowerFilename=FileList.Filename{find(FileList.Time==FileList.Time(File) & strcmp(FileList.Family(:,1),FileList.Family(File,2)))};
    ReferenceFilename=FileList.Filename{find(FileList.Time==FileList.Time(File) & FileList.Relation==1)};
    FollowerFilename=FileList.Filename{File};
    Wave1=find(strcmp(W.G.Driftinfo.Ffilename,FollowerFilename)&strcmp(W.G.Driftinfo.Rfilename,ReferenceFilename));
    FileList.Rel2toRel1(File,1)={W.G.Driftinfo.Results{Wave1}.FitCoefs};
    Wave1=find(strcmp(W.G.Driftinfo.Ffilename,ReferenceFilename)&strcmp(W.G.Driftinfo.Rfilename,FollowerFilename));
    FileList.Rel1toRel2(File,1)={W.G.Driftinfo.Results{Wave1}.FitCoefs};
% %     FileList.RotateTrace2A(File,1)=FileList.Rotate(File,1);
    
% % %     % find connected files
% % %     Wave1=find(FileList.Time==FileList.Time(File) & strcmp(FileList.Family(:,1),FileList.Family(File,2)));
% % %     Table=table; Table(end+1,{'Relation';'Filename'})=[{'Synchron'},{FileList.Filename(Wave1)}];
% % %     FileList.Connected(File,1)={Table};
end
% % % FileList.SumCoef=FileList.FitCoefTrace2B;
if exist('ReferenceFilenameGlobal','Var')==0 || isempty(ReferenceFilenameGlobal)
    ReferenceFilenameGlobal=FileList.Filename{FileList.Time==1&FileList.Relation==1};
end

IndGlobal=find(strcmp(FileList.Filename,ReferenceFilenameGlobal));
FileList.SumCoef(IndGlobal,1)={[0,0,0;0,0,0;0,0,0]};
FileChecklist=FileList.Connected{IndGlobal};
% FileChecklist.Original(:,1)={Filename};
for m=1:9999999
    if max(isempty_2(FileList.SumCoef))==0 || m>200; break; end;
    
%     Filename2=FileChecklist.Filename{1};
% % %     if isempty(FileChecklist.Filename{1}); FileChecklist(1,:)=[]; continue; end;
    IndSource=find(strcmp(FileList.Filename,FileChecklist.Filename{1}));
    if isempty(FileList.SumCoef{IndSource})
%         IndOrig=find(strcmp(FileList.Filename,FileChecklist.Original{1}));
        if strcmp(FileChecklist.Relation{1},'Before')
            SumCoef=FileList.Rel1toFirstRel1{IndSource}-FileList.Rel1toFirstRel1{IndGlobal};
%             SumCoef=-FileList.FitCoefTrace2B{Ind};
            FileList.SumCoef(IndSource,1)={SumCoef};
        elseif strcmp(FileChecklist.Relation{1},'After')
            SumCoef=-FileList.Rel1toFirstRel1{IndSource}+FileList.Rel1toFirstRel1{IndGlobal};
%             SumCoef=-FileList.FitCoefTrace2B{Ind};
            FileList.SumCoef(IndSource,1)={SumCoef};
        elseif strcmp(FileChecklist.Relation{1},'Synchron')
            IndRel1=find(FileList.Time==FileList.Time(IndSource) & FileList.Relation==1);
%             SumCoef=FileList.SumCoef{IndOrig}-FileList.FitCoefB2A{Ind};
            SumCoef=FileList.SumCoef{IndRel1}+FileList.Rel2toRel1{IndSource};
            FileList.SumCoef(IndSource,1)={SumCoef};
        end
%         Wave1=FileList.Connected{Ind}; Wave1.Original(:,1)={FileChecklist.Filename{1}};
%         FileChecklist=[FileChecklist;Wave1];
        FileChecklist=[FileChecklist;FileList.Connected{IndSource}];
    end
    FileChecklist(1,:)=[];
    
end

%% calculate MinMax range of each file in comparison to reference file

for File=1:size(FileList,1)
    Fileinfo=FileList.Fileinfo{File};
    UmMinMax=[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}].';
    
    [UmMinMax]=applyDriftCorrection(UmMinMax,FileList.SumCoef{File});
    FileList.UmMinMax(File,1:6)=UmMinMax(:).';
    
end

UmMinMaxTotal=[min(FileList.UmMinMax(:,[1;3;5]),[],1).',max(FileList.UmMinMax(:,[2;4;6]),[],1).'];

Output=struct;
Output.UmMinMaxTotal=UmMinMaxTotal;

TimeList=FileList(find(FileList.Relation==1),{'MouseId';'Time';'Filename';'Family';'Rotate';'Rel1toFirstRel1';'SumCoef'});
IndSource=find(FileList.Relation==2);
IndTarget=FileList.Time(IndSource);
TimeList.Filename(IndTarget,2)=FileList.Filename(IndSource);
TimeList.Rotate(IndTarget,2)=FileList.Rotate(IndSource);
TimeList.SumCoef(IndTarget,2)=FileList.SumCoef(IndSource);
TimeList.Rel2toRel1(IndTarget,1)=FileList.Rel2toRel1(IndSource);
TimeList.Rel1toRel2(IndTarget,1)=FileList.Rel1toRel2(IndSource);
TimeList.FilenameTrace(:,1)={FilenameTrace};
TimeList.FilenameRel1(:,1)=strcat(TimeList.Filename(:,1),{'.ims'});
TimeList.FilenameRatioB(:,1)=strcat(TimeList.Filename(:,1),{'_Ratio.ims'});
TimeList.FilenameDeFinB(:,1)=strcat(TimeList.Filename(:,1),{'_DeFin.ids'});
TimeList.FilenameRel2(IndTarget,1)=strcat(FileList.Filename(IndSource),{'.ims'});
TimeList.FilenameRatioA(IndTarget,1)=strcat(FileList.Filename(IndSource),{'_Ratio.ims'});
TimeList.FilenameDeFinA(IndTarget,1)=strcat(FileList.Filename(IndSource),{'_DeFin.ids'});


