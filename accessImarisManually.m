% accessImarisManually(Application,struct('Function','DeleteChannel','ChannelList',{{'Dystrophies2';'Invert4'}}));
function accessImarisManually(Application,In)
global W;
v2struct(In);

if ischar(Application)
    Path2file=Application;
    Application=openImaris_2(Path2file);
    SaveFile=1;
end
[Fileinfo]=getImarisFileinfo(Application);

for m1=1:10
% % %     mouseMoveController(1);
    if Application.GetVisible==0;
        SetInvisible=1;
    else
        Application.SetVisible(0);
        SetInvisible=0;
    end
    inputemu(transpose({'key_down','\WINDOWS';'key_normal','d';'key_up','\WINDOWS'}),1);
    Application.SetVisible(1); pause(1);
    Application.SetVisible(0); pause(1);
    Application.SetVisible(1); pause(3);
    inputemu('normal',[900,900]); pause(1);
    pause(5);
    
    if strcmp(Function,'DeleteChannel')
%         [Report]=deleteChannel(Application,ChannelList,Fileinfo,Path2file);
        [Report]=deleteChannel(ChannelList,Fileinfo);
    else
        keyboard;
        [Report]=subfctSetStatistics();
    end
    
    if SetInvisible==1
        Application.SetVisible(0);
    end
% % %     mouseMoveController(0);
    if Report==1
        break;
    end
    pause(m1*10);
end

if Report==0
    keyboard;
end

% save
if exist('SaveFile')==1 && SaveFile==1
% if exist('Path2file')
    keyboard;
    Application.FileSave(Path2file,'writer="Imaris5"');
    quitImaris(Application);
end