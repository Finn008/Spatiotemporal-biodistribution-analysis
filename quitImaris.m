function quitImaris(Application)
global W;
if isempty(Application); return; end;
if istable(Application)
    List=Application.Char;
else
    List={char(Application)};
end

for m=1:size(List,1)
    Ind=strfind1(W.Imaris.Instances.Char,List{m,1});
    if Ind==0
    else
        Application2close=W.Imaris.Instances.Application{Ind,1};
    end
    try
        Application2close.SetVisible(0); % to close without saving
        Application2close.Quit;
        W.ImarisId(Ind,:)=[];
    end
    
end

% if W.SingularImarisInstance==1
    mouseMoveController(0);
% end
