%% main
clear all
close all
clc;

addpath('./mapping');
addpath('./trajectory');
% landuse=load('landuse_manhattan.mat');
% image=imread('manhattan_landuse.png');
% image=imread('manhattan_overall.png');
% dem=load('dem_manhattan.mat');
image=imread('seoul_landuse.png');
landuse=load('landuse_seoul.mat');
dem=load('dem_seoul.mat');

slope=dem.slope;
town=landuse.landuse{1};

%% area score
% distance scoring
area=0;
for i = 1:length(town(:,1))
    for j = 1:length(town(1,:))
        if town(i,j)==1
            area=area+1;
        end
    end
end
r=sqrt(area/pi); %mean radius
[X,Y]=COG(town);
CG=[X,Y];
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        distance=dist(CG,[i,j]);
        dist_score(i,j)=d_sc(distance,r);
    end
end

%slope scoring
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        sl_score(i,j)=s_sc(slope(i,j));
    end
end

%% plotting

figure(1)
imshow(image)
hold on
scatter(CG(2),CG(1),'filled','d','r')
contour(dist_score)
hold on
surf(dist_score,'FaceAlpha',0.5)
shading interp
colorbar
[X,Y]=circle(CG(2),CG(1),r);
plot(X,Y,'r.')

figure(2)
A=zeros(905,1917,3);
A=uint8(A);
% imshow(A)
hold on
surf(sl_score,'FaceAlpha',1)
shading interp
hold on
contour(flipud(sl_score))
colorbar




%% define function
function r=dist(A,B)
r=sqrt((A(1)-B(1))^2+(A(2)-B(2))^2);
end

function score=d_sc(d,r)
if d>r
    score=-1/(1+exp((d-r)/3/33))+0.5;
else
    score=0;
end
end

function score=s_sc(d)
    score=exp(log(2)/30*d)-1;
end

function score=l_sc(d)
    score=1/(1+exp(d-2));
end

function [xp,yp]=circle(x,y,r)
ang=0:pi/180:2*pi; 
xp=r*cos(ang)+x;
yp=r*sin(ang)+y;
end

function [boundary] = bound(map)
boundary=zeros(length(map(:,1,1))-2,length(map(1,:,1))-2);
boundary=boundary+1;
for i=2:length(map(:,1,1))-1
    for j=2:length(map(1,:,1))-1
        if map(i,j,1)==1
            if map(i,j,1)==map(i+1,j,1) && map(i,j,1)==map(i-1,j,1) && map(i,j,1)==map(i,j+1,1) && map(i,j,1)==map(i,j-1,1)
                boundary(i,j)=0;
            end
        else
            boundary(i,j)=0;
        end
    end
end

end