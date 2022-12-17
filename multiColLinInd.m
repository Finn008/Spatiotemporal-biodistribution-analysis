function [LinInd]=multiColLinInd(Table)

if iscell(Table)
    Table=table(Table(:,1).','VariableNames',Table(:,2));
end

Table=flip(Table{:,:},2);

if min(Table(:))<1; keyboard; end;
Digits=max(Table,[],1);
Digits=num2strArray_3(Digits);
Digits=cellfun('length',Digits);
Digits=cumsum(Digits);
Digits=uint64(10.^Digits);

LinInd=uint64(Table);
LinInd(:,2:size(Digits,2))=LinInd(:,2:size(Digits,2)).*repmat(Digits(1,1:size(Digits,2)-1),[size(Table,1),1]);
LinInd=sum(LinInd,2,'native');
if max(LinInd(:))==uint64(2^64);keyboard;end