function [out]=exDoN(field)
global w; global l;

path=['wave1=l.t.f{w.task}.',field,';'];
eval(path);
wave2=cell(size(wave1,1),1);
for m=1:size(wave1,1);
    
    wave2{m,1}=wave1{m}(w.doN);
end

% if min(cellfun(@isnumeric,wave2))==1;
%     wave2=cell2mat(wave2);
% end

out=wave2;
