function [Output]=distributeColumnHorizontally_4(Input,VarsVertical,VarHorizontal,VarValue,ColIds,VarHorizontalNew)

if exist('VarsVertical')~=1 || isempty(VarsVertical)
    VarsVertical=Input.Properties.VariableNames.';
    VarsVertical(ismember(VarsVertical,{VarHorizontal;VarValue}),:)=[];
end
if exist('ColIds')~=1 || isempty(ColIds)
    ColIds=(min(Input{:,VarHorizontal}):1:max(Input{:,VarHorizontal})).';
end

Input=Input(ismember(Input{:,VarHorizontal},ColIds),:);
Output=accumarray_8(Input(:,VarsVertical),[],@sum);
Output(:,'Count') = [];

Pix=[size(Output,1);size(ColIds,1)];
Output.Data=nan(Pix.');
[Wave1,Wave2]=findCommonMultiColLinInd(Input(:,VarsVertical),Output(:,VarsVertical));

[~,Row]=ismember(Wave1,Wave2);
Col=Input{:,VarHorizontal}-min(ColIds(:))+1;

[~,Col]=ismember(Input{:,VarHorizontal},ColIds);

LinearInd=sub2ind(Pix,Row,Col);
Output.Data(LinearInd)=Input{:,VarValue};
if exist('VarHorizontalNew')==1 && isempty(VarHorizontalNew)==0
    VarValue=VarHorizontalNew;
end
Output.Properties.VariableNames{end}=VarValue;
