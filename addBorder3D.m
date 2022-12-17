function [Data3Dout,AddBorderMinMaxPaste]=addBorder3D(Data3D,Res,Border,Type)

if size(Res,2)==2
    AddBorderMinMaxPaste=Res;
    Data3Dout=Data3D(AddBorderMinMaxPaste(1,1):AddBorderMinMaxPaste(1,2),AddBorderMinMaxPaste(2,1):AddBorderMinMaxPaste(2,2),AddBorderMinMaxPaste(3,1):AddBorderMinMaxPaste(3,2));
    return;
end

if exist('Type')~=1; Type='Zeros'; end;

Pix=size(Data3D).';
PixNew=uint16((Pix.*Res+Border*2)./Res);
MinMaxPaste=round(Border./Res); MinMaxPaste(:,2)=MinMaxPaste+Pix-1;

if strcmp(Type,'Zeros')
    Data3Dout=zeros(PixNew.','uint16');
elseif strcmp(Type,'Ones')
    Data3Dout=ones(PixNew.','uint16');
end
Data3Dout(MinMaxPaste(1,1):MinMaxPaste(1,2),MinMaxPaste(2,1):MinMaxPaste(2,2),MinMaxPaste(3,1):MinMaxPaste(3,2))=Data3D;

AddBorderMinMaxPaste=MinMaxPaste;

% set equal to closest border pixel
if strcmp(Type,'EqualClosestBorder')
    Wave1=Data3Dout;
    Wave1(MinMaxPaste(1,1):MinMaxPaste(1,2),MinMaxPaste(2,1):MinMaxPaste(2,2),MinMaxPaste(3,1):MinMaxPaste(3,2))=1;
%     Wave1(MinMaxPaste(1,1)+1:MinMaxPaste(1,2)-1,MinMaxPaste(2,1)+1:MinMaxPaste(2,2)-1,MinMaxPaste(3,1)+1:MinMaxPaste(3,2)-1)=1;
    tic
    [~,Wave3]=bwdist(Wave1,'quasi-euclidean'); % make distance transform for outside
    toc
    
    Wave1=Data3Dout(Wave3(:,:,:));
%     Membership(:,:,:,m1)=cast(Wave2(Xt,Yt,Zt),DistanceBitType);
    [Application]=openData3DImaris(Wave1,Res,'Test');
    ex2Imaris_2(Wave1,Application,'Test');
    
    
    
%     Wave1(MinMaxPaste(1,1)+1:MinMaxPaste(1,2)-1,MinMaxPaste(2,1)+1:MinMaxPaste(2,2)-1,MinMaxPaste(3,1)+1:MinMaxPaste(3,2)-1)=0;
    
    
    
%     [Wave2,Wave3]=bwdist(Wave1,'cityblock'); % make distance transform for outside
end

% originalBW = imread('circles.png');
% imshow(originalBW)
% ultimateErosion = bwulterode(originalBW);
% figure, imshow(ultimateErosion)
% 
% originalBW = imread('circles.png');
% % imshow(originalBW)
% ultimateErosion = imregionalmax(originalBW);
% figure, imshow(ultimateErosion)
