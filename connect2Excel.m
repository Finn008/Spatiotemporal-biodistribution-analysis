function [Excel,Workbook,SheetNames,SheetNumber,Out]=connect2Excel(Path2file)

for m=1:2
    try % Check if an Excel server is running
        Excel = actxGetRunningServer('Excel.Application'); % If Excel is not running, "actxGetRunningServer" will result in error
        Workbooks=Excel.Workbooks;
        WorkbookNumber=Excel.Workbooks.Count;
        for m = 1:WorkbookNumber % get the names of all open Excel files
            if strcmpi(Path2file,Excel.Workbooks.Item(m).FullName)
                %Workbooks.Item(m).Save % save changes
                %Workbooks.Item(ii).SaveAs(filename) % save changes with a different file name
                %Workbooks.Item(ii).Saved = 1; % if you don't want to save
                %Workbooks.Item(m).Close; % close the Excel file
                Workbook=Excel.Workbooks.Item(m);
                break
            end
        end
        
    catch Error % open new
        
        %     Workbook = Excel.Workbooks.Open(Path2file);
        %         Excel = actxserver('Excel.Application');
        %     try; Workbook.Names.Item('_FilterDatabase').Delete(); end; % to avoid name conflict problem
    end
    if exist('Workbook')==1
        break;
    else
        try
            winopen(Path2file);
            pause(0.5);
        catch
%             Workbook = invoke(Excel.Workbooks,'Add');
%             invoke(Workbook, 'SaveAs', Path2file);
            xlswrite(Path2file,0);
            winopen(Path2file);
        end
    end
end
% if exist('Workbook')~=1
%     keyboard;
% end
SheetNumber = Workbook.sheets.count;

for m =1:SheetNumber;
    SheetNames{m,1}=Workbook.sheets.Item(m).name;
end

Out.Excel=Excel;
Out.Workbook=Workbook;
Out.WorkbookNumber=WorkbookNumber;
Out.SheetNumber=SheetNumber;
Out.SheetNames=SheetNames;

