function [Output]=isempty_2(Input)

Output=cellfun(@isempty,Input);