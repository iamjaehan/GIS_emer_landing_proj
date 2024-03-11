function [ascore, tscore,r,CG] = scoring(set,slope,town)
%ascore = [distance, slope, length]
%tscore = [total length, turn]
% set=couple_set;
rwy=set.rwy;
traj=set.traj;

%dimension match work (pixel -> km-s)
for i = 1:length(rwy)
    rwy{i}{3}=rwy{i}{3}/33; % height in km
    rwy{i}{4}=rwy{i}{4}/33; % distance in km
end

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
for i = 1:length(rwy)
    distance=dist(CG,(rwy{i}{1}+rwy{i}{2})/2);
    score(i,1)=d_sc(distance,r);
end

%slope scoring
for i = 1:length(rwy)
    sum=0;
    inter=[];
    res=0;
    res=round(rwy{i}{4}/0.2); %check every 200m
    inter=linspace(rwy{i}{1}(1),rwy{i}{2}(1),res);
    inter=[inter;linspace(rwy{i}{1}(2),rwy{i}{2}(2),res)];
    for j = 1:length(inter)
        inter(:,j)=round(inter(:,j));
        sum=sum+s_sc(slope(inter(1,j),inter(2,j)));
    end
    score(i,2)=sum/j;
end

%length scoring
for i = 1:length(rwy)
    score(i,3)=l_sc(rwy{i}{4});
end
ascore=score;

%% trajectory scoring

for i = 1:length(traj)
    t1=1; t2=1; t3=1;
    ratio=t_sc_ratio(traj{i,3}/traj{i,2}); % straight the better
    tot_len=t_sc_len(traj{i,2}); % small weight! penalty shape equal to ratio - shorter the better
    gam=t_sc_gam(traj{i,4}); % gamma. glide complexity - longer the better
    tscore(i,1)=ratio;
    tscore(i,2)=tot_len;
    tscore(i,3)=gam;
    tscore(i,4)=t1*ratio+t2*tot_len+ t3*gam;
    %ratio, total length, gamma, r
end

end

%% define function
function r=dist(A,B)
r=sqrt((A(1)-B(1))^2+(A(2)-B(2))^2);
end

function score=d_sc(d,r)
if d>r
    score=-1/(1+exp((d-r)/3))+0.5;
else
    score=0;
end
end

function score=s_sc(d)
if d<=30
    score=exp(log(2)/30*d)-1;
else
    score=100;
end
end

function score=l_sc(d)
    score=1/(1+exp(d-2));
end

function score=t_sc_ratio(d)
score=2*(-1/(1+exp(d*6))+0.5);
end

function score=t_sc_len(d)
score=2*(-1/(1+exp(d/10*6))+0.5);
end

function score=t_sc_gam(d)
score=2*(-1/(1+exp((d-3)*6/7))+0.5);
end

