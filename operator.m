function [finalset,score_set,n]=operator(landuse,town,dem,initial,altitude,vel,delay,n)

% parameter
sample_quality=n;

%% loading preprocessed data / settings
slope=dem.slope;
height=dem.height;

%% rwy generation
[point]=boundary_pointgen(landuse,sample_quality);
[rwy,k]=rwy_gen(point,landuse,height);

% pixel dimension output


%% trajectory generation
altitude = altitude*33; %in pixel
[couple_set,k2]=traj_gen(rwy,initial,altitude,1,vel,delay); %rwy info. + traj info.

%km-s dimension


%% Evaluation
[ascore,tscore,r,CG]=scoring(couple_set,slope,town);
ascore(:,4)=sum(ascore,2);


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

%% Visualize
%display

A=[num2str(length(setnum)),' reasonable choices generated'];
disp(A)
n=length(setnum);

end
