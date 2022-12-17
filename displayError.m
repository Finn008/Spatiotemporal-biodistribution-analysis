function [Messages]=displayError(error,Display)
if exist('Display')==0
    Display=1;
end

for m=0:size(error.stack,1)
    if m==0
        Messages{1}=['ERROR: ',error.message];
    else
        Messages{m+1,1}=['ERROR: ',error.stack(m).name,' ',num2str(error.stack(m).line)];
    end
%     A1=asdf; % put error message into one single char
%     disp(Messages{m+1});
    
end
Messages=strjoin(Messages,'\n');
if Display==1
    disp(Messages);
end