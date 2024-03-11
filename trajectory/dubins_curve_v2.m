% This function handles the interface to dubins_core.m to give a more 
% intuative tool within MATLAB
% Input: 
%   p1 / p2: two row vector that defines a 2-D point and starting/ending 
%            direction. e.g. [x, y, theta], 
%   r:  turning radius, set <=0 to automatically determined
%   stepsize: distance between each points used for graphics
% Output: the points data in stacked row vector
%
% Reference:
%       https://github.com/AndrewWalker/Dubins-Curves#shkel01
%       Shkel, A. M. and Lumelsky, V. (2001). "Classification of the Dubins
%                  set". Robotics and Autonomous Systems 34 (2001) 179좻202
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original Source: Andrew Walker
% MATLAB-lization: Ewing Kang
% Date: 2016.2.28
% contact: f039281310 [at] yahoo.com.tw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2016, Ewing Kang                                                 % 
%                                                                                %
% Permission is hereby granted, free of charge, to any person obtaining a copy   %
% of this software and associated documentation files (the "Software"), to deal  %
% in the Software without restriction, including without limitation the rights   %
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      %
% copies of the Software, and to permit persons to whom the Software is          %  
% furnished to do so, subject to the following conditions:                       %
%                                                                                %
% The above copyright notice and this permission notice shall be included in     %
% all copies or substantial portions of the Software.                            %
%                                                                                %
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     %
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       %
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    %
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         %
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  %
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN      %
% THE SOFTWARE.                                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [path, gamma, length_All, length_LR_SEG] = dubins_curve_v2(p1, p2, r, stepsize, hi, hf)
% tic
% [path, -gamma*180/pi, type_str, length_S_SEG, length_LR_SEG, real_mid_pt1, real_mid_pt2
%     close(findobj('type','figure','name','Dubins curve'));
    %%%%%%%%%%%%%%%%%%%%%%%%% DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % there are 6 types of dubin's curve, only one will have minimum cost
    % LSL = 1;
	% LSR = 2;
	% RSL = 3;
	% RSR = 4;
	% RLR = 5;
    % LRL = 6;
    
    % The three segment types a path can be made up of
    % L_SEG = 1;
    % S_SEG = 2;
    % R_SEG = 3;

    % The segment types for each of the Path types
    %{
    DIRDATA = [ L_SEG, S_SEG, L_SEG ;...
                L_SEG, S_SEG, R_SEG ;...
                R_SEG, S_SEG, L_SEG ;...
                R_SEG, S_SEG, R_SEG ;...
                R_SEG, L_SEG, R_SEG ;...
                L_SEG, R_SEG, L_SEG ]; 
    %}
            
    % the return parameter from dubins_core
    % param.p_init = p1;              % the initial configuration
    % param.SEG_param = [0, 0, 0];    % the lengths of the three segments
    % param.r = r;                    % model forward velocity / model angular velocity turning radius
    % param.type = -1;                % path type. one of LSL, LSR, ... 
    %%%%%%%%%%%%%%%%%%%%%%%%% END DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % main function
%     tic;
    param = dubins_core(p1, p2, r);
%     toc;
    if stepsize <= 0
        stepsize = dubins_length(param)/1000;
    end
%     tic;
    path = dubins_path_sample_many(param, stepsize);
%     toc
    
    
    %% Modified_Choi
    %%%%%%%%%%%%%%%%%%%%%%%%% DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The three segment types a path can be made up of
    L_SEG = 1;
    S_SEG = 2;
    R_SEG = 3;

    % The segment types for each of the Path types
    DIRDATA = [ L_SEG, S_SEG, L_SEG ;...
                L_SEG, S_SEG, R_SEG ;...
                R_SEG, S_SEG, L_SEG ;...
                R_SEG, S_SEG, R_SEG ;...
                R_SEG, L_SEG, R_SEG ;...
                L_SEG, R_SEG, L_SEG ]; 
    DIRDATA_str = { 'L_SEG, S_SEG, L_SEG' ;...
                    'L_SEG, S_SEG, R_SEG' ;...
                    'R_SEG, S_SEG, L_SEG' ;...
                    'R_SEG, S_SEG, R_SEG' ;...
                    'R_SEG, L_SEG, R_SEG' ;...
                    'L_SEG, R_SEG, L_SEG' };     
    %%%%%%%%%%%%%%%%%%%%%%%%% END DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Generate the target configuration
    types = DIRDATA(param.type, :);
    param1 = param.SEG_param(1);
    param2 = param.SEG_param(2);
    
%     mid_pt1 = dubins_segment( param1, p1, types(1) );
%     mid_pt2 = dubins_segment( param2, mid_pt1,  types(2) );
    
    real_mid_pt1 = dubins_path_sample( param, param1 * param.r );
    real_mid_pt2 = dubins_path_sample( param, (param1+param2) * param.r );
    type_str = DIRDATA_str{param.type};
    
    % Total length of S_SEG only
    length_All = sum(param.SEG_param*param.r);
    if ismember(param.type,[1, 2, 3, 4])
%         length_S_SEG = norm(mid_pt1(1:2)-mid_pt2(1:2));
        length_S_SEG  = param.SEG_param(2)*param.r;
        length_LR_SEG = length_All - length_S_SEG;
    else
        length_S_SEG = 0;
        length_LR_SEG = length_All;
    end
    
    %altitude consideration
    h=linspace(hi,hf,length(path(:,1)));
    path(:,3)=h;
    gamma=atan((hf-hi)/length_All);
    gamma=-gamma*180/pi;
    
%     disp('=== trajectory generation complete ===');
    A=['1. gliding angle : ',num2str(gamma), 'degrees'];
%     B=['2. flight distance : ',num2str(length_All), 'km'];
%     C=['3. ETA :',num2str(round(length_All/200*3600)),'sec',' (',num2str(length_All/200*60),'min)'];
%     disp(A); disp(B); disp(C)
%     toc
    %% plotting
%     figure('name','Dubins curve');
%     plot3(path(:,1), path(:,2), path(:,3)); axis equal; hold on
%     scatter3(p1(1), p1(2), hi, 45, 'x','r','LineWidth',1); hold on;
%     scatter3(p2(1), p2(2), hf, 45, 'square','b','LineWidth',1); hold on;
%     scatter(real_mid_pt1(1), real_mid_pt1(2), 45, 'o','r','LineWidth',1); hold on;
%     scatter(real_mid_pt2(1), real_mid_pt2(2), 45, 'o','r','LineWidth',1); hold on;
%     text(p1(1), p1(2),'start','HorizontalAlignment','center');
%     text(p2(1), p2(2),'end','VerticalAlignment','top');
%     quiver3(p1(1), p1(2), hi, cos(p1(3))*2, sin(p1(3))*2, -gamma, 'MaxHeadSize', 2)
%     quiver3(p2(1), p2(2), hf, cos(p2(3))*2, sin(p2(3))*2, -gamma, 'MaxHeadSize', 2)
%     
%     
%     delN_path1 = 10; % PathStep*10 [km] 간격으로 stem plot
%     
%     stem3(path(1:delN_path1:end,1), path(1:delN_path1:end,2), path(1:delN_path1:end,3), 'm', 'LineWidth', 0.1);
    
%     grid on
end

%% define functions
function path = dubins_path_sample_many( param, stepsize)
    if param.STATUS < 0
        path = 0;
        return
    end
    length = dubins_length(param);
    path = -1 * ones(floor(length/stepsize), 3);
    x = 0;
    i = 1;
    while x <= length
        path(i, :) = dubins_path_sample( param, x );
        x = x + stepsize;
        i = i + 1;
    end
    return
end

function length = dubins_length(param)
    length = param.SEG_param(1);
    length = length + param.SEG_param(2);
    length = length + param.SEG_param(3);
    length = length * param.r;
end


%{
 * Calculate the configuration along the path, using the parameter t
 *
 * @param path - an initialised path
 * @param t    - a length measure, where 0 <= t < dubins_path_length(path)
 * @param q    - the configuration result
 * @returns    - -1 if 't' is not in the correct range
%}
function end_pt = dubins_path_sample(param, t)
    if( t < 0 || t >= dubins_length(param) || param.STATUS < 0)
        end_pt = -1;
        return;
    end

    % tprime is the normalised variant of the parameter t
    tprime = t / param.r;

    % In order to take rho != 1 into account this function needs to be more complex
    % than it would be otherwise. The transformation is done in five stages.
    %
    % 1. translate the components of the initial configuration to the origin
    % 2. generate the target configuration
    % 3. transform the target configuration
    %      scale the target configuration
    %      translate the target configration back to the original starting point
    %      normalise the target configurations angular component

    % The translated initial configuration
    p_init = [0, 0, param.p_init(3) ];
    
    %%%%%%%%%%%%%%%%%%%%%%%%% DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The three segment types a path can be made up of
    L_SEG = 1;
    S_SEG = 2;
    R_SEG = 3;

    % The segment types for each of the Path types
    DIRDATA = [ L_SEG, S_SEG, L_SEG ;...
                L_SEG, S_SEG, R_SEG ;...
                R_SEG, S_SEG, L_SEG ;...
                R_SEG, S_SEG, R_SEG ;...
                R_SEG, L_SEG, R_SEG ;...
                L_SEG, R_SEG, L_SEG ]; 
    %%%%%%%%%%%%%%%%%%%%%%%%% END DEFINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Generate the target configuration
    types = DIRDATA(param.type, :);
    param1 = param.SEG_param(1);
    param2 = param.SEG_param(2);
    mid_pt1 = dubins_segment( param1, p_init, types(1) );
    mid_pt2 = dubins_segment( param2, mid_pt1,  types(2) );
    
    % Actual calculation of the position of tprime within the curve
    if( tprime < param1 ) 
        end_pt = dubins_segment( tprime, p_init,  types(1) );
    elseif( tprime < (param1+param2) ) 
        end_pt = dubins_segment( tprime-param1, mid_pt1,  types(2) );
    else 
        end_pt = dubins_segment( tprime-param1-param2, mid_pt2,  types(3) );
    end

    % scale the target configuration, translate back to the original starting point
    end_pt(1) = end_pt(1) * param.r + param.p_init(1);
    end_pt(2) = end_pt(2) * param.r + param.p_init(2);
    end_pt(3) = mod(end_pt(3), 2*pi);
    return;
end

%{
 returns the parameter of certain location according to an inititalpoint,
 segment type, and its corresponding parameter
%}
function seg_end = dubins_segment(seg_param, seg_init, seg_type)
    L_SEG = 1;
    S_SEG = 2;
    R_SEG = 3;
    if( seg_type == L_SEG ) 
        seg_end(1) = seg_init(1) + sin(seg_init(3)+seg_param) - sin(seg_init(3));
        seg_end(2) = seg_init(2) - cos(seg_init(3)+seg_param) + cos(seg_init(3));
        seg_end(3) = seg_init(3) + seg_param;
    elseif( seg_type == R_SEG )
        seg_end(1) = seg_init(1) - sin(seg_init(3)-seg_param) + sin(seg_init(3));
        seg_end(2) = seg_init(2) + cos(seg_init(3)-seg_param) - cos(seg_init(3));
        seg_end(3) = seg_init(3) - seg_param;
    elseif( seg_type == S_SEG ) 
        seg_end(1) = seg_init(1) + cos(seg_init(3)) * seg_param;
        seg_end(2) = seg_init(2) + sin(seg_init(3)) * seg_param;
        seg_end(3) = seg_init(3);
    end
end