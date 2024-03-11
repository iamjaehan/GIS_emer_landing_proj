close all
clear all

dem=imread('n52_e004_1arc_v3.tif');
dem2=imread('n52_e005_1arc_v3.tif');
demtot=[dem,dem2];
demtot=flipud(demtot);

%% dem localize
xw=ceil((4.62469-4)/2*3601);
xe=floor((5.15135-4)/2*3601);
yn=floor((52.44888-52)*3602);
ys=ceil((52.28328-52)*3602);

demregion=demtot(ys:yn,xw:xe);
height=demregion;

figure(1)
mesh(height)
title('height','fontsize',15)
colorbar

%% dem to slope
slope=zeros(length(demregion(:,1,1)),length(demregion(1,:,1)));

for i=1:length(demregion(:,1,1))
    for j=1:length(demregion(1,:,1))
        slope(i,j)=slopecalc(i,j,demregion);
    end
end

slope=atan(slope./30).*180./pi;

height = height(1:351,1:801);
slope = slope(1:351,1:801);

save('slope.mat','slope')
figure(2)
mesh(slope)
colorbar


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

