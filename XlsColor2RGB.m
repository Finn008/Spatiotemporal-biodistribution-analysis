function [ColorRGB]=XlsColor2RGB(ColorIndex)

ColorRGB(1,1)= rem(ColorIndex,256);
ColorRGB(2,1)= rem(ColorIndex/256,256);
ColorRGB(3,1)= ColorIndex/65536;

% TextColour=[Colorindex Mod 256];
% Color(m, 0) = Colorindex Mod 256
%     Color(m, 1) = (Colorindex \ 256) Mod 256
%     Color(m, 2) = Colorindex \ 65536