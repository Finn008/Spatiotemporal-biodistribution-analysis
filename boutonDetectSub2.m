function boutonDetectSub2(NameTable)
return; % discontinued
[Fileinfo,IndFileinfo,~]=getFileinfo_2(NameTable{'DeFin','FilenameTotal'});
Path2file=NameTable{'Ratio','Path2file'}{1};

FA=table;

FA.FilenameTotal={NameTable.FilenameTotal{'DeFin'}};

FA.RefFilename={RfilenameTotal;{''}};
FA.SourceChannel={2;1};
FA.SourceTimepoint=[1;1];
FA.TargetChannel={1;1};
FA.TargetTimepoint=[1;2];
FA.Range={[];[]};
try; FA.Rotate=Rotate; end;
FA.SumCoef{1}=FitCoef;


J=struct;
if exist('Application')==1
   J.Application=Application;
   FA(2,:)=[];
end

Pix=Rfileinfo.Pix{1}.*[0.5;0.5;1];
Res=Rfileinfo.Res{1}.*[2;2;1];

J.Pix=Pix;
J.Res=Res;
J.UmStart=Rfileinfo.UmStart{1};
J.UmEnd=Rfileinfo.UmEnd{1};
J.Channels=2;
J.Timepoints=1;
J.Overwrite=1;
J.PathInitialFile=TLpathRaw;

J.FA=FA;
J.BitType='uint16';

[Application]=merge3D_3(J);