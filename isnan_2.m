function Output=isnan_2(Input)

Output=cellfun(@(Input) any(isnan(Input)),Input);