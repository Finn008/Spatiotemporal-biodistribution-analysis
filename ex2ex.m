function ex2ex(Data)
DefaultPath='\\mitstor8.srv.med.uni-muenchen.de\ZNP-User\fipeter\Desktop\';
[PathName] = uigetdir(DefaultPath);
PathName=[PathName,'\MatlabExport.xlsx'];

MyExcel    = actxserver('Excel.Application');
MyExcel.Visible = 1;
Workbook = MyExcel.Workbooks.Open(PathName);
MySheet  = MyExcel.ActiveWorkBook.Sheets.Item(1);
MySheet.Cells.Clear;

Range=['A1:',num2abc(size(Data,2)),num2str(size(Data,1))];
if istable(Data);
    Range=['A1:',num2abc(size(Data,2)),num2str(size(Data,1)+1)];
    Fields=Data.Properties.VariableNames;
    Data=[Fields;table2cell(Data)];
end
ActivesheetRange= get(MySheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);


% MyExcel.ActiveWorkBook.Sheets.Item(1).set(data); 
% xlswrite(PathName,data);