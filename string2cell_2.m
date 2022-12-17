function [Table]=string2cell_2(In)

Cols=strfind(In,',').';
Rows=strfind(In,';').';

if isempty(Rows)
    Rows=size(In,2)+1;
else
%     keyboard;
end
Cols=sort([Cols;Rows]);
RowNumber=size(Rows,1);
ColNumber=size(Cols,1)/RowNumber;
Cols=[0;Cols;size(In,2)];
% Cols=reshape(Cols,ColNumber,RowNumber);
Ind=1;
for Row=1:RowNumber
    for Col=1:ColNumber
        Wave1=In(Cols(Ind)+1:Cols(Ind+1)-1);
        Wave2=str2num(Wave1);
        if isempty(Wave2)==0
            Wawe1=Wave2;
        end
        
        Table(Row,Col)={Wave1};
        Ind=Ind+1;
    end
end