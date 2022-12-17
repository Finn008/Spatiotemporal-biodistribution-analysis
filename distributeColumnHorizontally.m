function [Output]=distributeColumnHorizontally(Input,VarsVertical,VarHorizontal,Value,MinMaxHor)

Input=Input(ismember(Input{:,VarHorizontal},MinMaxHor(1):1:MinMaxHor(2)),:);

Output=accumarray_8(Input(:,VarsVertical),[],@sum,[],'Sparse');
Output(:,'Volume') = [];

Pix=[size(Output,1);MinMaxHor(2)-MinMaxHor(1)+1];
Output.Data=nan(Pix.');

Wave1=multiColLinInd(Input(:,VarsVertical));
Wave2=multiColLinInd(Output(:,VarsVertical));
[~,Row]=ismember(Wave1,Wave2);
Col=Input.Distance-MinMaxHor(1)+1;

LinearInd=sub2ind(Pix,Row,Col);
Output.Data(LinearInd)=Input{:,Value};
