function [PlaqueListSingle]=finalEvaluation_Distance4PlaqueListSingle(PlaqueListSingle,Array,Variable,RelationshipIds,DistanceMinMax)
keyboard; % remove 2017.03.26

if exist('DistanceMinMax')~=1
    DistanceMinMax=[1;255];
end
%     Array=Array(ismember(Array.Distance,DistanceMinMax(1):1:DistanceMinMax(2)),:);
% end

Array=Array(ismember(Array.Relationship,[1;2;3;4;5]),:);
AccumArray=accumarray_8(Array(:,{'MouseId';'RoiId';'PlId';'Time';'Distance'}),Array(:,Variable),@sum,[],'Sparse');

AccumArray=distributeColumnHorizontally(AccumArray,{'MouseId';'RoiId';'PlId';'Time'},'Distance',Variable,DistanceMinMax);


PlaqueListSingle=fuseTable_MatchingColums(PlaqueListSingle,AccumArray,{'MouseId';'RoiId';'PlId';'Time'},[],'CommonOverlap');


% AccumArray.LinRowInd=accumarray_4(AccumArray(:,{'MouseId';'RoiId';'PlId';'Time'}),'LinRowInd');
% [~,AccumArray.TargetRow]=ismember(AccumArray.LinRowInd,PlaqueListSingle.LinRowInd);
% 
% Pix=[size(PlaqueListSingle,1);DistanceMinMax(2)-DistanceMinMax(1)+1];
% PlaqueListSingle.Data=nan(Pix.');
% 
% AccumArray.LinearInd=sub2ind(Pix,AccumArray.TargetRow,AccumArray.Distance-DistanceMinMax(1)+1);
% PlaqueListSingle.Data(AccumArray.LinearInd)=AccumArray{:,Variable};

% % % PlaqueListSingle=PlaqueListSingle(unique(AccumArray.TargetRow),:);