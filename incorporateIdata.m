% incorporate I-data into I
function [Report]=incorporateIdata(IfileChanges)
global W;
OrigW=W;
try
%     Wave1=whos('IfileChanges');
%     MBSize=Wave1.bytes/1000000;
%     if MBSize>200
%         keyboard;
%     end
    
    for m=1:size(IfileChanges,1)
        if isempty(IfileChanges.IndRep{m})==0
            IndRep=IfileChanges.IndRep{m};
            for m2=1:size(IndRep,1)
                Path=[IndRep{m2,1},'=IndRep{m2,2};'];
                eval(Path);
            end
        end
        if isempty(IfileChanges.Value{m,1}) && istable(IfileChanges.Value{m,1})==0
            Path2W=[IfileChanges.Target{m,1},'=[];'];
        elseif strcmp(IfileChanges.Value{m,1},'ExecuteTarget')
            Path2W=[IfileChanges.Target{m,1}];
        else
            Path2W=[IfileChanges.Target{m,1},'=IfileChanges.Value{m,1};'];
        end
        
        MB1=whos('W'); MB1=MB1.bytes/1000000;
        Thumb=1;
        if Thumb==1
            eval(Path2W);
        end
%         MB2=whos('W'); MB2=MB2.bytes/1000000;
        
%         if MB2>9000
%             keyboard;
%         end
    end
    Report=1;
catch
    W=OrigW;
    Report=0;
end


