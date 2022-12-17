function [Out,TextColor]=xlsActxGet(Workbook,Sheet,ColTitle,RowTitle,Excel,TextColor)


Out=Workbook.sheets.Item(Sheet).UsedRange.value;
if exist('TextColor')==1
    for Row=1:size(Out,1)
        for Col=1:size(Out,2)
            Wave1=[num2abc(Col),num2str(Row)];
% % % %             Wave2(Row,Col)=Excel.Range(Wave1).Characters.Font.Color;
            Wave2(Row,Col)=Workbook.sheets.Item(Sheet).Range(Wave1).Characters.Font.Color;
%             Workbook(Sheet).Range(Wave1).Characters.Font.Color;
%             Worksheets("Sheet1").Range("A1").Value = 3.14159
        end
    end
    Wave3= dec2bin(Wave2,24);
    TextColor=zeros(size(Out));
    TextColor(:,:,1)=reshape(bin2dec(Wave3(:,17:24)),size(Out)); % red
    TextColor(:,:,2)=reshape(bin2dec(Wave3(:,9:16)),size(Out)); % green
    TextColor(:,:,3)=reshape(bin2dec(Wave3(:,1:8)),size(Out)); % blue
%     Green=bin2dec(Wave3(:,9:16)); % green
%     Blue=bin2dec(Wave3(:,1:8)); % blue
else
    TextColor=[];
end




% Range.Interior.Color;
% cellColor = Range.Interior.Color;

if iscell(Out)==0
    Out=num2cell(Out);
end
% delete nan rows and cols at the end
DeleteNans=1;
if DeleteNans==1
    Wave1=isnan_2(Out);
    NanCol=min(Wave1,[],1).';
    if NanCol(end)==1
        NanCol=size(NanCol,1)-find(flip(NanCol)==0,1)+2;
        Out(:,NanCol:end)=[];
    end
    
    NanRow=min(Wave1,[],2);
    if NanRow(end)==1
        NanRow=size(NanRow,1)-find(flip(NanRow)==0,1)+2;
        Out(NanRow:end,:)=[];
    end
end

Table=Out;
if exist('ColTitle')==1 && ColTitle==1 && isempty(Out)==0
    Titles=Table(1,:);
    Out(1,:)=[];
    Out=cell2table(Out);
    Out.Properties.VariableNames=Titles;
end
if exist('RowTitle')==1 && RowTitle==1 && isempty(Out)==0
    Titles=Out{:,1};
    Out(:,1)=[];
    Out.Properties.RowNames=Titles;
end