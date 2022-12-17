function [rainbowMap]=rainbow(number)

number=number-1;

R(number,1) = 0;
G(number,1) = 0;
B(number,1) = 0;

dx = 0.8;

for f=0:(1/number):1
    g = (6-2*dx)*f+dx;
    index = int16(f*number + 1);
    R(index,1) = max(0,(3-abs(g-4)-abs(g-5))/2);
    G(index,1) = max(0,(4-abs(g-2)-abs(g-4))/2); 
    B(index,1) = max(0,(3-abs(g-1)-abs(g-2))/2);

end

%concatenate arrays horizontally
rainbowMap = horzcat(R, G, B);
