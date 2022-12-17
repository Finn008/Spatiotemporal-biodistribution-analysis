function [NormData]=normalizePercProfile(Data)

if iscell(Data)==0
    Data={Data};
    ReturnNumericArray=1;
else
    ReturnNumericArray=0;
end

for m=1:size(Data,1)
    PercentileProfile=Data{m,1};
    
    NormPercentileProfile=PercentileProfile;
    for n=1:size(PercentileProfile,1);
        if istable(PercentileProfile)
            NormPercentileProfile{n,:}=PercentileProfile{n,:}/max(PercentileProfile{n,:})*100; % handle table
        else
            NormPercentileProfile(n,:)=PercentileProfile(n,:)/max(PercentileProfile(n,:))*100; % handle numeric array
        end
    end
    NormData(m,1)={NormPercentileProfile};
end

if ReturnNumericArray==1
    NormData=NormData{1,1};
end