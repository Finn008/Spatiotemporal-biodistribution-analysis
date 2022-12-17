function [x]=XofBinFnc(Y,a,b,c)
if a~=0;
    x=(   (Y-c+b^2/4/a)^0.5-(b/2/a^0.5)   )   / a^0.5;
elseif a==0;
    if b~=0;
        x=(Y-c)/b;
    elseif b==0
        x=Y;
        x(:)=-c;
    end
end