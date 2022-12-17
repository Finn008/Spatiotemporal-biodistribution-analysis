function statusNotifyer(Message)
handles = findall(0,'type','figure','Name','controlGUI_2');
handles=guidata(handles(1,1));
set(handles.notifier,'string',Message);
disp(Message);
pause(0.1);