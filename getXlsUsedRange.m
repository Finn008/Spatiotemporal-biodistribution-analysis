function [Row,Col]=getXlsUsedRange(MyExcel,Sheet)
UsedRange = MyExcel.ActiveWorkBook.Sheets.Item(Sheet).UsedRange.Address;
UsedRange=strrep(UsedRange,'$','');
UsedRange=UsedRange(4:end);
Col=abc2num(UsedRange(1));
Row=str2num(UsedRange(2:end));