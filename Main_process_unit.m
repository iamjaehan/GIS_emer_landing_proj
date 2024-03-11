clear all
close all
clc

%% initialize
% parameter
sample_quality=9;

% aircraft status
initial=[502,1093,pi/4]; % for seoul
% initial=[286,958,-pi/4*3]; %for manhattan
altitude=1; %km
vel= 250; %km/h
delay = 10; %s

%% loading preprocessed data / settings
tic
addpath('./mapping');
addpath('./trajectory');

% landuse=load('landuse_manhattan.mat');
% image=imread('manhattan_landuse.png');
% dem=load('dem_manhattan.mat');

image=imread('seoul_landuse.png');
landuse=load('landuse_seoul.mat');
dem=load('dem_seoul.mat');
slope=dem.slope;
height=dem.height;

town=landuse.landuse{1};
landuse_open=landuse.landuse{4}; %handle this one
landuse_water=landuse.landuse{2};

%% Process
n=sample_quality;
disp('===== water landing =====')
[finalset_w,score_set_w]=operator(landuse_water,town,dem,initial,altitude,vel,delay,n);
disp('===== field landing =====')
[finalset_op,score_set_op]=operator(landuse_open,town,dem,initial,altitude,vel,delay,n);
%% 
finalset.traj=[finalset_w.traj(:,1);finalset_op.traj(:,1)];
finalset.rwy=[finalset_w.rwy(:,1);finalset_op.rwy(:,1)];
% finalset.traj=finalset_w.traj(:,1);
% finalset.rwy=finalset_w.rwy(:,1);
score_set=[score_set_w;score_set_op];
% score_set=score_set_w;
%% Visualize
%objective space plot
figure('name','objective space');
hold on
plot(score_set_w(:,1),score_set_w(:,2),'blue');
plot(score_set_w(:,1),score_set_w(:,2),'bo');
plot(score_set_op(:,1),score_set_op(:,2),'r');
plot(score_set_op(:,1),score_set_op(:,2),'ro');
for i = 1:length(score_set_w)
    text(score_set_w(i,1), score_set_w(i,2), num2str(i),'VerticalAlignment','top');
end    
for i = 1:length(score_set_op)
    text(score_set_op(i,1), score_set_op(i,2), num2str(i),'VerticalAlignment','top');
end   
xlim([0 inf])
ylim([0 inf])
axis tight
title('objective space','fontsize',15)
xlabel('trajectory score','fontsize',14)
ylabel('area score','fontsize',14)
grid on


% map visualization
colorimage=imread('colormap_seoul.png');
% colorimage=imread('colormap_manhattan.png');
% figure('name','generated runway');
figure(2)
hold on
% imshow(landuse)
% imshow(image)
imshow(colorimage)

% for i=1:length(point)
%     hold on
%     plot(point{i}(2),point{i}(1),'ro')
% end

for i = 1:length(finalset_w.traj)
    hold on
    plot(finalset_w.traj{i}{1}(:,2),finalset_w.traj{i}{1}(:,1),'cyan')
    plot([finalset_w.rwy{i}{1}{1}(2),finalset_w.rwy{i}{1}{2}(2)],[finalset_w.rwy{i}{1}{1}(1),finalset_w.rwy{i}{1}{2}(1)],'b')
%     text(finalset.rwy{i}{1}{1}(2), finalset.rwy{i}{1}{1}(1),num2str(i),'VerticalAlignment','top');
    text(finalset_w.rwy{i}{1}{2}(2), finalset_w.rwy{i}{1}{2}(1),num2str(i),'VerticalAlignment','top');
end
for i = 1:length(finalset_op.traj)
    hold on
    plot(finalset_op.traj{i}{1}(:,2),finalset_op.traj{i}{1}(:,1),'y')
    plot([finalset_op.rwy{i}{1}{1}(2),finalset_op.rwy{i}{1}{2}(2)],[finalset_op.rwy{i}{1}{1}(1),finalset_op.rwy{i}{1}{2}(1)],'b')
%     text(finalset.rwy{i}{1}{1}(2), finalset.rwy{i}{1}{1}(1),num2str(i),'VerticalAlignment','top');
    text(finalset_op.rwy{i}{1}{2}(2), finalset_op.rwy{i}{1}{2}(1),num2str(i),'VerticalAlignment','top');
end


hold on
quiver(initial(2), initial(1), cos(initial(3))*40, sin(initial(3))*40, 'MaxHeadSize', 3)
scatter(initial(2), initial(1), 'filled','d')

%display

disp('=== visualization complete ===')
A=[num2str(length(finalset.traj)),' reasonable choices generated'];
disp(A)

disp(' ')
disp('==========================')
disp('==== Process Complete ====')
disp('==========================')
disp(' ')
toc
prompt='What is your choice : ';
x = input(prompt);
%% 3D visualize
figure('name','selected trajectory');
for i = x
    hold on
    plot3(finalset.traj{i}{1}(:,2),finalset.traj{i}{1}(:,1),finalset.traj{i}{1}(:,3)*30,'g')
    plot([finalset.rwy{i}{1}{1}(2),finalset.rwy{i}{1}{2}(2)],[finalset.rwy{i}{1}{1}(1),finalset.rwy{i}{1}{2}(1)],'b')
%     text(finalset.rwy{i}{1}{1}(2), finalset.rwy{i}{1}{1}(1),num2str(i),'VerticalAlignment','top');
    text(finalset.rwy{i}{1}{2}(2), finalset.rwy{i}{1}{2}(1),num2str(i),'VerticalAlignment','top');
end
hold on
surf(flipud(height))
shading interp
hold on
delN_path1 = 300; % PathStep*10 [km] 간격으로 stem plot
stem3(finalset.traj{x}{1}(1:delN_path1:end,2), finalset.traj{x}{1}(1:delN_path1:end,1), finalset.traj{x}{1}(1:delN_path1:end,3)*30, 'm', 'LineWidth', 0.1);
hold on
scatter3(initial(2), initial(1), altitude*1000, 'filled','dr')
title('final trajectory profile','fontsize',15)