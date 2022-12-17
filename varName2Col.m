function Out=varName2Col(In)
Out=struct;
for m=1:size(In,1)
    Path=['Out.',In{m,1},'=m;'];
    eval(Path);
end
