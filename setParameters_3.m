% if Value is empty then Report returns char
function [Report]=setParameters_3(Value,Pos1,Pos2)
if exist('Pos2')~=1
    Version=1;
else
    Version=2;
end

Report=0;
Trials=0;
while Report==0
    safeClipboard('EmptyClipboard');
    Trials=Trials+1;
    if Version==1
        if exist('Pos1')
            inputemu('normal',Pos1); pause(0.5);
        end
        inputemu({'key_normal';'\END'});
        inputemu({'key_down';'\SHIFT'});
        inputemu(repmat({'key_normal';'\LEFT'},[1,100]));
        inputemu({'key_up';'\SHIFT'}); pause(0.5);
    elseif  Version==2
        inputemu('left_down',Pos1); pause(0.5);
        inputemu('left_up',Pos2); pause(0.5);
    end
    inputemu('key_ctrl','c'); pause(1);
    CurrentValue=safeClipboard('paste'); pause(0.5);
    
    if isempty(Value) % donot set value just get the info
        if exist('PreviousValue')~=1
            PreviousValue=CurrentValue;
            continue;
        end
        if strcmp(CurrentValue,PreviousValue)
%             Report=1;
%             Output=CurrentValue;
            Report=CurrentValue;
            break;
        else
            Report=0;
        end
    else % replace with Value
        if strcmp(CurrentValue,Value)
            Report=1;
            break;
        else
            clipboard('copy',Value); pause(0.5);
            inputemu('key_ctrl','v'); pause(0.5);
        end
    end
    if Trials>1
%         disp(['SetParameters_3: ',Value,' trials: ',num2str(Trials)]);
        if Trials>4
            Report=0;
            return;
        end
    end
    
end
% A1=1;