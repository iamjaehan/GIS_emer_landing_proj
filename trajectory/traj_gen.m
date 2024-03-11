function [set,k]=traj_gen(rwy,p1,hi,mode,vel,delay)
% initial=[502,1093,pi/4];
% altitude=10;
% hi=altitude;
% p1=initial;
vel=vel/3.6; %to m/s
vel=vel*33/1000;
if mode==1
    p1(1)=p1(1)+cos(p1(3))*vel*delay;
    p1(2)=p1(2)+sin(p1(3))*vel*delay;
    hi=hi-vel*delay*tan(3*pi/180);
end

stepsize=0.1;
set=[];
a=1;
for i = 1:length(rwy)
    r=33;
    while r<331
        [path, gamma, length_All, length_LR_SEG] = ...
            dubins_curve_v2(p1,[rwy{i}{1}(1),rwy{i}{1}(2),rwy{i}{5}], r, stepsize, hi, rwy{i}{3});
        if gamma<3
            break;
        end
        if gamma<=10
            set.rwy{a,1}=rwy{i};
            set.traj{a,1}=path;
            set.traj{a,2}=length_All/33;
            set.traj{a,3}=length_LR_SEG/33;
            set.traj{a,4}=gamma;
            set.traj{a,5}=r/33;
            set.traj{a,6}=length_All/vel;
            a=a+1;
            break;
        end
        r=r+33;
    end
      
end
k=length(set.traj(:,1));

end