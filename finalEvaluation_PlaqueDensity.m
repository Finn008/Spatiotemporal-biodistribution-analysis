% analyse plaque radius, birth growth on a general scale pooling all plaques per mouse and per treatmenttype
function [MouseInfoTime,MouseInfo]=finalEvaluation_PlaqueDensity(MouseInfo,PlaqueList,MouseInfoTime)
global W;

% count BabyPlaques for each timepoint
% % % MouseInfoTime(:,'PlDensity')=[];
PlaqueList=PlaqueList(isnan(PlaqueList.PlBirth)==0,:);
for m=1:size(PlaqueList,1)
    PlaqueList.FinalRadius(m,1)=max(PlaqueList.PlaqueListSingle{m,1}.RadiusFit1);
    try
        PlaqueList.PlBirth(m,1)=PlaqueList.PlaqueListSingle{m,1}.Age(find(PlaqueList.PlaqueListSingle{m,1}.RadiusFit1>4,1));
    catch
        PlaqueList.FinalRadius(m,1)=0;
    end
    
end
PlaqueList(PlaqueList.FinalRadius<0.1,:)=[]; % previously <4

for m=1:size(MouseInfoTime,1)
    MouseId=MouseInfoTime.MouseId(m);
    MaxVolume=max(MouseInfoTime.TotalVolume(MouseInfoTime.MouseId==MouseId));
    Wave1=find(PlaqueList.MouseId==MouseId & PlaqueList.PlBirth==MouseInfoTime.Age(m));
    MouseInfoTime.PlBirth(m,1)=size(Wave1,1)/MouseInfoTime.TotalVolume(m)*1000000000;
    Wave1=find(PlaqueList.MouseId==MouseId & (PlaqueList.PlBirth<=MouseInfoTime.Age(m) | PlaqueList.PlBirth==0));
    MouseInfoTime.PlDensity(m,1)=size(Wave1,1)/MaxVolume*1000000000;
end
MouseInfoTime.PlDensity(MouseInfoTime.PlDensity==Inf)=NaN;
processSingleGroups(MouseInfo,MouseInfoTime,'PlDensity','TimeTo');
processSingleGroups(MouseInfo,MouseInfoTime,'PlDensity','Age');

% % % for MouseId=unique(MouseInfoTime.MouseId.')
% % %     continue;
% % %     Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
% % %     Opts=fitoptions('Method','NonlinearLeastSquares');
% % %     Opts.Robust='Bisquare';
% % %     Exclude=isnan(Selection.PlDensity);
% % %     Opts.Exclude=Exclude;
% % %     Opts.Upper=[+Inf,+Inf,0.2]; % 0.13
% % %     Opts.Lower=[0,-1,0];
% % % %     Opts.Startpoint=[0,20,0];
% % % %     Opts.MaxIter=70; % default 400
% % %     
% % %     Ft= fittype('Y0+Span*(1-exp(-K*x))',... % previously 'Y0+(Plateau-Y0)*(1-exp(-K*x))'
% % %         'dependent',{'y'},'independent',{'x'},...
% % %         'coefficients',{'Y0','Span','K'});
% % %     X=Selection.Age;
% % %     Y=Selection.PlDensity;
% % %     try
% % %         Fit=fit(X,Y,Ft,Opts);
% % %         figure; 
% % %         plot(Fit,X,Y);
% % %         Path=['\\GNP90N\share\Finn\Analysis\Output\Unsorted\PlaqueFormation'];
% % %         if exist(Path)~=7
% % %             mkdir(Path);
% % %         end
% % %         title([MouseInfo.TreatmentType{find(MouseInfo.Mouse==MouseId)},', M',num2str(MouseId)]);
% % %         saveas(gcf,[Path,'\M',num2str(MouseId),'.jpg'])
% % %         close Figure 1;
% % %     end
% % %     
% % %     
% % % end

