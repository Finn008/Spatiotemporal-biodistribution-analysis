function [Window,SizePix]=imdilateWindow(SizeUm,Res,Min3Pix)

SizePix=SizeUm./Res(1:size(SizeUm,1)); % SizePix=round(SizeUm./Res(1:size(SizeUm,1)));
SizePix=floor(SizePix/2)*2+1;
if exist('Min3Pix')==0 || isempty(Min3Pix) || Min3Pix==0
    SizePix(SizePix<3)=3;
end
Window=ones(SizePix.');