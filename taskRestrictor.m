function [Out]=taskRestrictor()
global W;
OrigW=W;
% W.G.Pipeline
RestrictionList=cell(size(W.G.Pipeline,1),1);

Ind=find(floor(W.G.Pipeline.Status)==1);
DoFunctions=W.G.DoFunctions;
for m=Ind.'
    CallerString=W.G.Pipeline.CallerString{m,1};
    Task=W.G.Pipeline.Task(m,1);
    File=W.G.Pipeline.File(m,1);
    Proxy=eval(W.G.Pipeline.ProxyPath{m,1});
    [FctSpec]=variableExtract(Proxy{File,CallerString}{1},{'Step'});
    Step=['Step',num2str(floor(FctSpec.Step))];
    
    try
        Wave1=DoFunctions{CallerString,Step};
    catch
        Wave1=0;
    end
    if iscell(Wave1)&&ischar(Wave1{1})
        [Wave1]=variableExtract(Wave1{1},{'Cn';'Imaris'});
        if Wave1.Cn~=0
            Wave2=string2cell_2(Wave1.Cn);
            W.G.Pipeline.Restriction{m,1}.ComputerName.Only=Wave2;
            RestrictionList(m,1)={[RestrictionList{m,1},Wave1.Cn,',']};
        end
        if Wave1.Imaris~=0
            W.G.Pipeline.Restriction{m,1}.ImarisStatus.Also=Wave1.Imaris;
            RestrictionList(m,1)={[RestrictionList{m,1},Wave1.Imaris,',']};
        end
    else
        W.G.Pipeline.Restriction{m,1}=struct;
        RestrictionList(m,1)={'None'};
    end
end

Out=struct;
Out.RestrictionList=RestrictionList;



