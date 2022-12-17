function [Cut,Paste]=pixelOverhang(CenterPixCut,CubePix,CenterPixPaste,Pix)
% CenterPixPaste must be odd
Cut=CenterPixCut-(CubePix-1)/2;
Cut=[Cut,Cut+CubePix-1];

Overhang=zeros(3,2);
Overhang(Cut(:,1)<1)=-Cut(Cut(:,1)<1)+1; % lower
Wave1=Cut(:,2)>Pix;
Overhang(Wave1,2)=Pix(Wave1)-Cut(Wave1,2);

Cut=Cut+Overhang;
% Overhang(:,2)=Pix-Cut(:,2);
% Overhang(Cut(:,2)>Pix,2)=Cut(Cut(:,2)>Pix,2);
% Overhang(Cut(:,2)>Pix,2)=Pix(Cut(:,2)>Pix);
% Overhang(:,2)=Cut(:,2)-Overhang(:,2);
% Cut(Cut(:,2)>Pix); % upper

Paste=CenterPixPaste-(CubePix-1)/2;
Paste=[Paste,Paste+CubePix-1];
Paste=Paste+Overhang;


%         
        
