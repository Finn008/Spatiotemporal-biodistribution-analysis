% accessImarisManually(Application,struct('Function','DeleteChannel','ChannelList',{{'Dystrophies2';'Invert4'}}));
function accessImarisManually_2(Path2file,Application,In)
% global W;
v2struct(In);

if exist('Application')~=1 || isempty(Application)
    SaveFile=1;
end


for Trial=1:5
    if exist('Application')~=1 || isempty(Application)
        Application=openImaris_2(Path2file);
    end
    [Fileinfo]=getImarisFileinfo(Application);
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
        [Report]=deleteChannel(ChannelList,Fileinfo);
    else
        keyboard;
        [Report]=subfctSetStatistics();
    end
    
    if SetInvisible==1
        Application.SetVisible(0);
    end
    if Report==1
        break;
    else
        quitImaris(Application);
        clear Application;
    end
    pause(60*10);
end

if Report==0
    keyboard;
end

if exist('SaveFile')==1 && SaveFile==1
%     keyboard;
    imarisSaveHDFlock(Application,Path2file);
%     Application.FileSave(Path2file,'writer="Imaris5"');
%     quitImaris(Application);
end