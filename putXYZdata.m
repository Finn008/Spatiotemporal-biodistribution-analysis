function [out]=putXYZdata(in,vars,type)
global i; global w;dbstop if error;
out=in;
for m=1:size(vars,1); % go through vars
%     path=[target,'.',vars{m,1},'=a.',vars{m,1},';']; eval(path);
    for n=1:3; % go through types
        try
            path=['out.',type{n,1},vars{m,1},'=in.',vars{m,1},'(',num2str(n),',1);']; eval(path);
            out=rmfield(out,vars{m,1});
        catch; end;
    end
end
a1=1;