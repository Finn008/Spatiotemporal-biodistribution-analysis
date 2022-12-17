function [String]=variableSetter_2(String,Changes)
% keyboard;
if iscell(String)==0
    String={String};
    Convert2String=1;
else
    Convert2String=0;
end
for m2=1:size(String,1)
    StartPos=strfind(String{m2,1},'#').';
    EndPos=strfind(String{m2,1},'|').';
    
    if isempty(StartPos)
        String{m2,1}='';
    else
        %         keyboard;
%         Version=1;
        if size(StartPos,1)~=size(EndPos,1)
            A1=qwertzui;
        end
    end
    
    
    %% new version
    %     if Version==1
    J=table;
    for m=1:size(Changes,1)
        J.Vars{m,1}=Changes{m,1};
        J.VariablesLength(m,1)=length(Changes{m,1});
        VariableStart=strfind(String{m2,1},[Changes{m,1},'#']);
        if isempty(VariableStart)
            String{m2,1}=[String{m2,1},Changes{m,1},'#',Changes{m,2},'|'];
        else
            J.VarStart(m,1)=VariableStart;
            J.StartPos(m,1)=J.VarStart(m,1)+J.VariablesLength(m,1);
            Wave1=strfind(String{m2,1},'|').';
            J.EndPos(m,1)=Wave1(min(find(Wave1>J.StartPos(m,1))));
            Content=Changes{m,2};
            ContentNum=num2str(Changes{m,2});
            if isempty(ContentNum)
                J.Content{m,1}=Content;
            else
                J.Content{m,1}=ContentNum;
            end
            String{m2,1}=[String{m2,1}(1:J.StartPos(m,1)),Changes{m,2},String{m2,1}(J.EndPos(m,1):end)];
        end
    end
end

if Convert2String==1
    String=String{1};
end
%     %% old version with landmarks provided
%     if Version==0
%
%
%         for m =1:size(Changes,1)
%             % convert numeric to string
%             Wave1=num2str(Changes{m,2});
%             if isempty(Wave1)==0
%                 Changes{m,2}=Wave1;
%             end
%
%             LandmarkLength=length(Changes{m,1});
%             LandmarkPos=strfind(String{m2,1},Changes{m,1});
%             TerminatorPos=strfind(String{m2,1}(LandmarkPos:end),'|')+LandmarkPos-1;
%             if isempty(LandmarkPos);
%                 String{m2,1}=[String{m2,1},Changes{m,1},Changes{m,2},'|'];
%             else
%                 String{m2,1}=[String{m2,1}(1:LandmarkPos-1),Changes{m,1},Changes{m,2},String{m2,1}(TerminatorPos:end)];
%             end;
%         end
%     end
% end
