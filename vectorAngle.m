function [Angle]=vectorAngle(Data)

Angle(:,1)=atan2(sqrt(Data(:,2).^2+Data(:,3).^2),Data(:,1)); % ax=atan2(sqrt(y^2+z^2),x);
Angle(:,2)=atan2(sqrt(Data(:,3).^2+Data(:,1).^2),Data(:,2)); % ay = atan2(sqrt(z^2+x^2),y);
Angle(:,3)=atan2(sqrt(Data(:,1).^2+Data(:,2).^2),Data(:,3)); % az = atan2(sqrt(x^2+y^2),z);