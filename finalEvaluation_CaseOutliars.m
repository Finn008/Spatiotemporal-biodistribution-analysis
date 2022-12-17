function CaseOutliars=finalEvaluation_CaseOutliars(MouseInfo)


% exclude timepoints for plaque size definition
CaseOutliars=MouseInfo(:,'MouseId');
CaseOutliars.Properties.RowNames=strcat(num2strArray_2(MouseInfo.MouseId));
CaseOutliars('331','TimepointsPlaque')={{[7;8;9]}};

% % % CaseOutliars('314','InterpolateTp')={{[66.5]}};
% % % CaseOutliars('336','InterpolateTp')={{[-10.5]}};
% % % CaseOutliars('338','InterpolateTp')={{[-10.5]}};
% % % CaseOutliars('353','InterpolateTp')={{[10.5]}};
% % % CaseOutliars('375','InterpolateTp')={{[38.5]}};
% % % CaseOutliars('275','InterpolateTp')={{[24.5]}};
% % % CaseOutliars('331','InterpolateTp')={{[-10.5;87.5]}};
% % % CaseOutliars('351','InterpolateTp')={{[-17.5;10.5]}};
CaseOutliars('371','RemoveTp')={{[1]}};

