function [Out]=struct2table_2(In)

Out=struct2table(In,'AsArray',1);
VariableNames=Out.Properties.VariableNames.';
for m=1:size(Out,2)
    if isstruct(Out{1,m})
        for m2=1:size(Out,1)
            Wave1{m2,1}=Out{1,m};
        end
        Path=['Out.',VariableNames{m},'=Wave1;'];
        eval(Path);
    end
end

