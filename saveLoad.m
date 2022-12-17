function [Out]=saveLoad(Type,Path2file,VariableQQ)

% Path2file='\\mitstor8.srv.med.uni-muenchen.de\ZNP-User\fipeter\Desktop\Zwischenspeicher\test.mat';

if strcmp(Type,'Save')
    %     SaveStart=datenum(now);
    save(Path2file,'VariableQQ')
    pause(1);
    SaveStatus=1;
    save(Path2file,'SaveStatus','-append');
elseif strcmp(Type,'Load')
    %     Wait=1;
    for m=1:10
        try
            Out=load(Path2file);
            if Out.SaveStatus==1
                Out=Out.VariableQQ;
%                 Out=rmfield(Out,'SaveStatus');
%                 Out=struct2cell(Out);
%                 Out=Out{1,1};
                break;
            end
%             strfind1({Wave1.name},'SaveStatus',1)
            %             Wave1=whos('-file',Path2file);
        catch
            pause(5);
        end
    end
end