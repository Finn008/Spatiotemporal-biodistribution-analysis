function excelWriteSparse(Table,Workbook,Sheet,Type,Color)

if exist('Type')~=1
    Type='EachCell';
end

if exist('Color')~=1 || isempty(Color)
    Color=0;
end

SheetNumber = Workbook.sheets.count;
for m =1:SheetNumber
    SheetNames{m,1}=Workbook.sheets.Item(m).name;
end
if max(strcmp(SheetNames,Sheet))==0
    xlsActxWrite(Table,Workbook,Sheet,[],'Delete');
    return;
end
List=xlsActxGet(Workbook,Sheet,1);

% xlsActxWrite(Table{Row,Col},Workbook,Sheet,[TargetRow,TargetCol],'Red');
if strcmp(Type,'EachCell')
    for Row=1:size(Table,1)
        for Col=1:size(Table,2)
            ColId=Table.Properties.VariableNames{Col};
            TargetRow=Row+1;
            TargetCol=strfind1(List.Properties.VariableNames.',ColId,1);
            if Color==0
                xlsActxWrite(Table{Row,Col},Workbook,Sheet,[TargetRow,TargetCol]);
            else
                
                Range=[num2abc(TargetCol),num2str(TargetRow)];
%                 Workbook.ActiveSheet.Range(Range).Font.Bold = 1;
%                 Workbook.ActiveSheet.Range(Range).Interior.ColorIndex = 3;
                if Table{Row,Col}==1
                    Workbook.ActiveSheet.Range(Range).Font.ColorIndex = 0;
                elseif Table{Row,Col}==0
                    Workbook.ActiveSheet.Range(Range).Font.ColorIndex = 3;
                end
                    
%                 xlsActxWrite(Table{Row,Col},Workbook,Sheet,[TargetRow,TargetCol],[],[],'Red');
            end
        end
    end
elseif strcmp(Type,'WholeColumns')
    for Col=1:size(Table,2)
        ColId=Table.Properties.VariableNames{Col};
%         TargetRow=Row+1;
        TargetCol=strfind1(List.Properties.VariableNames.',ColId,1);
        xlsActxWrite(Table{:,Col},Workbook,Sheet,[2,TargetCol;size(Table,1)+1,TargetCol]);
    end
else
    keyboard;
end