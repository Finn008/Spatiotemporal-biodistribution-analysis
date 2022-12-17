function variableSetter(Target,Value)
global W;
% String=1;
Path=['String=',Target,';'];
eval(Path);


for m =1:size(Value,1)
    % convert numeric to string
    wave1=num2str(Value{m,2});
    if isempty(Wave1)==0
        Value{m,2}=Wave1;
    end
    
    LandmarkLength=length(Value{m,1});
    LandmarkPos=strfind(String,Value{m,1});
    TerminatorPos=strfind(String(LandmarkPos:end),'|')+LandmarkPos-1;
    if isempty(LandmarkPos); 
%         landmarkPos=length(string)+1; 
        String=[String,Value{m,1},Value{m,2},'|'];
    else
        String=[String(1:LandmarkPos-1),Value{m,1},Value{m,2},String(TerminatorPos:end)];
    end;
    
    
end

Path=[Target,'=String;'];
eval(Path);