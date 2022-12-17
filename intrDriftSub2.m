function [Out]=intrDriftSub2(FitCoef,Xcenter,Ycenter,Zcenter,FfilenameTotal,RfilenameTotal,Refinement,ExcludeThreshold)
global W;

MinMax=[min(Zcenter(:,1))-50;max(Zcenter(:,1))+50]-FitCoef(3,3);
Zaxis=table;
Zaxis.Origin=(MinMax(1):0.001:MinMax(2)).';
Zaxis.Drift=YofBinFnc(Zaxis.Origin,-FitCoef(3,1),-FitCoef(3,2),-FitCoef(3,3));
Zaxis.Final=Zaxis.Origin-Zaxis.Drift;

Table2=table;
Table2.ZmetRed=Zcenter(:,1);
Table2.ZvglutRed=Zcenter(:,2);

for m=1:size(Table2,1)
    [Diff,Ind]=min(abs(Zaxis.Final-Table2.ZmetRed(m)));
    Table2.Zorigin(m)=Zaxis.Origin(Ind);
end

Table2.Zdrift=YofBinFnc(Table2.Zorigin,FitCoef(3,1),FitCoef(3,2),FitCoef(3,3));
Table2.Zfinal=Table2.Zorigin+Table2.Zdrift;
Table2.Zdiff=Table2.Zfinal-Table2.ZmetRed;

Table2.XmetRed=Xcenter(:,1);
Table2.Xdiff=YofBinFnc(Table2.Zorigin,FitCoef(1,1),FitCoef(1,2),FitCoef(1,3));
Table2.Xorigin=Table2.XmetRed-Table2.Xdiff;

Table2.YmetRed=Ycenter(:,1);
Table2.Ydiff=YofBinFnc(Table2.Zorigin,FitCoef(2,1),FitCoef(2,2),FitCoef(2,3));
Table2.Yorigin=Table2.YmetRed-Table2.Ydiff;

Xcenter(:,1)=Table2.Xorigin; % Xcenter(:,1)=Xcenter(:,1)-FitCoef(1,3);
Ycenter(:,1)=Table2.Yorigin; % Ycenter(:,1)=Ycenter(:,1)-FitCoef(2,3);
Zcenter(:,1)=Table2.Zorigin; % Zcenter(:,1)=Zcenter(:,1)-FitCoef(3,3);

Table=table;
Table.ZstartF=Zcenter(:,1);
Table.ZstartR=Zcenter(:,2);
Table.Xchange=Xcenter(:,2)-Xcenter(:,1);
Table.Ychange=Ycenter(:,2)-Ycenter(:,1);
Table.Zchange=Zcenter(:,2)-Zcenter(:,1);
Table=sortrows(Table,1);


[Xcurve,Xgof,Xoutput]=fit(Table.ZstartF,Table.Xchange,'poly2','Robust','Bisquare');
[Ycurve,Ygof,Youtput]=fit(Table.ZstartF,Table.Ychange,'poly2','Robust','Bisquare');
[Zcurve,Zgof,Zoutput]=fit(Table.ZstartF,Table.Zchange,'poly2','Robust','Bisquare');

% rmse should not be higher than 0.5 in XY and not higher than 1 in Z
Table.Xcurve=Xcurve(Table.ZstartF);
Table.Ycurve=Ycurve(Table.ZstartF);
Table.Zcurve=Zcurve(Table.ZstartF);
Table.Xdev=abs(Table.Xcurve-Table.Xchange);
Table.Ydev=abs(Table.Ycurve-Table.Ychange);
Table.Zdev=abs(Table.Zcurve-Table.Zchange);
Table.Out(1)=0;

Table.SumDev=Table.Xdev+Table.Ydev+Table.Zdev;
m=1;
while m>0
    Lower=(m*10)-9;
    Upper=m*10;
    if Upper>size(Table,1)
        Upper=size(Table,1);
        m=-1;
    end
    ExcludeNumber=round((Upper+1-Lower)*ExcludeThreshold);
    [Wave1,Wave2]=sort(Table.SumDev(Lower:Upper),'descend');
    Table.Out(Wave2(1:ExcludeNumber)+Lower-1,1)=1;
    m=m+1;
end

% Table.Xout=Table.Xdev>0.5;
% Table.Yout=Table.Ydev>0.5;
% Table.Zout=Table.Zdev>1;
% Table.Out=Table.Xout+Table.Yout+Table.Zout;

[FXcurve,Xgof,Xoutput]=fit(Table.ZstartF,Table.Xchange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);
[FYcurve,Ygof,Youtput]=fit(Table.ZstartF,Table.Ychange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);
[FZcurve,Zgof,Zoutput]=fit(Table.ZstartF,Table.Zchange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);

[RXcurve,Xgof,Xoutput]=fit(Table.ZstartR,-Table.Xchange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);
[RYcurve,Ygof,Youtput]=fit(Table.ZstartR,-Table.Ychange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);
[RZcurve,Zgof,Zoutput]=fit(Table.ZstartR,-Table.Zchange,'poly2','Robust','Bisquare','Exclude',Table.Out~=0);
Rmse=[Xgof.rmse;Ygof.rmse;Zgof.rmse];

FFitCoef(1,1:3)=coeffvalues(FXcurve);
FFitCoef(2,1:3)=coeffvalues(FYcurve);
FFitCoef(3,1:3)=coeffvalues(FZcurve);

RFitCoef(1,1:3)=coeffvalues(RXcurve);
RFitCoef(2,1:3)=coeffvalues(RYcurve);
RFitCoef(3,1:3)=coeffvalues(RZcurve);

Table.Xcurve2=FXcurve(Table.ZstartF);
Table.Ycurve2=FYcurve(Table.ZstartF);
Table.Zcurve2=FZcurve(Table.ZstartF);
Table.Xdev2=abs(Table.Xcurve2-Table.Xchange);
Table.Ydev2=abs(Table.Ycurve2-Table.Ychange);
Table.Zdev2=abs(Table.Zcurve2-Table.Zchange);

SavePath=[W.G.PathOut,'\IntrDrift\'];
J=struct;
J.Tit=['IntrDrift: ',FfilenameTotal,' ',RfilenameTotal];

J.X=Table.ZstartF;
J.OrigYaxis=[   {Table.Xchange-FitCoef(1,3)},{'w.'};...
    {Table.Xcurve2-FitCoef(1,3)},{'w-'};...
    {Table.Ychange-FitCoef(2,3)},{'c.'};...
    {Table.Ycurve2-FitCoef(2,3)},{'c-'};...
    {Table.Zchange-FitCoef(3,3)},{'r.'};...
    {Table.Zcurve2-FitCoef(3,3)},{'r-'};...
    ];
J.OrigType=1;
J.Xlab='Depth [µm]';
J.Ylab='Drift [µm]';
J.Style=1; J.MarkerSize=10;
J.Path2file=[SavePath,FfilenameTotal,'_vs_',RfilenameTotal,'_',num2str(Refinement),'.jpg'];

movieBuilder_4(J);

Out=struct;
Out.FFitCoef=FFitCoef;
Out.Table=Table;
Out.Rmse=Rmse;
Out.RFitCoef=RFitCoef;

evalin('caller','global W;');