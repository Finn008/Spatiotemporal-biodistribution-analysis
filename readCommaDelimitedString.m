function [Out]=readCommaDelimitedString(String)


Wave1=strsplit(String,'\n').';
for m=1:size(Wave1,1)
    Out(m,:)=strsplit(Wave1{m,1},'",');
end
Out=regexprep(Out,'"','');
Header=Out(1,:);
Header=regexprep(Header,'\W','');
Out(1,:)=[];
Out=array2table(Out,'VariableNames',Header);