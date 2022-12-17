function [Image]=drawLineOnImage(Table,Pix,Dilate)
Image= zeros(Pix.', 'uint8');
for m=1:size(Table,1)
    X=[Table.P1(m,1),Table.P2(m,1)];
    Y=[Table.P1(m,2),Table.P2(m,2)];
    nPoints=max(abs(diff(X)),abs(diff(Y)))+1;  % Number of points in line
    rIndex = round(linspace(Y(1),Y(2), nPoints));  % Row indices
    cIndex = round(linspace(X(1),X(2), nPoints));  % Column indices
    index = sub2ind(size(Image), rIndex, cIndex);     % Linear indices
    Wave1=zeros(Pix.','uint8'); Wave1(index)=1;
    Wave1=imdilate(Wave1,ones(Dilate));
    Image(Wave1==1)=Table.Ind(m);  % Set the line pixels to the max value of 255 for uint8 types
end
% imshow(Image);