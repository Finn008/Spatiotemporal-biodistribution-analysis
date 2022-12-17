function [Proxy]=renameFields(Proxy)

if isstruct(Proxy);
    OldFields=fieldnames(Proxy);
elseif istable(Proxy);
    OldFields=Proxy.Properties.VariableNames.';
end
NewFields=regexprep(OldFields,'(\<[a-z])','${upper($1)}');
% NewFields=OldFields;
for m=1:size(NewFields,1)
    Occurence=strcmp(NewFields,NewFields{m});
    if sum(Occurence,1)>1
        Ind=find(Occurence==1);
        for n=2:size(Ind,1)
            NewFields{Ind(n)}=[NewFields{Ind(n)},num2str(n)];
        end
    end
end

if isstruct(Proxy);
    Proxy = RenameField(Proxy, OldFields, NewFields);
elseif istable(Proxy);
    Proxy.Properties.VariableNames=NewFields.';
end
