function [Target]=fuseStruct(Target,Source,Fieldnames)

if exist('Fieldnames')~=1
    Fieldnames=fieldnames(Source);
end
for m=1:size(Fieldnames,1)
    Path=['Target.',Fieldnames{m,1},'=Source.',Fieldnames{m,1},';'];
    eval(Path);
end