function initializeFunction()
global W;

% varargout{1}=W;
OutputVariables={'W'};

for m=1:size(OutputVariables,1)
    Path=['val=',OutputVariables{m,1},';'];
    eval(Path);
    assignin('caller',OutputVariables{m,1},val)
end