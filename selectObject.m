function [VimarisObject,Ind,ObjectList]=selectObject(Application,Name)

if exist('Name')==1 && strcmp(class(Name),'Imaris.ISurfacesPrxHelper')
    Name=char(Name.GetName);
end

% get list of all surfaces
ObjectList=cell(0,2);

setImarisViewer(Application,'surpass');
Trials=0;
for Ind=0:inf;
    try
        Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(Ind));
        VimarisObject = Application.GetSurpassSelection;
        ObjectList{Ind+1,1}=char(VimarisObject.GetName);
        ObjectList{Ind+1,2}=Ind;
        
        if Application.GetFactory.IsSpots(VimarisObject)
            ObjectList{Ind+1,3}='Spots';
        elseif Application.GetFactory.IsSurfaces(VimarisObject)
            ObjectList{Ind+1,3}='Surfaces';
        end    
        Trials=0; % set back to zero when new object is found
    catch
        % does not recognize ortho slicer wherefore it would stop here
        % therefore count up until 5 times error the stop
        Trials=Trials+1;
        if Trials==5
            break;
        end
%         objectList{ind+1,1}='none';
%         break;
    end
end
% get index of specified surface
try
    Ind=strcmp(ObjectList(:,1),Name); 
%     ind=~cellfun(@isempty,ind); 
    Ind=find(Ind==1)-1;
    % select that surface
    Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(Ind));
    if strcmp(ObjectList{Ind+1,3},'Surfaces')
        VimarisObject = Application.GetFactory.ToSurfaces(Application.GetSurpassSelection);
    elseif strcmp(ObjectList{Ind+1,3},'Spots')
        VimarisObject = Application.GetFactory.ToSpots(Application.GetSurpassSelection);
    end
catch
    Ind=[];
    VimarisObject=[];
end
% ObjectList(:,2)=[];
