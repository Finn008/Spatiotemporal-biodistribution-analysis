function Table=exchangeVariableName(Table,Old,New)

VariableNames=Table.Properties.VariableNames.';
VariableNames=strrep(VariableNames,Old,New);
Table.Properties.VariableNames=VariableNames;