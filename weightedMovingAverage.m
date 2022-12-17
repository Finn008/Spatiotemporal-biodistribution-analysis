function [Out]=weightedMovingAverage(Input,Window,Weight,WeightFactor,Force)

Weight(Weight==0)=NaN;
[First,Last]=firstLastNonzero_2(Input,1);
Wave1=sort(Weight);
Min=find(Wave1~=0);Min=Wave1(Min(1));
Max=max(Wave1);
Size=size(Input,1);
Weight=1+(Weight-Min)./Max*(WeightFactor-1);
HalfWindow=floor(Window/2);
Input(isnan(Input))=0;
Weight(isnan(Weight))=0;
Input(:,2)=Weight;
Input2=zeros(Size+Window-1,1);
Weight2=zeros(Size+Window-1,1);
Input2(1+HalfWindow:HalfWindow+Size,1)=Input(:,1);
Weight2(1+HalfWindow:HalfWindow+Size,1)=Weight;
for m2=1:Force
    for m=HalfWindow+1:size(Input2,1)-HalfWindow
        WeightWindow=Weight2(m-HalfWindow:m+HalfWindow,1);
        WeightWindow=WeightWindow/max(WeightWindow(:));
%         WeightWindow=WeightWindow*Window/sum(WeightWindow(:));
        DataWindow=Input2(m-HalfWindow:m+HalfWindow,m2);
        Input2(m,m2+1)=nansum(DataWindow.*WeightWindow)/sum(WeightWindow(:));
    end
%     Input2(:,1)=Input2(:,2);
end
Input(:,3)=Input2(HalfWindow+1:HalfWindow+Size,end);
Input(1:First-1,3)=NaN;
Input(Last+1:end,3)=NaN;

% delete heading zeros or nans
Out=Input(:,3);