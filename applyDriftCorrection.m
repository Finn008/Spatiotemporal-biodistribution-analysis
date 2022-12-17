function [Output]=applyDriftCorrection(Input,FitCoefs)
Output=Input;
for Dim=1:size(Input,2)
    X=Input(:,Dim);
    A=FitCoefs(Dim,1);
    B=FitCoefs(Dim,2);
    C=FitCoefs(Dim,3);
    Y=X+A.*X.^2+B.*X+C;
    Output(:,Dim)=Y;
end