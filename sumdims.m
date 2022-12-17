function Output=sumdims(Input,Dims)

Output=Input;

for m=1:length(Dims)
    Output=sum(Output,Dims(m));
end
