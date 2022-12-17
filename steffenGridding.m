function steffenGridding()
DataPath='\\GNP90N\share\Finn\Raw data\TiffSeries\';
% FileList={'Steffen_astro_C01';};
[FileList]=listAllFiles(DataPath,1);
for FileId=14:size(FileList,1)
    Filename=FileList.FilenameTotal{FileId};
    Path2file=[DataPath,Filename];
    % global Data3D;
    [Table]=listAllFiles(Path2file);
    Table=Table(strfind1(Table.FilenameTotal,'.tif'),:);
    
    % load tif series in 3D volume
    clear Data3D;
    for m=1:size(Table,1)
        Path=Table.Path2file{m};
        Wave1=imread(Path);
        Data3D(:,:,m)=Wave1;
    end
    
    % divide by 16,8,4
    Pix=size(Data3D).';
    GridBinning=[32;64];
    for m=1:size(GridBinning,1)
        Result=zeros(0,size(Data3D,3));
        for X=1:Pix(1)/GridBinning(m)
            for Y=1:Pix(2)/GridBinning(m)
                Cut=[(X-1)*GridBinning(m)+1,(Y-1)*GridBinning(m)+1;X*GridBinning(m),Y*GridBinning(m)];
                Chunk=Data3D(Cut(1,1):Cut(2,1) , Cut(1,2):Cut(2,2) , :);
                %             Chunk=Data3D((X-1)*16+1:X*16 , (Y-1)*16+1:Y*16 , :);
                Mean=permute(mean(mean(Chunk,1),2),[1,3,2]);
                Result(size(Result,1)+1,:)=Mean;
            end
        end
        EndResult{m,1}=Result;
    end
    
    
    OutputPath=['\\GNP90N\share\Finn\Analysis\output\Unsorted\',Filename,'.xlsx'];
    
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
    for m=1:size(GridBinning,1)
        xlsActxWrite(EndResult{m,1},Workbook,num2str(GridBinning(m,1)));
    end
    Workbook.Save;
    Workbook.Close;
    % invoke(Workbook,'SaveAs','OutputPath');
    % invoke(Workbook,'Close');
end


