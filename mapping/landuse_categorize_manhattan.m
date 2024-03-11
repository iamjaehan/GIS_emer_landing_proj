clear all
close all
global ld
%% dataread
tic
ld=imread('manhattan_landuse.png');

%% landuse categorization
for i=1:length(ld(:,1,1))
    for j=1:length(ld(1,:,1))
        if iscolor(i,j,1)==1
            landuse(i,j)=1;
        elseif iscolor(i,j,2)==1
            landuse(i,j)=2;
        elseif iscolor(i,j,3)==1
            landuse(i,j)=3;
        elseif iscolor(i,j,4)==1
            landuse(i,j)=4;            
        else
            landuse(i,j)=0;
        end
    end
end

%% landtype file division
residential = zeros(length(landuse(:,1)), length(landuse(1,:)));
water = zeros(length(landuse(:,1)), length(landuse(1,:)));
forest = zeros(length(landuse(:,1)), length(landuse(1,:)));
open = zeros(length(landuse(:,1)), length(landuse(1,:)));

for i = 1:length(landuse(:,1))
    for j = 1:length(landuse(1,:))
        if landuse(i,j)==1
            residential(i,j)=1;
        elseif landuse(i,j)==2
            water(i,j)=1;
        elseif landuse(i,j)==3
            forest(i,j)=1;
        elseif landuse(i,j)==4
            open(i,j)=1;
        end
    end
end
landuse={residential,water,forest,open};

%% function define
function result=iscolor(i,j,n)
global ld
t=10;
if n==1
    if 147-t<=ld(i,j,1)&&ld(i,j,1)<=147+t && 47-t<=ld(i,j,2)&&ld(i,j,2)<=47+t && 20-t<=ld(i,j,3)&&ld(i,j,3)<=20+t
        result = 1;
    else
        result = 0;
    end
elseif n==2
    if 0<=ld(i,j,1)&&ld(i,j,1)<=t && 86-t<=ld(i,j,2)&&ld(i,j,2)<=86+t && 154-t<=ld(i,j,3)&&ld(i,j,3)<=154+t
        result = 1;
    else
        result = 0;
    end
elseif n==3
    if 20-t<=ld(i,j,1)&&ld(i,j,1)<=20+t && 119-t<=ld(i,j,2)&&ld(i,j,2)<=119+t && 73-t<=ld(i,j,3)&&ld(i,j,3)<=73+t
        result = 1;
    elseif 169-t<=ld(i,j,1)&&ld(i,j,1)<=169+t && 208-t<=ld(i,j,2)&&ld(i,j,2)<=208+t && 95-t<=ld(i,j,3)&&ld(i,j,3)<=95+t
        result = 1;
    else
        result = 0;
    end
elseif n==4
    if 249-t<=ld(i,j,1)&&ld(i,j,1)<=249+t && 243-t<=ld(i,j,2)&&ld(i,j,2)<=243+t && 193-t<=ld(i,j,3)&&ld(i,j,3)<=193+t
        result = 1;
    else
        result = 0;
    end
end
end

