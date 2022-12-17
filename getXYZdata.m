function [out]=getXYZdata(in,vars,type)
global i; global w;dbstop if error;
out=in;
for m=1:size(vars,1); % go through vars
%     path=['a.',vars{m,1},'=zeros(',num2str(size(type,1)),',1,''double'');'];
%     eval(path);
    for n=1:3; % go through types
        try
            path=['out.',vars{m,1},'(',num2str(n),',1)=in.',type{n,1},vars{m,1},';'];
            eval(path);
        catch; end;
    end
end
a1=1;