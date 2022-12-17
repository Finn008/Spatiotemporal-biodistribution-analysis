function [Out]=generateTextWithFont(In)
Out='';
for m=1:size(In,1)
    RGBcolor=1
    Out=[Out,'{\color{',In.Content{m,1},'}',In.Content{m,1},'}'];
    % ('string','{\color{red} A}ustralia');
end
A1=1;
h=text('string','{\color{red} A}ustralia');
delete(h);
h=text(100,100,'string','{\color{[1,0,0]} A}ustralia');
delete(h);
