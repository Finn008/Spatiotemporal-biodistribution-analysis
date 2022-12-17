function setParameters_2(Value,Pos,Version)
if exist('Version')==0
    Version=1;
end
Report=0;
Trials=0;
while Report==0
    if Version==1
        Trials=Trials+1;
        if exist('Pos')
            inputemu('normal',Pos); pause(0.5);
        end
        inputemu({'key_normal';'\END'}); pause(0.5);
        inputemu({'key_down';'\SHIFT'}); pause(0.5);
        inputemu({'key_normal';'\HOME'}); pause(0.5);
%         inputemu(repmat({'key_normal';'\LEFT'},[1,100]));
        inputemu({'key_up';'\SHIFT'}); pause(0.5);
        inputemu('key_ctrl','c'); pause(0.5);
        CurrentValue=clipboard('paste'); pause(0.5);
        
        if strcmp(CurrentValue,Value)
            Report=1;
            break;
        else
            clipboard('copy',Value); pause(0.5);
            inputemu('key_ctrl','v'); pause(0.5);
        end
        if Trials>1
            disp(Trials);
            if Trials>4
                keyboard;
            end
        end
    end
end
A1=1;