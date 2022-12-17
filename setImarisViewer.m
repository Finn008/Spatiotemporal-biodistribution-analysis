% eViewerSlice, eViewerSection, eViewerGallery, eViewerEasy3D, eViewerSurpass, eViewerColoc
function setImarisViewer(Application,viewer)
global W;
if strcmp(viewer,'surpass')
    Application.SetViewer(Imaris.tViewer.eViewerSlice);
    Application.SetViewer(Imaris.tViewer.eViewerSurpass);
    try
        Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(0));
        Report=1;
    catch
        
%         keyboard;
        % Create the surpass scene
        SurpassScene = Application.GetFactory.CreateDataContainer;
        SurpassScene.SetName('Surpasss Scene');
        % Add Light Source, Frame, Volume
        LightSource = Application.GetFactory.CreateLightSource;
        LightSource.SetName('Light Source 1');
        Frame=Application.GetFactory.CreateFrame;
        Frame.SetName('Frame');
        Volume=Application.GetFactory.CreateVolume;
        Frame.SetName('Volume');
        %% Set up the surpass scene
        Application.SetSurpassScene(SurpassScene);
        Application.GetSurpassScene.AddChild(LightSource,-1);
        Application.GetSurpassScene.AddChild(Frame,-1);
        Application.GetSurpassScene.AddChild(Volume,-1);
        
        
        Application.SetViewer(Imaris.tViewer.eViewerSlice);
        Application.SetViewer(Imaris.tViewer.eViewerSurpass);
    end
end


return;
%% out



keyboard; % differentiate between adding volume and pressing surpass
%         try SetSurpassScene, vSurpassScene = Application.GetSurpassScene;
Report=0;

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

ImarisVersion = char(Application.GetVersion);
Type='AddVolume'; % 'PressSurpass'
if strcmp(Type,'AddVolume')
    for m=1:2
        inputemu('key_normal','\ALT'); pause(1);
        inputemu('key_normal','s'); pause(1);
        %                 inputemu('key_normal','\Right'); pause(1);
        if strfind1(ImarisVersion,'7.7.2')
            inputemu(repmat({'key_normal';'\DOWN'},[1,12]),0.3);
        elseif strfind1(ImarisVersion,'7.6.0')
            inputemu(repmat({'key_normal';'\DOWN'},[1,12]),0.3);
        end
        inputemu('key_normal','\ENTER'); pause(0.5);
        inputemu('key_normal','_ALT'); pause(0.5);
        try
            Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(0));
            Report=1;
            break;
        end
    end
    
    
    
    
    
elseif strcmp(Type,'PressSurpass')
    for m=1:2
        inputemu('key_normal','\ALT'); pause(1);
        inputemu('key_normal','e'); pause(1);
        inputemu('key_normal','\Right'); pause(1);
        inputemu(repmat({'key_normal';'\DOWN'},[1,4]),0.3); pause(0.3);
        try
            Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(0));
            Report=1;
            break;
        end
    end
end
if Report==0
    keyboard;
end

if SetInvisible==1
    Application.SetVisible(0);
end

% % % mouseMoveController(0);

CurrentViewer=Application.GetViewer; % otherwise surface not generated
%         vVolume=Application.GetFactory.CreateVolume;
%         vSurpassScene = Application.GetSurpassScene;
%         vSurpassScene.AddChild(vVolume, -1);
%         Application.GetSurpassScene.AddChild(vVolume, -1);
%         keyboard; % if Version 7.7.2 then one more DOWN
%         A1=Application.GetFactory.CreateVolume;

%         SurpassScene = Application.GetSurpassScene;
%         SurpassScene.AddChild(A1,-1);
% % % %         mouseMoveController(1);
% % % %         inputemu(transpose({'key_down','\WINDOWS';'key_normal','d';'key_up','\WINDOWS'}),0.5);
% % % %         Application.SetVisible(1);
% % % %         pause(3);
% % % %         inputemu('key_normal','\ALT'); pause(1);
% % % %         inputemu('key_normal','s'); pause(1);
% % % %
% % % %         ImarisVersion = char(Application.GetVersion);
% % % %         if strfind1(ImarisVersion,'7.7.2')
% % % %             inputemu(repmat({'key_normal';'\DOWN'},[1,12]),0.3);
% % % %         else
% % % %             inputemu(repmat({'key_normal';'\DOWN'},[1,11]),0.3);
% % % %         end
% % % %         inputemu('key_normal','\ENTER'); pause(0.5);
% % % %         inputemu('key_normal','_ALT'); pause(0.5);
% % % %         pause(2);
% % % %         Application.SetVisible(0);
% % % %
% % % %         try
% % % %             Application.SetSurpassSelection(Application.GetSurpassScene.GetChild(0));
% % % %             disp('surpass selector');
% % % %         catch
% % % %             keyboard;
% % % %             A1=asdf;
% % % %         end
% % % %         mouseMoveController(0);