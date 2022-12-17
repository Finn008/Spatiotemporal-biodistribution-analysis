function [output]=emptyRow(input)

input{end+1,end+1}=1;
input(:,end)=[];
output=input(end,:);
% input.newColumn=1;
% input.newColumn(end+1,1)=1;
% input.newColumn=[];
% output=input(end,:);
