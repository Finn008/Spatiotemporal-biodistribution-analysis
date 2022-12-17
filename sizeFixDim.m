function Size=sizeFixDim(Size,Dim)

Size(1,size(Size,2)+1:Dim)=1;
