function [Y]=YofBinFnc(X,A,B,C,Range)
A(isnan(A))=0;
B(isnan(B))=0;
C(isnan(C))=0;

Y=A.*X.^2+B.*X+C;
if exist('Range')~=1 || isempty(Range) || max(isnan(Range(:)));
    
else
    Y(X<Range(1))=A.*Range(1).^2+B.*Range(1)+C;
    Y(X>Range(2))=A.*Range(2).^2+B.*Range(2)+C;
end