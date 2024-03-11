clear all
close all

dem=imread('n40_w075_1arc_v3.tif');
dem2=imread('n40_w074_1arc_v3.tif');
demtot=[dem,dem2];
demtot=flipud(demtot);

%% dem localize
xw=ceil((-74.15438+75)/2*7202);
xe=floor((-73.62841+75)/2*7202);
yn=floor((40.93610-40)*3601);
ys=ceil((40.74910-40)*3601);

demregion=demtot(ys:yn,xw:xe);
height=demregion;

% figure(1)
% mesh(height)
% title('height','fontsize',15)
% colorbar

%% dem to slope
slope=zeros(length(demregion(:,1,1)),length(demregion(1,:,1)));

for i=1:length(demregion(:,1,1))
    for j=1:length(demregion(1,:,1))
        slope(i,j)=slopecalc(i,j,demregion);
    end
end

slope=atan(slope./30).*180./pi;
% 
% figure(2)
% mesh(slope)
% title('slope map','fontsize',15)
% colorbar

%706 1889

slope_real=zeros(905, 1917);
height_real=zeros(905, 1917);
for i = 1:length(slope_real(:,1))
    for j = 1:length(slope_real(1,:))
        slope_real(i,j)=slope(round(673/905*i),round(1894/1917*j));
        height_real(i,j)=height(round(673/905*i),round(1894/1917*j));
    end
end

slope=slope_real;
height=height_real;
clear slope_real height_real

%% define function
function r=slopecalc(b,c,m)
a=0;
if b==1 && c==1
    r=max([abs(m(2,1)-m(1,1)),abs(m(1,2)-m(1,1))]);
    a=1;
elseif b==length(m(:,1,1)) && c==1
    r=max([abs(m(b-1,c)-m(b,c)),abs(m(b,c+1)-m(b,c))]);
    a=1;
elseif b==length(m(:,1,1)) && c==length(m(1,:,1))
    r=max([abs(m(b-1,c)-m(b,c)),abs(m(b,c-1)-m(b,c))]);
    a=1;
elseif b==1 && c==length(m(1,:,1))
    r=max([(abs(m(b+1,c)-m(b,c))),abs(m(b,c-1)-m(b,c))]);
    a=1;
end
if a==0
    if b==1
        r=max([abs(m(b+1,c)-m(b,c)),abs(m(b,c-1)-m(b,c)), abs(m(b,c+1)-m(b,c))]);
        a=2;
    elseif b==length(m(:,1,1))
        r=max([abs(m(b-1,c)-m(b,c)),abs(m(b,c-1)-m(b,c)), abs(m(b,c+1)-m(b,c))]);
        a=2;
    elseif c==1
        r=max([abs(m(b+1,c)-m(b,c)),abs(m(b-1,c)-m(b,c)), abs(m(b,c+1)-m(b,c))]);
        a=2;
    elseif c==length(m(1,:,1))
        r=max([abs(m(b+1,c)-m(b,c)),abs(m(b-1,c)-m(b,c)), abs(m(b,c-1)-m(b,c))]);
        a=2;
    end
end
if a==0
    r=max([abs(m(b+1,c)-m(b,c)),abs(m(b-1,c)-m(b,c)),abs(m(b,c-1)-m(b,c)),abs(m(b,c+1)-m(b,c))]);
end
end

