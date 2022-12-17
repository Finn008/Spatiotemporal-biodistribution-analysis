function secureJavaAddPath(Path)

Wave1=who('global');
global W;
for m=1:size(Wave1,1)
    Wave2=['Wave1(m,2)={',Wave1{m,1},'};'];
    eval(Wave2);
end

javaaddpath(Path);

for m=1:size(Wave1,1)
    Wave2=[Wave1{m,1},'=Wave1{m,2};'];
    eval(Wave2);
end
global W;