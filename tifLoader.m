function [Data3D,Outside]=tifLoader(Filename,BigData)
global W;
FileList=table;
Drives=W.G.ComputerInfo.Path2RawData(strcmp(W.G.ComputerInfo.Name,W.ComputerName),:).';
for Drive=1:size(Drives,1)
    FileList=[FileList;listAllFiles(Drives{Drive})];
end
FileList=FileList(strfind1(FileList.FilenameTotal,Filename),:);
FileList.TifInfo=regexprep(FileList.Filename,Filename,'');
% FileList(strncmp(FileList.TifInfo,'_T'),:)=[];
Wave1=~cellfun('isempty',strfind(FileList.TifInfo,'_T'));
Wave1(:,2)=~cellfun('isempty',strfind(FileList.TifInfo,'_C'));
Wave1(:,3)=~cellfun('isempty',strfind(FileList.TifInfo,'_Z'));
Wave1=min(Wave1,[],2);
FileList(Wave1==0,:)=[];

Table=table;
Table.Type={'_C';'_T';'_Z'};
Table.Properties.RowNames=Table.Type;
ErroneousFiles=[];
for File=1:size(FileList,1)
    tic
    for m=1:size(Table,1)
        Table.Pos(m,1)=strfind(FileList.TifInfo{File},Table.Type{m});
    end
    Table=sortrows(Table,'Pos','ascend');
    for m=1:size(Table,1)-1
        Table.Value(m,1)=str2num(FileList.TifInfo{File}(Table.Pos(m)+2:Table.Pos(m+1)-1));
    end
    Table.Value(m+1,1)=str2num(FileList.TifInfo{File}(Table.Pos(m+1)+2:end));
    try
        Image=imread(FileList.Path2file{File});
        if exist('Data3D','Var')==1
            Data3D(:,:,size(Data3D,3)+1)=Image;
%             Data3D(:,:,Table.Value('_Z'))=Image;
        else
            Data3D=Image;
        end
    catch
        ErroneousFiles=[ErroneousFiles;File];
    end
    disp(['File: ',num2str(File),' Time:  ',num2str(toc)]);
    if exist('BigData','Var') && BigData==1
        
        Wave1=whos('Data3D');
        if Wave1.bytes>50^9
            if exist('Path2Datastore','Var')~=1
                Path2Datastore=['D:\DataStore\',W.SlaveInstance,'_TifLoad.ims'];
                delete(Path2Datastore);
%                 h5create(Path2Datastore,'/DataSet',[size(Data3D,1),size(Data3D,2),Inf],'Datatype','single','Deflate',2,'ChunkSize',[size(Data3D,1),size(Data3D,2),1]);
                StartPaste=[1,1,1];
                Res=[1.3;1.3;1.3];
                [Application]=openImaris_4([size(Data3D,1);size(Data3D,2);size(FileList,1);0;1],Res,[],[],[],'single'); % class(Data5D)
                Application.FileSave(Path2Datastore,'writer="Imaris5"');
                quitImaris(Application);
            end
            
%             h5write('D:\DataStore\Test',datasetname,data,start,count);
%             Location=['/DataSet/ResolutionLevel ',num2str(ResLevel-1),'/TimePoint ',num2str(Timepoints(IndT)-1),'/Channel ',num2str(Channels(IndC)-1),'/Data'];
%             h5create(Path2file,Location,ResolutionLevels.MaxSize{ResLevel,1}.','Datatype',BitType,'ChunkSize',ResolutionLevels.ChunkSize{ResLevel,1}.','Deflate',GZIPcompression);
            
            ex2Imaris_2(Data3D,Path2Datastore,'XrayPhase',[],[],[],StartPaste);
%             h5write(Path2Datastore,'/DataSet',Data3D,StartPaste,size(Data3D));
            StartPaste(3)=StartPaste(3)+size(Data3D,3);
            clear Data3D;
%             h5write(Path2file,Location,Data3D,[1,1,1],size(Data3D));
        end
    end
    
end
keyboard;
[Data2D,~]=max(Data3D,[],3);
Min=prctile(Data2D(:),30);
Max=prctile(Data2D(:),90);
Data2D=(Data2D-Min)*(65535/(Max-Min));
Data2D=uint16(Data2D);
Path2file=getPathRaw([Filename,'_Crop.tif']);
imwrite(Data2D,Path2file);

% Path2file=regexprep(Path2file,'_Crop.tif','_Cropped.tif');

[Path2file,Report]=getPathRaw([Filename,'_Cropped.tif']);

if Report==0; keyboard; end;
Outside=imread(Path2file);
Outside=Outside(:,:,1)<128;

Ydim=min(Outside,[],1).';
Xdim=min(Outside,[],2);
Cut=[find(Xdim==0,1),size(Outside,1)-find(flip(Xdim)==0,1);find(Ydim==0,1),size(Outside,2)-find(flip(Ydim)==0,1)];

Data3D=Data3D(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),:);
% Min=prctile(Data3D_2(:),1);
Min=min(Data3D(:));
Max=prctile(Data3D(:),99);
Data3D=(Data3D-Min)*(65535/(Max-Min));

Outside=Outside(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2));

