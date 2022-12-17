function Arraystring = num2clip_2(Array)


if isnumeric(Array)
    Array=num2cell(Array);
end
if istable(Array)
    ColumnNames=Array.Properties.VariableNames;
    RowNames=Array.Properties.RowNames;
    Array=table2array(Array);
    if isnumeric(Array)
        Array=num2cell(Array);
    end
    if isempty(ColumnNames)==0
        Array=[ColumnNames;Array];
    end
    if isempty(RowNames)==0
        Array=[[{''};RowNames],Array]; % 22x13
    end
end

[Arraystring]=cell2delimitedString(Array);
Arraystring=char(Arraystring); %286x23
Arraystring = reshape(Arraystring',1,prod(size(Arraystring))); %reshape the array to a single line (1x3990)

clipboard('copy',Arraystring);
return;
if isnumeric(Array)
    %convert the numerical array to a string array
    %note that num2str pads the output array with space characters to account
    %for differing numbers of digits in each index entry
    Arraystring = num2str(Array); %21x189
    Arraystring(:,end+1) = char(10); %add a carrige return to the end of each row (21x190)
    %reshape the array to a single line
    %note that the reshape function reshape is column based so to reshape by
    %rows one must use the inverse of the matrix
    Arraystring = reshape(Arraystring',1,prod(size(Arraystring))); %reshape the array to a single line (1x3990)
    
    Arraystringshift = [' ',Arraystring]; %create a copy of arraystring shifted right by one space character (1x3991)
    Arraystring = [Arraystring,' ']; %add a space to the end of arraystring to make it the same length as arraystringshift (1x3991)
    
    %now remove the additional space charaters - keeping a single space
    %charater after each 'numerical' entry
    Arraystring = Arraystring((double(Arraystring)~=32 | double(Arraystringshift)~=32) & ~(double(Arraystringshift==10) & double(Arraystring)==32) ); % (1x2258)
    
    Arraystring(double(Arraystring)==32) = char(9); %convert the space characters to tab characters (1x2258)
end

