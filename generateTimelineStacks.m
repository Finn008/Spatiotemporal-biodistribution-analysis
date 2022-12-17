function generateTimelineStacks(MouseInfo,PlaqueListSingle)


% show all plaque of each mouse at one timepoint VglutVenus and Methoxy
for Mouse=1:size(MouseInfo,1)
    if strcmp(MouseInfo.TreatmentType(Mouse),'Control'); continue; end;
    generateTimelineStacks_AllPlaquesPerTimepoint_2(Mouse,MouseInfo,PlaqueListSingle);
end