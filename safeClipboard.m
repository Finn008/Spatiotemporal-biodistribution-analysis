function [Out]=safeClipboard(Input)

if strcmp(Input,'paste')
    for m=1:20
        try
            Out=clipboard('paste'); pause(0.5);

            return;
        end
    end
    keyboard;
    Out=[];
else
    for m=1:20
        try
            clipboard('copy',Input);
            pause(m);
            [Wave1]=safeClipboard('paste');
            if strcmp(Wave1,Input)
                Out=Wave1;
                return;
            end
        end
    end
    keyboard;
    Out=[];
end