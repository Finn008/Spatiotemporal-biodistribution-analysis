function [Out]=getXlsCell_2(Sheet,MyExcel,ColumnNames,Rows)

Table=xlsActxGet(MyExcel,Sheet,1);
Columns=strfind1(Table.Properties.VariableNames.',ColumnNames);
% MySheet  = MyExcel.ActiveWorkBook.Sheets.Item(Sheet);
% if ischar(Range)
%     if strcmp(Range,'All')
%         keyboard;
%         [Rows,Cols]=getXlsUsedRange(MyExcel,Sheet);
%         Range=[1,Rows;1,Cols];
%     end
% end
% Clock=datenum(now);
% Out=Table(Rows,Columns);
Out=table;
for Col=1:size(Columns,1)
    for Row=1:size(Rows,1)
        ColID=Columns(Col);
        RowID=Rows(Row);
        Wave1=[num2abc(ColID),num2str(RowID)];
        Cellinfo=MyExcel.Run('getCellInfo',RowID,ColID,Sheet);
        Cellinfo=cell2table(Cellinfo(2:end,:),'VariableNames',Cellinfo(1,:));
%         Cellinfo.Properties.VariableNames=XlsCellinfo(1,:);
        Out(Row,ColumnNames(Col))={{Cellinfo}};
%         if Clock+(1/24/60)<datenum(now)
%             disp([clock,' col:',num2str(Mcol),', row:',num2str(Mrow)]);
%             Clock=datenum(now);
%         end
    end
end

%% code to get cell info
% Sub Test()
% Test1 = getCellInfo(1, 1, 1)
% End Sub
% Function getCellInfo(Row As Variant, Col As Variant, Sheet As Variant)
% ActiveWorkbook.Sheets(Sheet).Activate ' activate Voc sheet
% Text = Cells(Col)(Row).Text
% TextLength = Len(Cells(Col)(Row))
% Dim Cellinfo() As Variant
% ReDim Cellinfo(TextLength, 15)
% Cellinfo(0, 0) = "Text"
% Cellinfo(0, 1) = "Background"
% Cellinfo(0, 2) = "Bold"
% Cellinfo(0, 3) = "ColorR"
% Cellinfo(0, 4) = "ColorG"
% Cellinfo(0, 5) = "ColorB"
% Cellinfo(0, 6) = "Colorindex"
% Cellinfo(0, 7) = "FontStyle"
% Cellinfo(0, 8) = "Italic"
% Cellinfo(0, 9) = "Name"
% Cellinfo(0, 10) = "Size"
% Cellinfo(0, 11) = "Strikethrough"
% Cellinfo(0, 12) = "Subscript"
% Cellinfo(0, 13) = "Underline"
% Cellinfo(0, 14) = "TintAndShade"
% Cellinfo(0, 15) = "ThemeFont"
%
% For m = 0 To TextLength - 1
%     Text = Cells(Col)(Row).Characters(m + 1, 1).Text
%     Background = Cells(Col)(Row).Characters(m + 1, 1).Font.Background
%     Bold = Cells(Col)(Row).Characters(m + 1, 1).Font.Bold
%     ColorOut = Cells(Col)(Row).Characters(m + 1, 1).Font.Color
%     Colorindex = Cells(Col)(Row).Characters(m + 1, 1).Font.Colorindex
%     FontStyle = Cells(Col)(Row).Characters(m + 1, 1).Font.FontStyle
%     Italic = Cells(Col)(Row).Characters(m + 1, 1).Font.Italic
%     Name = Cells(Col)(Row).Characters(m + 1, 1).Font.Name
%     Size = Cells(Col)(Row).Characters(m + 1, 1).Font.Size
%     Strikethrough = Cells(Col)(Row).Characters(m + 1, 1).Font.Strikethrough
%     Subscript = Cells(Col)(Row).Characters(m + 1, 1).Font.Subscript
%     Underline = Cells(Col)(Row).Characters(m + 1, 1).Font.Underline
%     'ThemeColorOut = Cells(Col)(Row).Characters(m + 1, 1).Font.ThemeColor
%     TintAndShade = Cells(Col)(Row).Characters(m + 1, 1).Font.TintAndShade
%     ThemeFont = Cells(Col)(Row).Characters(m + 1, 1).Font.ThemeFont
%
%     Cellinfo(m + 1, 0) = Text
%     Cellinfo(m + 1, 1) = Background
%     Cellinfo(m + 1, 2) = Bold
%     Cellinfo(m + 1, 3) = ColorOut Mod 256
%     Cellinfo(m + 1, 4) = (ColorOut \ 256) Mod 256
%     Cellinfo(m + 1, 5) = ColorOut \ 65536
%     Cellinfo(m + 1, 6) = Colorindex
%     Cellinfo(m + 1, 7) = FontStyle
%     Cellinfo(m + 1, 8) = Italic
%     Cellinfo(m + 1, 9) = Name
%     Cellinfo(m + 1, 10) = Size
%     Cellinfo(m + 1, 11) = Strikethrough
%     Cellinfo(m + 1, 12) = Subscript
%     Cellinfo(m + 1, 13) = Underline
%     Cellinfo(m + 1, 14) = TintAndShade
%     Cellinfo(m + 1, 15) = ThemeFont
% Next
% getCellInfo = Cellinfo
%
% End Function
%
% ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
% '   Function            Color
% '   Purpose             Determine the Background Color Of a Cell
% '   @Param rng          Range to Determine Background Color of
% '   @Param formatType   Default Value = 0
% '                       0   Integer
% '                       1   Hex
% '                       2   RGB
% '                       3   Excel Color Index
% '   Usage               Color(A1)      -->   9507341
% '                       Color(A1, 0)   -->   9507341
% '                       Color(A1, 1)   -->   91120D
% '                       Color(A1, 2)   -->   13, 18, 145
% '                       Color(A1, 3)   -->   6
% ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
% Function Color(rng As Range, Optional formatType As Integer = 0) As Variant
%     Dim colorVal As Variant
%     colorVal = Cells(rng.Row, rng.Column).Interior.Color
%     Select Case formatType
%         Case 1
%             Color = Hex(colorVal)
%         Case 2
%             Color = (colorVal Mod 256) & ", " & ((colorVal \ 256) Mod 256) & ", " & (colorVal \ 65536)
%         Case 3
%             Color = Cells(rng.Row, rng.Column).Interior.Colorindex
%         Case Else
%             Color = colorVal
%     End Select
% End Function

