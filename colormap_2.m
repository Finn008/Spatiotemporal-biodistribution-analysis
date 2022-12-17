function Colormap=colormap_2(Color,N)

Colormap=zeros(N,3);

if strcmp(Color,'Spectrum')
    KeyColors=[0.5,0,1,0;... % violet
        0,0,1,1;... % blue
        0,1,1,3;... % cyan
        0,1,0,5;... % green
        1,1,0,7;... % yellow
        1,0,0,9;... % red
        ];
    KeyColors=table(KeyColors(:,1:3),KeyColors(:,4),'VariableNames',{'RGB';'Pos'});
    
    KeyColors.Pos=round(KeyColors.Pos/max(KeyColors.Pos)*N);
    KeyColors.Pos(1)=1;
%     cmap(1,:) = [1 0 0];   %// color first row - red
%     cmap(2,:) = [0 1 0];   %// color 25th row - green
%     cmap(3,:) = [0 0 1];   %// color 50th row - blue
    
    [X,Y]=meshgrid(1:3,1:N);  %// mesh of indices
    
    Colormap=interp2(X(KeyColors.Pos,:),Y(KeyColors.Pos,:),KeyColors.RGB,X,Y); %// interpolate colormap
%     cmap = interp2(X([1,25,50],:),Y([1,25,50],:),cmap,X,Y); %// interpolate colormap
%     colormap(cmap) %// set color map

    
    
else
    keyboard;
end
