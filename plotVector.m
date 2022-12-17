function plotVector(Data)
keyboard; % remove
% Data=sin(Data);
Data=[0,0,0;sin(Data)];
figure; plot3(Data(:,1),Data(:,2),Data(:,3),'k*-');
%legend(('first', 'second', 'third'});
Angle(:,1)=atan2(sqrt(Data(:,2).^2+Data(:,3).^2),Data(:,1)); % ax=atan2(sqrt(y^2+z^2),x);
Angle(:,2)=atan2(sqrt(Data(:,3).^2+Data(:,1).^2),Data(:,2)); % ay = atan2(sqrt(z^2+x^2),y);
Angle(:,3)=atan2(sqrt(Data(:,1).^2+Data(:,2).^2),Data(:,3)); % az = atan2(sqrt(x^2+y^2),z);
A1=(sum(Data.^2))^0.5