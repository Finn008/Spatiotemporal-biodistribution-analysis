function iFileChanger(Target,Value,IndRep)
global W;
if exist('Value')==0
    Value='ExecuteTarget';
end
if exist('IndRep')==1 % && isempty(IndRep{m,1})==0
    for m2=1:size(IndRep,1)
        Path=[IndRep{m2,1},'=IndRep{m2,2};'];
        eval(Path);
    end
else
    IndRep=[];
end
try; Target=strrep(Target,'W.Task',num2str(W.Task)); end;
try; Target=strrep(Target,'1',num2str(1)); end;
try; Target=strrep(Target,'W.File',num2str(W.File)); end;
try; Target=strrep(Target,'W.Row',['''',W.Row{1},'''']); end;
if isempty(Value) && istable(Value)==0
    Path2W=[Target,'=[];'];
elseif strcmp(Value,'ExecuteTarget')
    Path2W=Target;
else
    Path2W=[Target,'=Value;'];
end
OrigW=W;
try
    eval(Path2W);
catch error
    keyboard;
end

if isfield(W,'IfileChanges')
    %     keyboard; % replace previous one if already present
    Ind=size(W.IfileChanges,1)+1;
    try
        Wave1=strfind1(W.IfileChanges.Path2W,Path2W,1);
%         keyboard;
        if Wave1~=0
            for m=flip(Wave1.')
                if isequal(W.IfileChanges.IndRep{m,1},IndRep)
%                     keyboard;
                    W.IfileChanges(m,:)=[];
%                     Ind=m;
                    Ind=size(W.IfileChanges,1)+1;
                    break;
                end
            end
        end
    catch
    end
    
    W.IfileChanges.Target{Ind,1}=Target;
    W.IfileChanges.Value(Ind,1)={Value};
    W.IfileChanges.IndRep{Ind,1}=IndRep;
    W.IfileChanges.Path2W{Ind,1}=Path2W;
end

assignin('caller','W',W);