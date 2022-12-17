function [T1]=putMultiCol2table(T1,Data,TargetRows,TargetCol)

VariableNames=T1.Properties.VariableNames.';
MultiColNumber=size(Data,2);
Path=['T1.',VariableNames{TargetCol,1},'(TargetRows,1:',num2str(MultiColNumber),')=Data;'];
eval(Path);
% T1.a3(TargetRows,1:2)=Data;
% A1=1;