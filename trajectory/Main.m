% http://planning.cs.uiuc.edu/node821.html
% https://en.wikipedia.org/wiki/Dubins_path
%https://gieseanw.wordpress.com/2012/10/21/a-comprehensive-step-by-step-tutorial-to-computing-dubins-paths/
clc
clear
close all
tic
clear global

% global pointA pointF Param
global pointA Param
addpath('./J1_module')
%% Dubins curve test
    point0 = [ 20, -15,   90*pi/180, 3];  % km, km, rad, km   
%       % pointB = [ 20, 5,  +60*pi/180, NaN];  % km, km, rad, km
%     pointF = [ 19, 3, 180*pi/180, 0];  % km, km, rad, km
%     point0 = [ 20*rand(1,1), -20*rand(1,1), 180*rand(1,1)*pi/180, 3];
    
        dF_init = 5;
        Param.gammaF = 3.5*pi/180; % 3.5 degrees gliding angle
        gammaF = Param.gammaF;
%     pointB = [ pointF(1) - dF*cos(pointF(3)), pointF(2) - dF*sin(pointF(3)), pointF(3), 0 + dF*tan(gammaF)];  % km, km, rad, km    
    
    Param.gamma_max = 10*pi/180; 
    Param.gamma_min = 3.5*pi/180; 
    Param.MinRunway = 1.5;
    Param.PathStep = 0.030;   % km 30m step
    
    d0_margin = 5; Param.gamma0 = 3.5*pi/180; %km initial decision delay length
    pointA = [point0(1) + d0_margin*cos(point0(3)), point0(2) + d0_margin*sin(point0(3)),  point0(3), 3 - d0_margin*tan(Param.gamma0)]; %action point

%     pointB_init = [ pointF(1) - dF_init*cos(pointF(3)), pointF(2) - dF_init*sin(pointF(3)), pointF(3), 0 + dF_init*tan(Param.gammaF)];  % km, km, rad, km
%% Landing Area Search
    dum=load('PilwonBdryDB.mat');
    Param.xBDRYs = dum.xBDRYs * 15 /10^3;
    Param.yBDRYs = dum.yBDRYs * 15 /10^3;
    Param.dxBDRY_max = max(Param.xBDRYs) - min(Param.xBDRYs);
    Param.dyBDRY_max = max(Param.yBDRYs) - min(Param.yBDRYs);

%% Optimization : Flight Path
% Objective : 
% Decision variable : X = [xL,yL,psiL, xM,yM,psiM, gamma_total_avg,d_final]
% Constraints
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = [min(Param.xBDRYs), min(Param.yBDRYs), -pi,  -Inf, -Inf,  -pi,    5];
    ub = [max(Param.xBDRYs), max(Param.yBDRYs), +pi,   Inf,  Inf,   pi,    10];
    nonlcon = @PathPlanCon;

    options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',2000 ...
                           , 'MaxIterations', 20);

    % x0 = [1.5, 1.5, 1.5];
    w1 = 0.5;  w2 = 0.5; dF_init = 6;
%         pointB_init = [ pointF(1) - dF_init*cos(pointF(3)), pointF(2) - dF_init*sin(pointF(3)), pointF(3), 0 + dF_init*tan(Param.gammaF)];  % km, km, rad, km
        
%     X0 = [w1*pointA(1:2) + w2*pointB_init(1:2), -(w1*pointA(3)+w2*pointB_init(3)), Param.gamma_min, dF_init];
%     X0 = [10, 2, 0, pointA(1) + 5*cos(pointA(3)), pointA(2) + 5*sin(pointA(3)), pointA(3), Param.gamma_min, dF_init];
    
%     X0 = [1.44, 2.5, pi/2, pointA(1) + 5*cos(pointA(3)), pointA(2) + 5*sin(pointA(3)), pointA(3), dF_init];
    X0 = [1.44, 2.4, pi/2, 10, -5, pi/2, dF_init];
    %destination
%     X0 = x_opt2
    [x_opt2, fval2, exitflag2, output2, lambda2] = fmincon(@TotalObjective, X0, A, b, Aeq, beq, lb, ub, nonlcon, options);
        
    
%% Obtained Flight Path

h0 = 0;
pointF = [x_opt2(1:3), h0];
pointM = [x_opt2(1+3:3+3), NaN];  % km, km, rad, km
% gamma_avg_opt = x_opt2(4+3);
dF_opt = x_opt2(5+3-1);

[path1, param1, type_str1, path2, param2, type_str2, length_S_SEG1, length_LR_SEG1, length_S_SEG2, length_LR_SEG2, pointB] = S_Dubins(pointM(1:3), pointF(1:3), dF_opt);
    

%% Plot the Obtained Flight Path & Analysis     
    % Dubins type & """""Length of STRAIGHT segment""""""
    disp(['=== Dubins type : {' type_str1 '}', ', {' type_str2 '}'])
    disp(['=== Length of STRAIGHT Segment : ' num2str(length_S_SEG1 + length_S_SEG2) ' km '])
    disp(['=== Length of CURVED Segment   : ' num2str(length_LR_SEG1 + length_LR_SEG2) ' km '])
    disp(['=== J_opt   : ' num2str(fval2) ])
    
    L_turn  = length_LR_SEG1 + length_LR_SEG2;
    L_total = length_S_SEG1 + length_S_SEG2 + length_LR_SEG1 + length_LR_SEG2;
    H       = pointA(4) - pointB(4);
    
    % Altitude analysis
%     gamma_opt = x_opt2();
    gamma_Dubins = atan2(H, L_total);
%         disp(['=== average total gamma (gliding angle) : ' num2str(gamma_avg_opt*180/pi) ' deg']);
        disp(['=== average total gamma (gliding angle) : ' num2str(gamma_Dubins*180/pi) ' deg']);
    pointM(4) = H*(1 - (length_S_SEG1+length_LR_SEG1)/L_total) + pointB(4);
    
    N_path1 = numel(path1(:,1));
    N_path2 = numel(path2(:,1));
    path1(:,4) = linspace(pointA(4), pointM(4), N_path1)';
    path2(:,4) = linspace(pointM(4), pointB(4), N_path2)';
    
    % mid_points
    % plot(mid_pt1(1), mid_pt1(2), '^')
    % plot(mid_pt2(1), mid_pt2(2), 'v')
    % legend('Dubins Path', 'Start', 'End', 'Mid Point 1', 'Mid Point 2')
    
    % Plot Feasible Landing Area    
    figure('name','Dubins curve');
    axis equal; hold on   
    plot(Param.xBDRYs, Param.yBDRYs , 'r-')
    
    % Plot Slope ditbn
    [X,Y]=meshgrid(0:800,0:350);
    X_SlpKm = X*15/1000;
    Y_SlpKm = Y*15/1000;
    load('slope.mat')
    mesh(X_SlpKm, Y_SlpKm, slope - 50)
    
    % Plot Ambulance
    xamb_km=[500,900,450,750,60,650,200, 700, 100]/3 * 15/1000;
    yamb_km=[1000, 1000, 190, 150, 864,1200, 1450, 600, 100]/3 * 15/1000;
    
        plot(xamb_km,yamb_km,'*')
%         plot(xmid,ymid,'*')
%         plot(xamb(idx),yamb(idx),'or')

    
    % Plots   
    plot(X0(1), X0(2), 'r+')
    
    plot3(path1(:,1), path1(:,2), path1(:,4));    
    plot3(path2(:,1), path2(:,2), path2(:,4));   
    
    delN_path1 = 30; % PathStep*10 [km] 간격으로 stem plot
    delN_path2 = 30;
    
    stem3(path1(1:delN_path1:end,1), path1(1:delN_path1:end,2), path1(1:delN_path1:end,4), 'm', 'LineWidth', 0.1);
    stem3(path2(1:delN_path2:end,1), path2(1:delN_path2:end,2), path2(1:delN_path2:end,4), 'm', 'LineWidth', 0.1);    
    
    plot3(point0(1), point0(2), point0(4), 'cs','LineWidth',2); hold on;
    plot3(pointA(1), pointA(2), pointA(4), 'rs','LineWidth',2); hold on;
    plot3(pointM(1), pointM(2), pointM(4), 'ks','LineWidth',2); hold on;
    plot3(pointB(1), pointB(2), pointB(4), 'gs','LineWidth',2); hold on;
    plot3(pointF(1), pointF(2), pointF(4), 'bs','LineWidth',2);
    
    % Start, End heading vector
    Cgam = cos(gamma_Dubins); Sgam = sin(gamma_Dubins);
    quiver3(pointA(1), pointA(2), pointA(4), cos(pointA(3))*Cgam, sin(pointA(3))*Cgam, -Sgam, 'MaxHeadSize', 2)
    quiver3(pointM(1), pointM(2), pointM(4), cos(pointM(3))*Cgam, sin(pointM(3))*Cgam, -Sgam, 'MaxHeadSize', 2)
    quiver3(pointB(1), pointB(2), pointB(4), cos(pointB(3))*Cgam, sin(pointB(3))*Cgam, -Sgam, 'MaxHeadSize', 2)   
    quiver3(pointF(1), pointF(2), pointF(4), cos(pointF(3))*cos(gammaF), sin(pointF(3))*cos(gammaF), -sin(gammaF), 'MaxHeadSize', 2)   
    
%     % Initial Guess Vector
%     
%     plot3(X0(1), X0(2), 0, 'kd','LineWidth',2);
%     quiver3(X0(1), X0(2), 0, cos(X0(3))*Cgam, sin(X0(3))*Cgam, -Sgam, 'MaxHeadSize', 2)   
%     
%     plot3(pointB_init(1), pointB_init(2), pointB_init(3), 'gd','LineWidth',2);
%     quiver3(pointB_init(1), pointB_init(2), pointB_init(4), cos(pointB_init(3))*Cgam, sin(pointB_init(3))*Cgam, -Sgam, 'MaxHeadSize', 2)   
%     
%     line([pointA(1), pointB_init(1)], [pointA(2), pointB_init(2)], [pointA(4), pointB_init(4)], 'LineStyle', '--', 'Color', 'g')
    
    
    % Initial margin & Appraoch path & Runway
    line([point0(1), pointA(1)], [point0(2), pointA(2)], [point0(4), pointA(4)])    
    line([pointF(1), pointB(1)], [pointF(2), pointB(2)], [pointF(4), pointB(4)])
    line([pointF(1), pointF(1) + 1*cos(pointF(3))], [pointF(2), pointF(2) + 1*sin(pointF(3))], [0, 0], 'LineWidth', 5)
    
    % labels
    xlabel('x(km)')
    ylabel('y(km)')
    
    % grid
    grid on
    
   