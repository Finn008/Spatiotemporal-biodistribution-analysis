% allow access to macro in Excel 2010, Optionen/Sicherheitscenter/Einstellungen für Makros/ Zugriff auf das VBA-Projektobjektmodell vertrauen
function addExcelModule(MacroName,Excel)

% GenerateFunction_VBEScript(RelatedInput,MacroFileName);
Path2File=['C:\Users\Admins\Desktop\Finns\Computer\Matlab\mfiles\Excel Macros\',MacroName,'.txt'];

%Pointer to VB componenets
vbCom = Excel.VBE.ActiveVBProject.VBComponents;

%Delete any previous module and add new module
try
vbCom.Remove(vbCom.Item('Modul1'));
vbCom.Import(Path2File);
catch
vbCom.Import(Path2File);
end 