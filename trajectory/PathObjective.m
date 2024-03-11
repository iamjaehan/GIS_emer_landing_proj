function Cost = PathObjective(X)
% global pointA pointB Param
% Scoring function for the path
% For the given Intermediate Point, obtains S-turn Dubins path 
% and calculates its performance

% Option 1
%     Cost = tan(X(4));
%     Cost = X(1);
    
% % Option 2
%     [~, ~, ~, ~, ~, ~, length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2] = S_Dubins(X(1:3));
%     
%     Cost = (length_LR_SEG1 + length_LR_SEG2)/max(length_S_SEG1+length_S_SEG2,1);
%     Cost = (length_LR_SEG1 + length_LR_SEG2)/(length_S_SEG1+length_LR_SEG1+length_S_SEG2+length_LR_SEG2);
    
    
% Option 3
%     [~, ~, ~, ~, ~, ~, length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2] = S_Dubins(X(1:3));
%     
%     % Cost = (length_LR_SEG1 + length_LR_SEG2)/max(length_S_SEG1+length_S_SEG2,1);
%     Cost = (length_LR_SEG1 + length_LR_SEG2);
   
% Option 4
    dF = X(5+3-1);
    [~, ~, ~, ~, ~, ~, length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2, ~] = S_Dubins(X(1+3:3+3), X(1:3), dF);
%     Cost = (length_LR_SEG1 + length_LR_SEG2) / (length_S_SEG1+length_S_SEG2 + dF);
%     Cost = (length_LR_SEG1 + length_LR_SEG2) / (dF);
    Cost = (length_LR_SEG1 + length_LR_SEG2) + 0.2*(length_S_SEG1+length_S_SEG2);
    
end

