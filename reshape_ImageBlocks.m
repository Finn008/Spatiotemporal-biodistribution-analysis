function Data2=reshape_ImageBlocks(Data,Pix,ImageShape)

ImageNumber=size(Data,1)/Pix;

for m=1:ImageNumber
    disp(m);
    Cut=[((m-1)*Pix)+1,m*Pix];
    Paste=[((m-1)*Pix)+1;floor(m/ImageShape(1))*Pix+1];
%     Data2(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2))=Data(Cut(1):Cut(2),:);
end

A1=1;