function [c,ceq] = PathPlanCon(X)
    % X = [xL, yL, psiL, xM, yM, psiM, d_final]'
%     global pointA pointF Param
    global pointA Param

    pointF = X(1:3);    
    pointM = X(1+3:3+3);
    dF = X(5+3-1);
    
    xBDRYs = Param.xBDRYs;
    yBDRYs = Param.yBDRYs;
        
    pointB = [ pointF(1) - dF*cos(pointF(3)), pointF(2) - dF*sin(pointF(3)), pointF(3), 0 + dF*tan(Param.gammaF)];  % km, km, rad, km     
    [~, ~, ~, ~, ~, ~, length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2, ~] = S_Dubins(pointM, pointF, dF);
   
%% GIS Module Constraints
    % Eq. Cons. 1 : Feasible Landing Site
        g1 = inpolygon(pointF(1),pointF(2),xBDRYs,yBDRYs) - 1; 
    
    % Ineq. Cons. 1 : Landing Direction & Runway Feasibility
        xf_psiL = pointF(1) + (2*max(Param.dxBDRY_max,Param.dyBDRY_max)) * cos(pointF(3));
        yf_psiL = pointF(2) + (2*max(Param.dxBDRY_max,Param.dyBDRY_max)) * sin(pointF(3));
        
        X_inter = poly2poly([pointF(1), xf_psiL; pointF(2), yf_psiL], [xBDRYs'; yBDRYs']);
        if isempty(X_inter)            
            h1 = +10; % infeasible
        else    
            for ii = 1:numel(X_inter(1,:))
                x_inter = X_inter(1,ii);
                y_inter = X_inter(2,ii);
                dummy_length = sqrt((pointF(1)-x_inter)^2 + (pointF(2)-y_inter)^2);
                if ii==1                    
                    MaxRunwayDist = dummy_length;
                else
                    if dummy_length < MaxRunwayDist
                        MaxRunwayDist = dummy_length;
                    end
                end
            end
            
            % h1 = Param.MinRunway - MaxRunwayDist;
            h1 = (Param.MinRunway - MaxRunwayDist);
        end
    
%% FD Module Constraint
    tan_gamma_Dubins = (pointA(4) - pointB(4))/ (length_S_SEG1+length_LR_SEG1+length_S_SEG2+length_LR_SEG2);
    % Ineq. Const 2
        h2 = tan_gamma_Dubins - Param.gamma_max;
    % Ineq. Const 3
        h3 = Param.gamma_min - tan_gamma_Dubins;
    
    % Eq. Cons. 2 : Feasible Landing Site    
%         g2 = tan(X(4+3)) - (pointA(4) - pointB(4))/ (length_S_SEG1+length_LR_SEG1+length_S_SEG2+length_LR_SEG2);        
%         g2 = X(4+3) - atan2(pointA(4) - pointB(4),(length_S_SEG1+length_LR_SEG1+length_S_SEG2+length_LR_SEG2));        
    
    
    c   = [h1*10, h2, h3];        
    ceq = [g1]';
end