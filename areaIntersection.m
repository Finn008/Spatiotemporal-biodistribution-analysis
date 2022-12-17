function [Intersection]=areaIntersection(Traces)

for m=1:size(Traces,1)
    
    if max(max(isnan(Traces(m,:,:))),[],3)==1 || Traces(m,2,1)>Traces(m,1,2) || Traces(m,2,2)>Traces(m,1,1)
        % separated
        Intersection(m,1:2)=[NaN,NaN];
    else
        Max=min(Traces(m,1,:),[],3);
        Min=max(Traces(m,2,:),[],3);
        Intersection(m,1:2)=[Max,Min];
    end
end

% keyboard;