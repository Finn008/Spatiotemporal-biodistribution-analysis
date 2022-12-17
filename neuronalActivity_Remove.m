function neuronalActivity()

%% catch general data on mice
Path2Folder='\\gnp42n\marvin\AG Herms Share\Finn\Petar\00 - TAU project pooled data';

Path2InputData=[Path2Folder,'\Input data'];
[~,~,InputData]= xlsread(Path2InputData,1);

InputData=array2table(InputData(2:end,:),'VariableNames',InputData(1,:));

MouseData=InputData(:,{'Mouse','BirthDate','TreatmentType','Sex'});
MouseData.Mouse=cell2mat(MouseData.Mouse);

VariableNames={'BirthDate';'SeedingDate';'IT1';'IT2';'IT3';'IT4';'IT5';'IT6';'IT7';'IT8';'IT9';'Dead'};
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

MouseData.AgeSeeding=cell2mat(InputData.SeedingDate);
MouseData.AgeDead=cell2mat(InputData.Dead);
MouseData.IT=cell2mat(table2array(InputData(:,strfind1(InputData.Properties.VariableNames.','IT'))));
MouseData.IT=MouseData.IT-repmat(MouseData.AgeSeeding,[1,9]);



%% catch and analyse activity data of different mental states
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
DataTypes={'FrequencywithWhisking1min';'FrequencynoWhisking1min';'TotalTimes';'PercentageofWhiskingtime';'TotalWhiskingTimes';'ActiveTimes';'AreaUndertheCurve';'TransientsduringWhisking';'NumberofTransients'};
for m=1:size(DataTypes,1)
    neuronalActivity_FrequencyData(DataTypes{m},MouseData,Path2Folder);
end











