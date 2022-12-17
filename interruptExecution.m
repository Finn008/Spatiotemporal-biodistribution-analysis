function interruptExecution(Figure,Key,Time)

callstr = 'set(gcbf,''Userdata'',get(gcbf,''Currentkey'')) ; uiresume ' ;
if isempty(Figure)
    Figure = figure(...
        'name',['Press ',Key,' to interrupt processing'], ...
        'keypressfcn',callstr, ...
        'windowstyle','modal',...
        'numbertitle','off', ...
        'userdata','timeout') ;
    DeleteFigure=1;
else
    set(Figure,'keypressfcn',callstr,'userdata','timeout','windowstyle','modal');
    DeleteFigure=0;
end

pause(Time);

InputKey= get(Figure,'Userdata') ;  % and the key itself


if strcmp(Key,InputKey)
    keyboard;
    pause(10);
end
if DeleteFigure==1
    delete(Figure);
end