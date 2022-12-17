function [Kernel]=generateKernel(Pix,Res,Type)

if exist('Res')
    Um=Pix;
    Pix=Pix./Res;
end
Pix=floor(Pix/2)*2+1; % only ungrade
Center=ceil(Pix/2);
Kernel=zeros(Pix(1),Pix(2),Pix(3));
for X=1:Pix(1)
    for Y=1:Pix(2)
        for Z=1:Pix(3)
            Kernel(X,Y,Z)=(((Center(1)-X)*Res(1))^2+((Center(2)-Y)*Res(2))^2+((Center(3)-Z)*Res(3))^2)^0.5;
        end
    end
end
    
if strcmp(Type,'Gaussian')
    % calc sigma such that kernel size is twice the width at half max of the normal distribution
%     Width=2*2.4*Sigma;
%     Width=2*2.4*Sigma;
    Sigma=Um/2/2.4;
    Kernel=normpdf(Kernel,0,Sigma);
end
Kernel=Kernel/sum(Kernel(:));
% % % % figure;plot(Wave1(:,Center(2),Center(3)));
