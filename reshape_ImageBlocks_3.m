function Data2=reshape_ImageBlocks_3(Data,Rows)

Pix=size(Data,2);
ImageNumber=size(Data,1)/Pix;
Table=table;
for m=1:ImageNumber
    Table.CutPix(m,1:2)=[(m-1)*Pix+1,m*Pix];
    Paste=[m-floor((m/Rows-0.0001))*Rows,ceil(m/Rows)];
    Table.PastePosXY(m,1:2)=Paste;
    Paste=(Paste-1)*Pix+1;
    Paste(2,:)=Paste(1,:)+Pix-1;
    Table.PastePixX(m,1:2)=Paste(1:2,1).';
    Table.PastePixY(m,1:2)=Paste(1:2,2).';
    Data2(Table.PastePixX(m,1):Table.PastePixX(m,2),Table.PastePixY(m,1):Table.PastePixY(m,2))=Data(Table.CutPix(m,1):Table.CutPix(m,2),:);
end

A1=1;