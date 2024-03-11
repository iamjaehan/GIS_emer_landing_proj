function Cost = TotalObjective(X)
% global pointA pointB Param
% Scoring function for the path
% For the given Intermediate Point, obtains S-turn Dubins path 
% and calculates its performance

    w1 = 1;
    w2 = 0;
    Cost = w1*LandingSiteObjective(X) + w2*PathObjective(X);    
end

