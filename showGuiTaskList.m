function showGuiTaskList()
global W;
handles = findall(0,'type','figure','Name','controlGUI_2');
handles=guidata(handles(1,1));
if isempty(W.G.TaskList)
    set(handles.uitable8,'Data',[]);
    Data=table;
else
    Table={'Task',0,30;...
        'Filename',0,250;...
        'Dofunction',0,80;...
        'Status',1,50;...
        'Restriction',0,60;...
        'Clock',0,80;...
        'Duration',0,60;...
        'Slave',0,'auto';...
        'Error',0,100};
    Table=cell2table(Table,'VariableNames',{'Name','Editable','Width'});
    Table.Editable=logical(Table.Editable);
    
    Data=W.G.TaskList(:,Table.Name);
    Data.Duration=round2digit(Data.Duration);
    
    [Wave1]=taskRestrictor();
    Data.Restriction=Wave1.RestrictionList;
    
    
    ColumnNames=Data.Properties.VariableNames.';
    set(handles.uitable8,'Data',table2cell(Data),'ColumnName',ColumnNames);
    set(handles.uitable8,'ColumnEditable',Table.Editable.');
    set(handles.uitable8,'ColumnWidth',Table.Width.');
    
end