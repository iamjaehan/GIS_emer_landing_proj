function [path1, param1, type_str1, path2, param2, type_str2,length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2, pointB] = S_Dubins(pointM, pointF, dF)
    global pointA Param    
    m = 300000; S = 512;  K = 0.045;  CD0 = 0.022;   rho0 = 1.225;   rhoH = 0.4135;   g = 9.81;
    Param.gamma_max = 10*pi/180; Param.gamma_min = 3.5*pi/180;  
%     phi = 30*pi/180;   
    phi = 20*pi/180;   

    %  cos(gamma_min)=0.9981 ~ cos(gamma_max)=0.9848 
    %  --> let's take gamma_min only for the max. turn radius
    r_turn_max = 2*m/(rho0*S)*sqrt(K/CD0)*cos(Param.gamma_min)/tan(phi) / 10^3;
    TurnRadius = r_turn_max;
    Param.TurnRadius = r_turn_max;
    
    pointB = [ pointF(1) - dF*cos(pointF(3)), pointF(2) - dF*sin(pointF(3)), pointF(3), 0 + dF*tan(Param.gammaF)];  % km, km, rad, km
    
    [path1, param1, type_str1, length_S_SEG1, length_LR_SEG1, mid_pt1, mid_pt2] = dubins_curve_v2(pointA(1:3), pointM(1:3), TurnRadius, Param.PathStep);
    [path2, param2, type_str2, length_S_SEG2, length_LR_SEG2, mid_pt1, mid_pt2] = dubins_curve_v2(pointM(1:3), pointB(1:3), TurnRadius, Param.PathStep);            
%     figure('name','Dubins curve');
%     plot(path1(:,1), path1(:,2)); axis equal; hold on
%     plot(path2(:,1), path2(:,2)); axis equal; hold on
%     scatter(p1(1), p1(2), 45, '*','r','LineWidth',1); hold on;
%     scatter(p2(1), p2(2), 45, 'square','b','LineWidth',1); hold on;
%     text(p1(1), p1(2),'start','HorizontalAlignment','center');
%     text(p2(1), p2(2),'end','VerticalAlignment','top');
end