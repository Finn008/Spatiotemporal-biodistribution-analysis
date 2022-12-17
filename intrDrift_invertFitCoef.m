function [Xb,Yb,Zb,FitCoefA2B,MinMaxZbefore]=intrDrift_invertFitCoef(FitCoefB2A,Xa,Ya,Za,MinMaxZbefore)

Table2=table;
Table2.Xa=Xa;
Table2.Ya=Ya;
Table2.Za=Za;

MinMaxZafter=[min(Table2.Za(:));max(Table2.Za(:))];

Resolution=0.01;
if exist('MinMaxZbefore')~=1
    MinMaxZbefore=[-500;500];
end
% A1=1;
% MinMaxZ=[min(Zcenter(:));max(Zcenter(:))];

Table=table;
Table.Zb=(MinMaxZbefore(1):Resolution:MinMaxZbefore(2)).';
Table.XdeltaA2B=FitCoefB2A(1,1).*Table.Zb.^2+FitCoefB2A(1,2).*Table.Zb+FitCoefB2A(1,3);
Table.YdeltaA2B=FitCoefB2A(2,1).*Table.Zb.^2+FitCoefB2A(2,2).*Table.Zb+FitCoefB2A(2,3);
Table.ZdeltaA2B=FitCoefB2A(3,1).*Table.Zb.^2+FitCoefB2A(3,2).*Table.Zb+FitCoefB2A(3,3);
Table.Za=Table.Zb+Table.ZdeltaA2B;

for m=1:size(Za,1)
    Wave1=abs(Table.Za-Za(m));
    Ind=find(Wave1<(Resolution/2));
    [~,Ind]=min(Wave1);
%     if size(Ind,1)>1; keyboard; end;
    Table2.Zb(m,1)=Table.Zb(Ind,1);
end

Table2.XdeltaA2B=FitCoefB2A(1,1).*Table2.Zb.^2+FitCoefB2A(1,2).*Table2.Zb+FitCoefB2A(1,3);
Table2.YdeltaA2B=FitCoefB2A(2,1).*Table2.Zb.^2+FitCoefB2A(2,2).*Table2.Zb+FitCoefB2A(2,3);
Table2.Xb=Table2.Xa-Table2.XdeltaA2B;
Table2.Yb=Table2.Ya-Table2.YdeltaA2B;

Table(Table.Za<MinMaxZafter(1)|Table.Za>MinMaxZafter(2),:)=[];
[Xcurve,Xgof,Xoutput]=fit(Table.Za,-Table.XdeltaA2B,'poly2','Robust','Bisquare');
[Ycurve,Xgof,Xoutput]=fit(Table.Za,-Table.YdeltaA2B,'poly2','Robust','Bisquare');
[Zcurve,Xgof,Xoutput]=fit(Table.Za,-Table.ZdeltaA2B,'poly2','Robust','Bisquare');
FitCoefA2B=[coeffvalues(Xcurve);coeffvalues(Ycurve);coeffvalues(Zcurve)];


MinMaxZbefore=[min(Table2.Zb(:));max(Table2.Zb(:))];

Xb=Table2.Xb;
Yb=Table2.Yb;
Zb=Table2.Zb;