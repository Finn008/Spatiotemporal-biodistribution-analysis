function [Report]=subfctSetStatistics()

for m=1:2
    inputemu('key_normal','\ALT'); pause(0.5);
    inputemu('key_normal','e'); pause(0.5);
    inputemu('key_normal','p'); pause(0.5);
    inputemu('key_normal','\DOWN'); pause(0.5);
    inputemu('key_normal','\DOWN'); pause(0.5);
    Report='Default';
    inputemu('key_ctrl','c'); pause(0.5);
    Report=safeClipboard('paste'); pause(0.5);
    if strcmp(Report,'System')
        break;
    else
    end
end

if strcmp(Report,'System')
    Report=1;
else
    Report=0;
    return;
end

inputemu(repmat({'key_normal';'\DOWN'},[1,8]),0.3); pause(0.3);
inputemu('key_normal','\TAB'); pause(0.3);
inputemu('key_normal',' '); pause(0.3); % uncheck or check all Cells statistics
inputemu('key_normal','\RIGHT'); pause(0.3);
inputemu('key_normal','\DOWN'); pause(0.3); % opposite check for one Cells statistics value
inputemu('key_normal',' '); pause(0.3); % check all
inputemu('key_normal','\TAB'); pause(0.3);
inputemu('key_normal',' '); pause(0.3); % check all
inputemu('key_normal','\TAB'); pause(0.3);
inputemu('key_normal','\ENTER'); pause(0.3);
