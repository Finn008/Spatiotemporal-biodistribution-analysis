function [Output]=distributeColumnHorizontally_3(Input,VarsVertical,VarHorizontal,VarValue,MinMaxHor)

if exist('VarsVertical')~=1 || isempty(VarsVertical)
    VarsVertical=Input.Properties.VariableNames.';
    VarsVertical(ismember(VarsVertical,{VarHorizontal;VarValue}),:)=[];
end
if exist('MinMaxHor')~=1 || isempty(MinMaxHor)
    MinMaxHor=[min(Input{:,VarHorizontal});max(Input{:,VarHorizontal})];
end

Input=Input(ismember(Input{:,VarHorizontal},MinMaxHor(1):1:MinMaxHor(2)),:);

Output=accumarray_8(Input(:,VarsVertical),[],@sum,[],'Sparse');
Output(:,'Count') = [];

Pix=[size(Output,1);MinMaxHor(2)-MinMaxHor(1)+1];
Output.Data=nan(Pix.');

[Wave1,Wave2]=findCommonMultiColLinInd(Input(:,VarsVertical),Output(:,VarsVertical));

% Wave2=multiColLinInd(Output(:,VarsVertical));
[~,Row]=ismember(Wave1,Wave2);
% Col=Input.Distance-MinMaxHor(1)+1;
Col=Input{:,VarHorizontal}-MinMaxHor(1)+1;

LinearInd=sub2ind(Pix,Row,Col);
Output.Data(LinearInd)=Input{:,VarValue};
