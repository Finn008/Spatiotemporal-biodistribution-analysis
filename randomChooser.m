function [Ind]=randomChooser(Range,Number,Weight)

% Range=Selection.VocID.';
% Range = 1:size(W.Voc,1);            %# possible numbers
%     Weight = ones(1,size(W.Voc,1));   %# corresponding weights
% Weight=(W.Voc.SuccessWeight.*W.Voc.Quality).';
if exist('Number')~=1 || exist(Number)==0
    Number = 1;
end
if exist('Weight')~=1 || exist(Weight)==0
    Weight=ones(size(Range,1),1);
%     Weight = (1:size(Range,1)).';
end
Wave1=rand(size(Range,1),1);
Wave1=Wave1.*Weight;
[~,Wave2]=sort(Wave1);
Ind=Range(1:Number,1);
% Ind = Range( sum( bsxfun(@ge, rand(Number,1), cumsum(Weight./sum(Weight))), 2) + 1 );