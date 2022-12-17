function Table=finalEvaluation_ShowImagingTimepoints(MouseInfo)
FileVersion='A';

Table=table;
for Mouse=1:size(MouseInfo,1)
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    if isnan(RoiInfo.Roi(1)); continue; end;
    for Roi=1:floor(max(RoiInfo.Roi))
        IndAdd=size(Table,1)+1;
        Table.MouseId(IndAdd,1)=MouseInfo.MouseId(Mouse);
        Table.TreatmentType(IndAdd,1)=MouseInfo.TreatmentType(Mouse);
        Table.StackB(IndAdd,1)=RoiInfo.StackB(Roi);
        Table.StackA(IndAdd,1)=RoiInfo.StackA(Roi);
        StartTreatmentNum=MouseInfo.StartTreatmentNum(Mouse);
        Table.TreatStart(IndAdd,1)=StartTreatmentNum/30.42;
        Ages=RoiInfo.Files{Roi}.Age;
        if strcmp(FileVersion,'A')
            Filenames=RoiInfo.Files{Roi}.Filenames;
            if size(Filenames,2)>1
                Wave1=isempty_2(Filenames(:,2));
                Ages(Wave1)=NaN;
            else
                Ages(:)=NaN;
            end
        end
        Ind=find(Ages>StartTreatmentNum,1)-1;
        Ages=[nan(7-Ind,1);Ages/30.42];
        Table.TimepointsB(IndAdd,1:size(Ages,1))=Ages.';
    end
end
Table.TimepointsB(Table.TimepointsB==0)=NaN;

PathExcelExport='\\GNP90N\share\Finn\Raw data\ImagingTimepoints.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

xlsActxWrite(Table,Workbook,['Age',FileVersion],[],'DeleteOnlyContent');
Workbook.Save;
Workbook.Close;
