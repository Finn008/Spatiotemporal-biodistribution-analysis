function xlswrite_2(Path2File,Data,Sheet)


if istable(Data)
    VariableNames=Data.Properties.VariableNames;
    RowNames=Data.Properties.RowNames;
    if isempty(RowNames)
        Data=[VariableNames;table2cell(Data)];
    else
        Data=[[{'Rows'};RowNames],[VariableNames;table2cell(Data)]];
    end
end

try
    [~,~,Raw]=xlsread(Path2File);
    Raw(:)={[]};
    xlswrite(Path2File,Raw,Sheet);
end

xlswrite(Path2File,Data,Sheet);

