function neuronalActivity(Path2Folder)
dbstop if error;
warning('off','all');
%% catch general data on mice
% Path2Folder='\\gnp42n\marvin\AG Herms Share\Finn\Petar\00 - TAU project pooled data';
%\\gnp42n\marvin\AG Herms Share\Petar\Tau Ca DATA
if exist('Path2Folder')==0
    Path2Folder='\\gnp42n\marvin\AG Herms Share\Petar\Vika_ca_data\input';
end

Path2InputData=[Path2Folder,'\Input data'];
[~,~,InputData]= xlsread(Path2InputData,1);

InputData=array2table(InputData(2:end,:),'VariableNames',InputData(1,:));

MouseInfo=InputData(:,{'MouseId','BirthDate','TreatmentType','Sex'});
MouseInfo.MouseId=cell2mat(MouseInfo.MouseId);

% % % VariableNames={'BirthDate';'SeedingDate';'IT1';'IT2';'IT3';'IT4';'IT5';'IT6';'IT7';'IT8';'IT9';'Dead'};
% VariableNames={'BirthDate';'SeedingDate';'IT1';'IT2';'IT3';'IT4';'IT5';'IT6';'IT7';'IT8';'IT9';'IT10';'IT11';'Dead'};
Wave1=InputData.Properties.VariableNames.';
VariableNames=['BirthDate';'SeedingDate';Wave1(strfind1(Wave1,'IT'));'Dead'];
for m=1:size(VariableNames,1)
    Var=VariableNames{m,1};
    for m2=1:size(InputData,1)
        try
            Wave1=datenum(InputData{m2,Var},'/yyyy.mm.dd');
            if m==1
                Birthdate(m2,1)=Wave1;
            else
                InputData(m2,Var)={{Wave1-Birthdate(m2,1)}};
            end
        end
    end
end

MouseInfo.AgeSeeding=cell2mat(InputData.SeedingDate);
MouseInfo.AgeDead=cell2mat(InputData.Dead);
MouseInfo.IT=cell2mat(table2array(InputData(:,strfind1(InputData.Properties.VariableNames.','IT'))));
MouseInfo.IT=MouseInfo.IT-repmat(MouseInfo.AgeSeeding,[1,size(MouseInfo.IT,2)]);

MouseInfo.Timepoints=sum(isnan(MouseInfo.IT)==0,2);


%% catch and analyse activity data of different parameters
% TotalTimes
% PercentageofWhiskingtime
% TotalWhiskingTimes
% ActiveTimes
% FrequencywithWhisking1min
% FrequencynoWhisking1min
% AreaUndertheCurve
% TransientsduringWhisking
% NumberofTransients


% frequency data
% DataTypes={'FrequencywithWhisking1min';'FrequencynoWhisking1min';'TotalTimes';'PercentageofWhiskingtime';'TotalWhiskingTimes';'ActiveTimes';'AreaUndertheCurve';'TransientsduringWhisking';'NumberofTransients'};
% DataTypes={'FrequencywithWhisking1min';'FrequencynoWhisking1min';'TotalTimes';'PercentageofWhiskingtime';'TotalWhiskingTimes';'ActiveTimes';'AreaUndertheCurve'};
DataTypes={'FrequencywithWhisking1min';'FrequencynoWhisking1min';'Areanowhisking';'Areayeswhisking'};
for m=1:size(DataTypes,1)
    neuronalActivity_FrequencyData(DataTypes{m},MouseInfo,Path2Folder);
end











