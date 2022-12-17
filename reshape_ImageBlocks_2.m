function Data2=reshape_ImageBlocks_2(Data,Rows)

Pix=size(Data,2);
ImageNumber=size(Data,1)/Pix;

for m=1:ImageNumber
%     disp(m);
    Cut=[(m-1)*Pix+1;m*Pix];
%     m=1; Wave1=m-floor((m/Rows-0.1))*Rows
%     m=5; Wave1=ceil(m/Rows)
    Paste=[m-floor((m/Rows-0.1))*Rows,ceil(m/Rows)];
    PasteTotal(m,1:2)=Paste;
%     disp(Paste);
    Paste=(Paste-1)*Pix+1;
    Paste(2,:)=Paste(1,:)+Pix-1;
%     disp(Paste);
    
    %     Paste=[floor((m/ImageShape(2))-0.1)*Pix+1;floor(m/ImageShape(1))*Pix+1];
%     Paste(:,2)=Paste(:,1)+Pix-1
    Data2(Paste(1,1):Paste(2,1),Paste(1,2):Paste(2,2))=Data(Cut(1):Cut(2),:);
end

A1=1;