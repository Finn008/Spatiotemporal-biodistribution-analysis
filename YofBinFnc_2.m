function [Y]=YofBinFnc_2(x,FitCoef,range,FitType)
FitCoef(isnan(FitCoef))=0;
% a(isnan(a))=0;
% b(isnan(b))=0;
% c(isnan(c))=0;
if strcmp(FitType,'poly2')
    Y=FitCoef(1).*x.^2    +   FitCoef(2).*x    +    FitCoef(3);
elseif strcmp(FitType,'poly3')
    Y=FitCoef(1).*x.^3    +   FitCoef(2).*x.^2    +    FitCoef(3).*x    +     FitCoef(4);
elseif strcmp(FitType,'exp1')
    Y=FitCoef(1).*exp(FitCoef(2).*x);
elseif strcmp(FitType,'exp2')
    Y=FitCoef(1).*exp(FitCoef(2).*x) + FitCoef(3).*exp(FitCoef(4).*x);
elseif strcmp(FitType,'Immuno')
%     Y=FitCoef(1)*exp(FitCoef(2)*x)+FitCoef(1)*exp(-FitCoef(2)*x)+FitCoef(3)*exp(FitCoef(4)*x);
%     Y=FitCoef(1)*exp(FitCoef(2)*x)+FitCoef(3)*exp(-FitCoef(2)*x)+FitCoef(4)*exp(FitCoef(5)*x);
    Y=FitCoef(1)*exp(FitCoef(2)*x)+FitCoef(3)*exp(FitCoef(4)*x)+FitCoef(3)*exp(-FitCoef(4)*x);
elseif strcmp(FitType,'linear')
    Y=FitCoef(1)*x+FitCoef(2);
end
if isempty(range) || max(isnan(range(:)));
    
else
    Y(1:range(1))=Y(range(1));
    Y(range(2):end)=Y(range(2));
%     Y(x<range(1))=a.*range(1).^2+b.*range(1)+c;
%     Y(x>range(2))=a.*range(2).^2+b.*range(2)+c;
end