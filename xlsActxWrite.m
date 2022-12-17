function xlsActxWrite(Input,Workbook,Sheet,Range,Delete,Quit,Format)

if ischar(Workbook)
   [Excel,Workbook]=connect2Excel(Workbook); 
end

if ischar(Sheet)
    OriginalSheetName=regexprep(Sheet,'\W','');
    if size(OriginalSheetName,2)>31
        OriginalSheetName=OriginalSheetName(1,1:31);
    end
    
    SheetNumber = Workbook.sheets.count;
    for m =1:SheetNumber
        SheetNames{m,1}=Workbook.sheets.Item(m).name;
    end
    Sheet=strfind1(SheetNames,OriginalSheetName,1);
    if Sheet==0
        % find empty sheets
        EmptySheets=strfind1(SheetNames,'Tabelle');
        if EmptySheets==0
            invoke(Workbook.Sheets,'Add');
            for m =1:SheetNumber
                SheetNames{m,1}=Workbook.sheets.Item(m).name;
            end
            EmptySheets=strfind1(SheetNames,'Tabelle');
        end
        Sheet=EmptySheets(end);
        
        Workbook.sheets.Item(Sheet).name=OriginalSheetName;
    end
end

try
    Workbook.sheets.Item(Sheet).UsedRange.AutoFilter;
    Workbook.sheets.Item(Sheet).UsedRange.AutoFilter;
end

if istable(Input)
    [Input]=table2cell_2(Input);
elseif isnumeric(Input)
    Input=num2cell(Input); % otherwise NaN values are transferred to 65535
end
if exist('Delete')==1
    if strcmp(Delete,'Delete')
        Workbook.sheets.Item(Sheet).UsedRange.Delete;
    elseif strcmp(Delete,'DeleteOnlyContent')
        
        Wave1=Workbook.sheets.Item(Sheet).UsedRange.Columns.Count;
        Wave2=Workbook.sheets.Item(Sheet).UsedRange.Rows.Count;
        set(Workbook.sheets.Item(Sheet).UsedRange, 'Value', cell(Wave2,Wave1));
    end
end

RowNumber=size(Input,1);
ColNumber=size(Input,2);
if RowNumber==0 || ColNumber==0
    return;
end
if exist('Range')~=1 || isempty(Range)
    Range=['A1:',num2abc(ColNumber),num2str(RowNumber)];
else
    Range=[num2abc(Range(1,2)),num2str(Range(1,1)),':',num2abc(Range(end,2)),num2str(Range(end,1))];
end

Range = get(Workbook.sheets.Item(Sheet),'Range',Range);
set(Range, 'Value', Input);

Borders = get(Range, 'Borders');
set(Borders, 'ColorIndex', 1);
set(Borders, 'LineStyle', 1);
if exist('Format')
%     keyboard;
    Wave1=find(strcmp(Format,'Bold'));
    [X,Y]=ind2sub(size(Format),Wave1);
    for m=1:size(X,1)
        Range=[num2abc(Y(m)),num2str(X(m))];
        Workbook.ActiveSheet.Range(Range).Font.Bold = 1;
%         
%         Range = get(Workbook.sheets.Item(Sheet),'Range',Range);
%         Borders = get(Range, 'Borders');
%         set(Borders, 'ColorIndex', 3);
%         set(Borders, 'LineStyle', 2);
    end
end
% Selection.Borders.Item('xlDiagonalDown').LineStyle = xlNone 
%% colorize
%RED = 0000FF
%BLUE= FF00FF
%GREEN=00FF00
%BLACK=000000
%WHITE=FFFFFF

if exist('Quit')==1 && isempty(Quit)==0
    try; Workbook.Names.Item('_FilterDatabase').Delete(); end; % to avoid name conflict problem
    Workbook.Save;
    Workbook.Close;
    delete(Workbook);
end
