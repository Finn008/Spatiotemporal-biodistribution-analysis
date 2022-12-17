% Stack is a uint16 3D dataset with 1 for inside and 0 for outside
% um is a 3xvector with the µm size of the stack
% DTresolution is the resolution at which the distance transform is calculated
function [StackOut]=P0184(Stack,um)
global w; global i;
% a1=sum(sum(sum(Stack)));
% um=[w.Xum,w.Yum,w.Zum];
Stack=int16(Stack); % to have an integer stack
% a2=sum(sum(sum(Stack)));
pix=[size(Stack,1);size(Stack,2);size(Stack,3)];

resolution=um; % from µm and pixel dimensions calculate the resolution
resolution(1)=um(1)/size(Stack,1);
resolution(2)=um(2)/size(Stack,2);
resolution(3)=um(3)/size(Stack,3);

x=size(Stack,1)*resolution(1)/min(resolution)*   min(resolution)/w.Dtresolution; % calculate factor by which to multiply to get to lowest resolution
y=size(Stack,2)*resolution(2)/min(resolution)*   min(resolution)/w.Dtresolution;
z=size(Stack,3)*resolution(3)/min(resolution)*   min(resolution)/w.Dtresolution;


[Stack]=P0156(Stack,x,y,z); % resize Stack so that isotropic resolution in all 3 dimensions

% a3=sum(sum(sum(Stack)));

StackOut=Stack; % allocate memory to store distance transform outside plaque
[Outside]=bwdist(StackOut,'quasi-euclidean'); % make distance transform for outside

% inside
StackOut(:,:,:)=1; StackOut(Stack==1)=0; % invert StackOut so that everything outside plaque is 1
[Stack]=bwdist(StackOut,'quasi-euclidean'); % make distance transform for inside and store in Stack
% now pixel-based distance transform is saved in Outside and inside is saved in Stack
Stack=Stack-1; % subtract value one from inside so that 0 is not empty when adding the two together, so the value zero is still inside the plaque

Stack(Stack==-1)=0; % to reset everything outside plaque to 0
StackOut(:,:,:)=Outside(:,:,:)-Stack(:,:,:); % add together

% convert pixel based distance into µm based distance
roundingVersion=2;
if roundingVersion == 1 % round to nearest integer
    StackOut(:,:,:)=int(StackOut(:,:,:)*w.Dtresolution);
elseif roundingVersion==2 % roundup to next integer µm
%     wave1=zeros(size(StackOut,1),size(StackOut,2),size(StackOut,3),'single');
    StackOut=single(StackOut)*w.Dtresolution;
    StackOut=ceil(StackOut);
    StackOut=int16(StackOut);
elseif roundingVersion==3 % do not round at all
    StackOut(:,:,:)=StackOut(:,:,:)*w.Dtresolution;
end



[StackOut]=P0156(StackOut,pix(1),pix(2),pix(3)); % resize Stack back to original size
% a15(StackOut<1)=1;a10=sum(sum(sum(a15)));
% StackOut=int16(StackOut);




