function [Pos]=circleGenerator(Center,Radius,Resolution)
Pi=3.1415;
% AngleSteps=360/Resolution;
Pos=table;
Pos.Angle=(0:Resolution:360).';
Pos.Radian=Pos.Angle*Pi/180;
Pos.Xpos=cos(Pos.Radian)*Radius+Center(1,1);
Pos.Ypos=sin(Pos.Radian)*Radius+Center(2,1);

% Pos=Xpos+;
% Pos(:,2)=Ypos+Center(2,1);
% A1=1;