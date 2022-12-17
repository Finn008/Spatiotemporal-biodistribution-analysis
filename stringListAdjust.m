
% stringListAdjust({'D:\Finn\MatlabExport.xlsx';1},{'D:\Finn\MatlabExport.xlsx';2},{'D:\Finn\MatlabExport.xlsx';3})
function stringListAdjust(Data1,Data2,Output)


[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Data1{1});
Data1=array2table(xlsActxGet(Workbook,Data1{2}));

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Data2{1});
% Data2=xlsActxGet(Workbook,Data2{2});
Data2=array2table(xlsActxGet(Workbook,Data2{2}));
Data3=Data1;
% IndRemove=zeros(size(Data2,1),1);
for m=1:size(Data1,1)
    Ind=strfind1(Data2.Var1(:,1),Data1.Var1(m,1),1);
    if Ind==0
        Data3.Var3(m,1)={'NotFound'};
        Data3.Var4(m,1)={'NotFound'};
%         Data3(m,{'Var1','Var2'})={'NotFound','NotFound'};
    else
        Data3.Var3(m,1)=Data2.Var1(Ind);
        Data3.Var4(m,1)=Data2.Var2(Ind);
%         Data3(m,3:4)=Data2(Ind,1:2);
        Data2.Remove(Ind,1)=1;
    end
end
Data2=Data2(Data2.Remove==0,:);
    
for m=1:size(Data2,1)
    Data3.Var1(end+1,1)={'NotFound'};
    Data3.Var2(end,1)={'NotFound'};
    Data3.Var3(end,1)=Data2.Var1(m);
    Data3.Var4(end,1)=Data2.Var2(m);
end

Ind=strfind1(Data3.Var3,'NotFound',1);
Data3=[Data3;Data3(Ind,:)];
Data3(Ind,:)=[];

for m=1:size(Data3,1)
   Data3.Equality(m,1)=isequal(Data3.Var2(m),Data3.Var4(m));
end

xlsActxWrite(Data3,Workbook,Output{2,1},[],'DeleteOnlyContent');
Excel.Visible = 1;
