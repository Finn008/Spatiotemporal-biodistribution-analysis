function [ClosestValues]=findClosestValue(Array,Values)

for m=1:size(Values,1)
    [~, ClosestValues(m,1)] = min(abs(Array - Values(m,1)));
end