function axonalDystrophies()

global W;
F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(W.G.T.F{W.Task,1}.AxonalDystrophies{W.File},{'Step';'Do'});

FileList=W.G.T.F{W.Task};

Ind=find(FileList.Mouse==F.Mouse & FileList.Roi==F.Roi);
FileList=FileList(Ind,:);
FileList(FileList.TargetTimepoint==0,:)=[];


SourceChannels={1;2};
TargetChannels={'MetBlue';'MetRed';'MetBluePerc'};

FA=table;
FA.FilenameTotal=strcat(FileList.Filename,['.ids']);
FA.SourceChannel=repmat({[1;2]},[size(FA,1),1]);
FA.SourceTimepoint(:,1)=1;
try; FA.TargetChannel(strfind1(FileList.Filename,'blue'),1)={{'MetBlue';'MetRed'}}; end;
try; FA.TargetChannel(strfind1(FileList.Filename,'green'),1)={{'GfpmRed';'GfpmGreen'}}; end;
FA.TargetTimepoint=FileList.TargetTimepoint(:,1);
try; FA.Rotate=strcat(FileList.Rotate); end;
% FA.Selection=FileList.RatioPlaque(:,1);
% FA.RowSpecifier=FileList.RowSpecifier;
% FA=FA(strfind1(FA.Selection,'Do#'),:);
% for m=1:size(FA,1)
%     [Wave1]=fileSiblings_3(FA.FilenameTotal{m,1});
%     FA.FilenameTotal{m,1}=Wave1.FilenameTotal{'RatioB'};
% end
% for m=1:size(FA,1)
%     FA.SumCoef{m,1}=[zeros(3,2),FitCoefB2Trace(m,1:3).'];
% end

[FA,Volume]=calcSummedFitCoef_2(struct('FA',FA));

% if ischar(Criterium); Criterium={Criterium}; end;
% if strcmp(Criterium{1},'Step#2')
%     FA=FA(strfind1(FA.Selection,'Step#2'),:);
% elseif strcmp(Criterium{1},'CurrentFile')
%     FA=FA(strfind1(FA.FilenameTotal,F.Filename),:);
% elseif strcmp(Criterium{1},'TargetTimepoint')
%     FA=FA(FA.TargetTimepoint==Criterium{2},:);
% end

TLfilename=['Eva_Trace,M',num2str(F.Mouse),'Roi',num2str(F.Roi),'.ims'];
[~,~,TLpathRaw]=getFileinfo_2(TLfilename);

J.Pix=Volume.TotalVolumePix;
J.Res=Volume.Resolution;
J.UmStart=Volume.TotalVolumeUm(:,1);
J.UmEnd=Volume.TotalVolumeUm(:,2);
J.Timepoints=max(FA.TargetTimepoint);
J.PathInitialFile=TLpathRaw;
J.FA=FA;
J.BitType='uint8';

[FA]=merge3D_4(J); % (ch1-1).*double(logical(uint8(ch2-10)))
imarisSaveHDFlock(TLfilename);
Wave1=variableSetter_2(W.G.T.F{W.Task,1}.AxonalDystrophies{W.File},{'Do','Fin';'Step','1'});
iFileChanger('W.G.T.F{W.Task,1}.AxonalDystrophies{W.File}',Wave1);
