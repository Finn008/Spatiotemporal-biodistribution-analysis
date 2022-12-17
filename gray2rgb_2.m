function ImageOut=gray2rgb_2(Image,ColorTable)

ColorNumber=size(ColorTable,1);
Image=Image+1;
Image(Image>ColorNumber)=ColorNumber;

ImageOut=ColorTable(Image);
ImageOut(:,:,2)=ColorTable(Image+ColorNumber);
ImageOut(:,:,3)=ColorTable(Image+ColorNumber*2);

% keyboard;
% ImageOut(:)=1;
% imshow(double(ImageOut));
% 
% Wave1=(0:300).';
% ImageOut=ColorTable(Wave1+1);
% 
% keyboard;