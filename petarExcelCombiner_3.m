% Example input: petarExcelCombiner(4,707,2)
function petarExcelCombiner(Timepoints,Mouse,Areas,Path2Folder)

dbstop if error;
warning('off','all');
if exist('Path2Folder')~=1
    Path2Folder='\\gnp42n\marvin\AG Herms Share\Petar\Vika_ca_data\1013\';
end
ExcelOutputType=1;
InputFiles=listAllFiles(Path2Folder(1:end-1));
NewCell=1000;
for Ar=1:Areas
    %     clear CombinedData;
    CombinedData=cell(0,0);
    for Time=1:Timepoints;
        TimeVar=lower(num2abc(Time));
        Filepart=[TimeVar,num2str(Mouse),'area',num2str(Ar)];
        Ind=strfind1(InputFiles.FilenameTotal,Filepart);
        %         if Ind == 0;
        %             Time=Time+1;
        %         else
        try
            FilenameTotal=InputFiles.FilenameTotal{Ind,1};
            Path=InputFiles.Path2file{Ind,1};
            [Num,Txt,Raw]=xlsread(Path);
            Raw=Raw;
            VariableNames=Raw(1,:).';
            Raw(1,:)=[];
            Cells=cell2mat(Raw(:,2));
            Wave1=find(Cells==0);
            if isempty(Wave1)==0
                Raw(Wave1,2)=num2cell(NewCell:NewCell+size(Wave1,1)-1);
                %                 Cells(Wave1,1)=NewCell:NewCell+size(Wave1,1)-1;
                Cells=cell2mat(Raw(:,2));
                NewCell=NewCell+size(Wave1,1);
            end
            CombinedData(Cells,:,Time)=Raw(:,:);
            
        catch
            
        end
    end
    DataPerArea(Ar,1)={CombinedData};
end

OutputPath=[Path2Folder,num2str(Mouse),'.xlsx'];
if ExcelOutputType==1
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
end

for Ar=1:Areas
    try
        Wave1=DataPerArea{Ar,1}(:,2,:);
        Wave1=cell2mat(Wave1(:));
        Wave1=unique(Wave1(:));
        DataPerArea(Ar,1)={DataPerArea{Ar,1}(Wave1,:,:)};
        DataPerArea(Ar,2)={Wave1};
    end
end

for m=1:size(VariableNames,1)
    clear Wave1;
    for Ar=1:Areas
        try
            Data2Add=permute(DataPerArea{Ar,1}(:,m,:),[1,3,2]);
            Wave2=repmat({['Area',num2str(Ar)]},[size(Data2Add,1),1]);
            Wave3=num2cell(DataPerArea{Ar,2});
            Wave4=permute(DataPerArea{Ar,1}(:,3,:),[1,3,2]);
            for m3=1:size(Wave4,1)
                for m2=1:size(Wave4,2)
                    if isempty(Wave4{m3,m2})==0
                        Wave4(m3,1)=Wave4(m3,m2);
                        
                    end
                end
            end
            Data2Add=[Wave2,Wave3,Wave4(:,1),Data2Add];
            if Ar==1
                Wave1=Data2Add;
            else
%                 Wave1=[Wave1;Data2Add];
                Wave1(size(Wave1,1)+1:size(Wave1,1)+size(Data2Add,1),1:size(Data2Add,2))=Data2Add;
            end
        end
    end
    if ExcelOutputType==1
        xlsActxWrite(Wave1,Workbook,VariableNames{m,1},[],1);
    elseif ExcelOutputType==2
        xlswrite(OutputPath,Wave1,m);
    end
end

if ExcelOutputType==2
    winopen(OutputPath);
end



