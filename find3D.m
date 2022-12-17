function [Out]=find3D(Data3D)

Pix=size(Data3D).';
Wave1=find(Data3D>0);
Data3D=nan(Pix(1),Pix(2),Pix(3),'double');
Data3D(Wave1)=Wave1;
clear Wave1;

Data3D=double(min(Data3D,[],3));
[X,Y,Z]=ind2sub(Pix.',Data3D);
Out=Z;
% [X,Y,Z]=ind2sub(Pix.',Wave1);
% Wave1=zeros(Pix(1),Pix(2),Pix(3),'uint16');
% Wave1(:)=65535;
% for m=1:size(X,1)
%     Wave1(X(m),Y(m),Z(m))=Z(m);
% end
% 
% Out=double(min(Wave1,[],3));
% Out(Out==65535)=NaN;
% 
% return;
% 
% [r,c]=find(Data3D==0);
% b=zeros(1,size(Data3D,2));
% b(c)=r+1;
% b(b>size(a,1))=nan; % mark all-zero cols