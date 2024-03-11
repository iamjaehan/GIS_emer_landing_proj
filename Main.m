close all
clear all
clc;

% parameter
sample_quality=10;

%% loading preprocessed data / settings
addpath('./mapping');
addpath('./trajectory');
% landuse=load('landuse_amsterdam.mat');

% landuse=load('landuse_manhattan.mat');
% image=imread('manhattan_landuse.png');
% dem=load('dem_manhattan.mat');

image=imread('seoul_landuse.png');
landuse=load('landuse_seoul.mat');
dem=load('dem_seoul.mat');
slope=dem.slope;
height=dem.height;

town=landuse.landuse{1};
landuse=landuse.landuse{2}; %handle this one

% aircraft status
initial=[502,1093,pi/4]; % for seoul
% initial=[286,958,-pi/4*3]; %for manhattan
altitude=1; %km
vel= 250; %km/h
delay = 10; %s

%% rwy generation
tic
[point,matrix]=boundary_pointgen(landuse,sample_quality);
disp('=== feasible area selection complete ===');
[rwy,k]=rwy_gen(point,landuse,height);
disp('=== runway generation complete ===');
A=[num2str(k),' runway candidates'];
disp(A);
% pixel dimension output



%% trajectory generation
altitude = altitude*33; %in pixel
[couple_set,k]=traj_gen(rwy,initial,altitude,1,vel,delay); %rwy info. + traj info.
disp('=== trajectory generation complete ===');
A=[num2str(k),' possible combinations'];
disp(A);
%km-s dimension
traj=couple_set.traj;

%% Evaluation
[ascore,tscore,r,CG]=scoring(couple_set,slope,town);
ascore(:,4)=sum(ascore,2);
disp('=== evaluation complete ===');

%% Filter out meaningless selections - Pareto front selection
setnum=pareto_frontier(ascore,tscore); %Meaningful ones survive
finalset=[];
a=1;
for i = 1:length(setnum)
    finalset.traj{a}=couple_set.traj(setnum(i),:);
    finalset.rwy{a}=couple_set.rwy(setnum(i),:);
    a=a+1;
    score_set(i,1)=tscore(setnum(i),4);
    score_set(i,2)=ascore(setnum(i),4);
end



%% Post process - sorting

[B,I]=sort(score_set);
I1=I(:,1);
B=score_set(:,2);
score_set=[score_set(I1),B(I1)];

finalset.traj=finalset.traj(I);
finalset.rwy=finalset.rwy(I);
% traj=couple_set.traj;
% colorimage=imread('colormap_seoul.png');
% imshow(colorimage)
% for i = 1:length(rwy)
%     hold on
%     plot([rwy{i}{1}(2),rwy{i}{2}(2)],[rwy{i}{1}(1),rwy{i}{2}(1)],'b')
% end
% for i = 1:length(traj(:,1))
%     hold on
%     plot(traj{i}(:,2),traj{i}(:,1),'r')
% %     A=num2str(ascore(i,4));
% %     text(couple_set.rwy{i}{1}(2), couple_set.rwy{i}{1}(1),A,'HorizontalAlignment','center');
%     text(couple_set.rwy{i}{1}(2), couple_set.rwy{i}{1}(1),num2str(i),'VerticalAlignment','top');
%     text(couple_set.rwy{i}{2}(2), couple_set.rwy{i}{2}(1),num2str(i),'VerticalAlignment','top');
% end
% 
%objective space


%% Visualize
%objective space plot
figure('name','objective space');
hold on
plot(tscore(:,4),ascore(:,4),'o') % -> Case on Obejctive space

for i = 1:length(setnum)
    hold on
    plot(tscore(setnum(i),4),ascore(setnum(i),4),'ro-');
end

hold on
plot(score_set(:,1),score_set(:,2));
for i = 1:length(score_set)
    text(score_set(i,1), score_set(i,2), num2str(i),'VerticalAlignment','top');
end    
% xlim([0 inf])
% ylim([0 inf])
% axis tight
title('objective space','fontsize',15)
xlabel('trajectory score','fontsize',14)
ylabel('area score','fontsize',14)
grid on


%map visualization
colorimage=imread('colormap_seoul.png');
boundary=imread('boundary.png');
figure('name','generated runway');
hold on
% imshow(landuse)
% imshow(image)
imshow(colorimage)
% imshow(boundary)

for i=1:length(point)
    hold on
    plot(point{i}(2),point{i}(1),'ro')
end

for i = 1:length(finalset.traj)
    hold on
    plot(finalset.traj{i}{1}(:,2),finalset.traj{i}{1}(:,1),'g')
    plot([finalset.rwy{i}{1}{1}(2),finalset.rwy{i}{1}{2}(2)],[finalset.rwy{i}{1}{1}(1),finalset.rwy{i}{1}{2}(1)],'b')
%     text(finalset.rwy{i}{1}{1}(2), finalset.rwy{i}{1}{1}(1),num2str(i),'VerticalAlignment','top');
    text(finalset.rwy{i}{1}{2}(2), finalset.rwy{i}{1}{2}(1),num2str(i),'VerticalAlignment','top');
end

hold on
quiver(initial(2), initial(1), cos(initial(3))*40, sin(initial(3))*40, 'MaxHeadSize', 3)
[X,Y]=circle(CG(2),CG(1),r);
plot(X,Y)
scatter(initial(2), initial(1), 'x')
scatter(CG(2),CG(1),'filled','d','r')

%% 3D visualize
figure('name','3D');
for i = 1:length(finalset.traj)
    hold on
    plot3(finalset.traj{i}{1}(:,2),finalset.traj{i}{1}(:,1),finalset.traj{i}{1}(:,3)*30,'g')
    plot([finalset.rwy{i}{1}{1}(2),finalset.rwy{i}{1}{2}(2)],[finalset.rwy{i}{1}{1}(1),finalset.rwy{i}{1}{2}(1)],'b')
%     text(finalset.rwy{i}{1}{1}(2), finalset.rwy{i}{1}{1}(1),num2str(i),'VerticalAlignment','top');
    text(finalset.rwy{i}{1}{2}(2), finalset.rwy{i}{1}{2}(1),num2str(i),'VerticalAlignment','top');
end
hold on
surf(flipud(height))
shading interp
axis equal

%display

disp('=== visualization complete ===')
A=[num2str(length(setnum)),' reasonable choices generated'];
disp(A)

disp(' ')
disp('==========================')
disp('==== Process Complete ====')
disp('==========================')
disp(' ')
toc

%% define function
function [xp,yp]=circle(x,y,r)
ang=0:pi/180:2*pi; 
xp=r*cos(ang)+x;
yp=r*sin(ang)+y;
end
