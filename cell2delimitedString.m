function [Out]=cell2delimitedString(Input)

Input=cellfun(@num2str,Input,'UniformOutput',false);
[m n]=size(Input);
Out(1:m,1:2:2*n)=Input;
Out(1:m,2:2:2*n)={sprintf('\t')};
Out(1:m,end)={sprintf('\n')};
Out=reshape(Out',1,[]);