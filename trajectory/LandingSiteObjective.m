function Cost = LandingSiteObjective(X)
global Param
% Scoring function for the path
% For the given Intermediate Point, obtains S-turn Dubins path 
% and calculates its performance
   
xBDRYs = Param.xBDRYs;
yBDRYs = Param.yBDRYs;

% Option 1
    xL = X(1); % km
    yL = X(2); % km
    psi = X(3)*180/pi; % rad -> deg
%%
% xBDRYs = X_ini(:,1);
% yBDRYs = X_ini(:,2);


% constraint 1 : g1(xL, yL) == 0 : inpolygon
%     xq = 800*rand(100,1); yq = 350*rand(100,1);
%     in=inpolygon(xq,yq,xBDRYs,yBDRYs);
%     figure; hold on; title('Equality Constraint 1 (x_L,y_L): landing site inpolygon feasibility')
%         plot(xBDRYs,yBDRYs,'LineWidth',2) % polygon
%         axis equal
%         plot(xq(in),yq(in),'b+') % points inside
%         plot(xq(~in),yq(~in),'rx') % points outside
%         hold off
        
    % then, the constraint of pL = (xL, yL) should be
    %     in_pL = inpolygon(xL,yL,xBDRYs,yBDRYs);
    %     in_pL == 1 : in or on the polygon !!!
    %     in_pL == 0 : out of the polygon
    
    
% constraint 2 : g2(xL, yL, psiL) == 0 : landing direction & runway feasibility
    % (xL, yL, psi)
    xf_psiL = xL + 1000*cosd(psi);
    yf_psiL = yL + 1000*sind(psi);
    
    if true == inpolygon(xL,yL,xBDRYs,yBDRYs)
%         [xi, yi] = polyxpoly([xL, xf_psiL], [yL, yf_psiL], xBDRYs, yBDRYs);        
        X_inter = poly2poly([xL, xf_psiL; yL, yf_psiL], [xBDRYs'; yBDRYs']);
        
        % %
        if isempty(X_inter)            
            xend = xL;
            yend = yL;

            MaxRunwayDist = 0;
        else    
            for ii = 1:numel(X_inter(1,:))
                x_inter = X_inter(1,ii);
                y_inter = X_inter(2,ii);
                dummy_length = sqrt((xL-x_inter)^2 + (yL-y_inter)^2);
                if ii==1                    
                    MaxRunwayDist = dummy_length;
                    xend = x_inter;
                    yend = y_inter;
                else
                    if dummy_length < MaxRunwayDist
                        MaxRunwayDist = dummy_length;
                        xend = x_inter;
                        yend = y_inter;
                    end
                end
            end
        end
%             
%         % % 
%         xend = X_inter(1,1);
%         yend = X_inter(2,1);
%                 
%         MaxRunwayDist = sqrt((xL-xend)^2 + (yL-yend)^2);
    else
        xend = xL;
        yend = yL;
        
        MaxRunwayDist = 0;
    end
    
%     
%     figure; hold on; title('Equality Constraint 2 (x_L,y_L,\psi_L) : landing direction & runway length feasibility')
%         plot(xBDRYs,yBDRYs,'LineWidth',2) % polygon
%         axis equal
%         h_line = plot([xL, xend], [yL, yend], 'g:', 'LineWidth', 3);  
%         plot(xL, yL, 'bo')
%         quiver(xL, yL, 100*cosd(psi), 100*sind(psi), 'b')        
%         plot(xend, yend, 'rx')
%         
%         legend([h_line], {['Max Runway Length=' num2str(MaxRunwayDist)]})
        
    dist_min_pixel = mindistance(xL*1000/15, xend*1000/15, yL*1000/15, yend*1000/15);
%     dist_min_km = dist_min_pixel*15/1000; % pixel -> km    
    E_score = Distance_Emergencystation(dist_min_pixel);
    
    R_score = Runway_Length( sqrt((xL-xend)^2+(yL-yend)^2) );
    
    S_score = Runway_Slope(xL*1000/15, xend*1000/15, yL*1000/15, yend*1000/15);

%     Cost = E_score*R_score/S_score; 
    Cost = S_score; 
    
end


function [P_RL] = Runway_Length (RL)
if RL > 1
    P_RL = 1.5-log(RL-1); %change the value 1.1 to adjust function
else
    P_RL = 100;
end
end

function [P_SL]= Runway_Slope (xL,xend,yL,yend)
    dummy = load('slope.mat');
    x=linspace(xL,xend,30); % pixel
    y=linspace(yL,yend,30); % pixel
    for ii = 1:length(x)
%         [xL, xend]
        [yL, yend]
%         [ii,round(y(ii)),round(x(ii))]
        SL=dummy.slope(max(round(y(ii)),1),max(round(x(ii)),1))
        P_SL(ii)=exp(1)^(0.03*(SL-1)) %change the value 0.03 or/and 3 to adjust function
    end
    P_SL=max(P_SL);
end

function [P_DES]= Distance_Emergencystation (DES)
%-----Distance Penalty Funfction
e=exp(1);
P_DES=(1/(1+e^(5-0.2*DES*15/1000)));
end


