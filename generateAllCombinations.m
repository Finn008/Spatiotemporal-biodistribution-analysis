function Output=generateAllCombinations(Data)

LoopNumber=prod(Data);
Output=ones(size(Data,1),1);

for m=2:max(Data)
    for Row=find(Data>=m).'
        Wave1=Output;
        Wave1(Row,:)=m;
        Output=[Output,Wave1];
    end
end

Output=unique(Output.','rows').';