clear all
close all
global ld
%% dataread
% landuse_raw=imread('Amsterdam.png');
ld=imread('amsterdam_simplified.png');


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
t=100;
if n==1
    if 255-t<=ld(i,j,1)&&ld(i,j,1)<=255+t && 0<=ld(i,j,2)&&ld(i,j,2)<=t && 0<=ld(i,j,3)&&ld(i,j,3)<=t
        result = 1;
    else
        result = 0;
    end
elseif n==2
    if 0<=ld(i,j,1)&&ld(i,j,1)<=t && 112-t<=ld(i,j,2)&&ld(i,j,2)<=112+t && 192-t<=ld(i,j,3)&&ld(i,j,3)<=192+t
        result = 1;
    else
        result = 0;
    end
elseif n==3
    if 176-t<=ld(i,j,1)&&ld(i,j,1)<=176+t && 80-t<=ld(i,j,2)&&ld(i,j,2)<=80+t && 0<=ld(i,j,3)&&ld(i,j,3)<=t
        result = 1;
    else
        result = 0;
    end
elseif n==4
    if 255-t<=ld(i,j,1)&&ld(i,j,1)<=255+t && 255-t<=ld(i,j,2)&&ld(i,j,2)<=255+t && 0<=ld(i,j,3)&&ld(i,j,3)<=t
        result = 1;
    else
        result = 0;
    end
end
end

