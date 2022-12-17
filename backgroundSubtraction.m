function [Data]=backgroundSubtraction(Data,Res,FilterRadius,ResCalc,Application)
keyboard; % discontinued
if exist('FilterType')~=1
    FilterType='Gaussian';
end
Pix=round2odd(repmat(2*FilterRadius,[3,1])./Res);
Data2=smooth3(Data,'gaussian',Pix);

if exist('ResCalc')~=1
    ResCalc=Res;
    Wave1=FilterRadius/10;
    ResCalc(ResCalc>Wave1)=Wave1;
end

J=struct;
J.Res=Res;
J.Type='Gaussian3D';
J.Kernel=FilterRadius;
J.Repeat=3;
J.ResOut=3;

[MaxDataGaussian,Out]=interpolate3D(MaxData,J);

% DataCalc=



if strcmp(FilterType,'Gaussian')
    
    Data2=smooth3(Data,'gaussian',Pix);
end

Data3=Data-Data2


return;
%% 
MaxPix=max(Pix(:));

if strcmp(FilterType,'Gaussian')
    % calc sigma such that kernel size is twice the width at half max of the normal distribution
%     Width=2*2.4*Sigma;
    Sigma=MaxPix/2/2.4;
    Yaxis=normpdf(Xaxis,M,S);
else
    Kernel=ones(Pix(1),Pix(2),Pix(3));
    Kernel=Kernel/sum(Kernel(:));
end




Data=imfilter(Data,Kernel);

% Wave2=imgaussfilt3(Data,13);
Wave1=fspecial('gaussian',5,5,5);