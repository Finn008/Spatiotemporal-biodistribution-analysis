function MouseInfo=finalEvaluation_Quantification(MouseInfo,TimeDistTable)

for TDTind=1:size(TimeDistTable,1)
    if strfind1({'Dystrophies1'},TimeDistTable.Mod{TDTind,1},1)
    else
        continue;
    end
    Mouse=find(MouseInfo.MouseId==TimeDistTable.MouseId(TDTind,1));
    RoiId=floor(TimeDistTable.Roi(TDTind,1));
    TDTRoi=find(MouseInfo.RoiInfo{Mouse,1}.Roi==RoiId);
    MouseInfoData=MouseInfo.RoiInfo{Mouse,1}.TraceData{TDTRoi}.Data{TimeDistTable.Pl(TDTind,1),1};
    Data=TimeDistTable.Data{TDTind,1}{:,:};
    NanCols=nansum(Data);
    NanCols=find(NanCols.'~=0);
    Wave1=table2struct(TimeDistTable(TDTind,:));
    if strfind1({'Dystrophies1';'Autofluo1'},TimeDistTable.Mod{TDTind,1},1)
        Wave1.Mod='Volume1';
    elseif strfind1({'Boutons1Number'},TimeDistTable.Mod{TDTind,1},1)
        Wave1.Mod='Volume2';
    end
    
    Ind=findTDTind(TimeDistTable,Wave1);
    VolumeData=TimeDistTable.Data{Ind,1}{:,:};
%     %% Autofluo1
%     if strcmp(TimeDistTable.Mod{TDTind,1},'Autofluo1')
%         if TimeDistTable.Sub(TDTind,1)~=1
%             continue;
%         end
%         
%         % calculate density between 0 and 10µm from plaque border compared to 20-40
%         BaselineFraction=nanmean(Data(71:91,:));
%         AutofluoFraction=nanmean(Data(50:65,:));
%         AutofluoFraction=AutofluoFraction-BaselineFraction;
%         Factor=AutofluoFraction./BaselineFraction;
%         AutofluoVol=VolumeData(50:65,:).*Data(50:65,:);
%         AutofluoVol=nansum(AutofluoVol);
%         
%         Wave1=table(AutofluoFraction.',BaselineFraction.',Factor.',AutofluoVol.','VariableNames',{'AutofluoFraction','AutofluoBaselineFraction','AutofluoFactor','AutofluoVol'});
%         MouseInfoData(NanCols,{'AutofluoFraction','AutofluoBaselineFraction','AutofluoFactor','AutofluoVol'})=Wave1(NanCols,:);
%         
%         
%     end
    %% Dystrophies
    if strcmp(TimeDistTable.Mod{TDTind,1},'Dystrophies1')
        if TimeDistTable.SubPool(TDTind,1)~=2
            continue;
        end
        Smooth=table;
        Smooth.Power=1;
        Smooth.Robust={[]};
        Smooth=repmat(Smooth,[3,1]);
        [Abl,Out1]=ableitung_2(Data,[],Smooth);
        Distance=nan(size(MouseInfoData,1),1);
        Baseline=nan(size(MouseInfoData,1),1);
        Volume=nan(size(MouseInfoData,1),1);
        Version=4;
        for Time=NanCols.'
            Baseline(Time,1)=weightedMean(Data(65:end,Time),VolumeData(65:end,Time));
            
            Yaxis=Data(:,Time);
            [Wave1]=sort(Yaxis(isnan(Yaxis)==0));
            Wave1=Wave1(round(size(Wave1,1)*4/5));
            Yaxis(Yaxis>Wave1)=nan;
            Xaxis=(1:256).';
            f = fittype('A1*x+A2','independent','x');
            [Fit,Gof]=fit((1:256).',Yaxis,f,'Exclude',isnan(Yaxis)==1);
            FitCoef=coeffvalues(Fit);
            % % % % %         plot(Fit,Xaxis,Yaxis);
            BaselineFit=Xaxis*FitCoef(1)+FitCoef(2);
            
            if Version==1 % find first Wendepunkt below Baseline and use Wendepunkt before that
                Wave1=Out1.MaximaLocs(1:7,3,Time);
                Wave1(:,2)=Data(Wave1(:,1),Time);
                Wave2=find(Wave1(:,2)<=Baseline(Time,1));
                Distance(Time,1)=Wave1(min(Wave2(:))-1,1);
            end
            if Version==2 % find last Wendepunkt within falling region
                Wave1=Out1.MaximaLocs(:,3,Time);
                Falling=find(Abl(50:end,2,Time)>-0.1)+50;
                Wave2=find(Wave1<=min(Falling(:))); Wave2=max(Wave2(:));
                Distance(Time,1)=Wave1(Wave2,1);
            end
            if Version==3
                % large 2.Abl value, 1.Abl is negative for at least 3µm, raw value above Baseline
                Wave1=table;
                Wave1.Abl2Maxima=Out1.MaximaLocs(:,3,Time);
                Wave1.Abl2Value=Out1.MaximaValues(:,3,Time);
                Wave1(isnan(Wave1.Abl2Maxima),:)=[];
                [~,Wave2]=sort(Wave1.Abl2Value);
                Wave1.Abl2Order(Wave2,1)=(size(Wave2,1):-1:1).';
                for m2=1:size(Wave1,1)
                    Wave1.RawValue(m2,1)=Data(Wave1.Abl2Maxima(m2,1),Time);
                    Wave1.FallingFor3um(m2,1)=max(Abl(Wave1.Abl2Maxima(m2,1)-2:Wave1.Abl2Maxima(m2,1),2,Time))<0;
                end
                Wave2=find(Wave1.Abl2Order<4&...
                    Wave1.FallingFor3um==1&...
                    Wave1.RawValue>Baseline(Time,1)&...
                    Wave1.Abl2Value>0.3);
                if isempty(Wave2) || size(Wave2,1)>1
                    keyboard;
                end
                Distance(Time,1)=Wave1.Abl2Maxima(Wave2,1);
            end
            if Version==4
                %             Distance(Time,1)=min(find(Data(:,Time)<Baseline(Time,1)*1.5));
                Distance(Time,1)=min(find(Data(:,Time)<BaselineFit*1.5));
            end
            Wave1=Data(:,Time)-BaselineFit;
            Wave1(Wave1<0)=0;
            Wave1=VolumeData(:,Time).*Wave1;
            Volume(Time,1)=nansum(Wave1(1:Distance(Time,1)));
        end
        Distance=Distance-50;
        Wave1=table(Distance,Volume,Baseline,'VariableNames',{'Dystrophy1Distance','Dystrophy1Volume','Dystrophy1Baseline'});
        MouseInfoData(1:size(Wave1,1),{'Dystrophy1Distance','Dystrophy1Volume','Dystrophy1Baseline'})=Wave1;
    end
    %% finish
    MouseInfo.RoiInfo{Mouse,1}.TraceData{TDTRoi,1}.Data{TimeDistTable.Pl(TDTind,1),1}=MouseInfoData;
end

