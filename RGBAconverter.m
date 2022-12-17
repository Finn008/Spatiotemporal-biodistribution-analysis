function [RGBA]=RGBAconverter(RGBA)
% vRed = 0.9;
% vGreen = 0.1;
% vBlue = 0.6;
% vAlpha = 0;
% disp(sprintf('Range 0-1: Red = %f, green = %f, blue = %f, alpha = %f', vRed, vGreen, vBlue, vAlpha))
% vRGBA = [vRed, vGreen, vBlue, vAlpha];
RGBA = round(RGBA * 255); % need integer values scaled to range 0-255
RGBA = uint32(RGBA * [1; 256; 256*256; 256*256*256]); % combine different components (four bytes) into one integer