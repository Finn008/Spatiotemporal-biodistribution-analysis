% 3     999         2.7 Jahre
% 2     99          Tage
% 1     9           Tage
% 1     0.1         2.4     Stunden
% 2     0.01        14.4	Minuten
% 3     0.001       1.44	Minuten
% 4     0.0001      8.64	Sekunden
% 5     0.00001     864	ms
% 6     0.000001	86	ms
% 7    0.0000001	8.6	ms
% 8     0.00000001	864	µs
% 9 	0.000000001	86	µs
% 10	1E-10       8.6	µs

% pause of 1s to make sure that 7 digits of datenum are below timeresolution


function [Ind]=uniqueInd(Exclude,Resolution,Number,Base)
global W;
if exist('Number')~=1
    Number=1;
end
if exist('Base')~=1
    Base=36;
end
if exist('Resolution')~=1
    ResTop=2; % 99 days
    ResBottom=5; % 864ms
else
    if size(Resolution,1)==2
        ResTop=Resolution(1);
        ResBottom=Resolution(2);
    else
        Digits=Resolution;
    end
end
for m=1:Number
    if exist('Digits')==1
        Wave1=Base^Digits-1;
        Ind(m,1)={dec2base(randperm(Wave1,1),36)};
    else
        Wave1=datenum(now)/10^ResTop;
        Wave1=Wave1-floor(Wave1);
        Wave1=round(Wave1*10^(ResBottom+ResTop));
        Ind(m,1)={dec2base(Wave1,Base)};
        Wave2=10^-ResBottom*24*60*60*1.5;
        pause(Wave2);
    end
end
if exist('Exclude')&&isempty(Exclude)==0
    %     keyboard;
    if istable(Exclude)
        Exclude=Exclude.Properties.RowNames;
    end
    Exclude=[Exclude;Ind];
    if size(strfind1(Exclude,Ind,1),1)>size(Ind,1)
        keyboard;
    end
end
if Base<=10
    Ind=str2double(Ind);
else
    if Number==1
        Ind=Ind{1};
    end
end

