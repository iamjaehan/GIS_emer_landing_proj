function [rwy,k] = rwy_gen(point,m,dem)

%imshow하면 뒤집어서 나타남. 0,0좌표상 똑바로 보이게 수정한 것임.

rwy_cand=[];
a=1;
res=[];
min_length=66; %2km
for i = 1:length(point) %first filering with length/determine intermediate point number
    for j=1:length(point)
        if dist(point{i},point{j}) > 66
            rwy_cand{a}={point{i},point{j}};
            res(a)=round((dist(point{i},point{j}))/10)+2;
            a=a+1;
        end
    end
end


%intermediate point generation
inter=[];
for i = 1:length(rwy_cand)
    X=linspace(rwy_cand{i}{1}(1),rwy_cand{i}{2}(1),res(i));
    Y=linspace(rwy_cand{i}{1}(2),rwy_cand{i}{2}(2),res(i));
    for j = 1:res(i)
        X(j)=round(X(j));
        Y(j)=round(Y(j));
    end
    inter{i}=[X',Y'];
end

reject=[];
a=1;
k=0;
%intermediate within feasible region?
for i = 1:length(rwy_cand)
    for j = 2:res(i)-1
        if m(inter{i}(j,1),inter{i}(j,2),1)==0
            k=1;
        end
    end
    if k==1
        reject(a)=i;
        a=a+1;
    end
    k=0;
end

search=zeros(length(rwy_cand),1);
search=search+1;
for i = 1:length(reject)
    search(reject(i))=0;
end

rwy=[];
a=1;
for i = 1:length(search)
    if search(i)==1
        rwy{a}=rwy_cand{i};
        a=a+1;
    end
end

for i = 1:length(rwy)
    rwy{i}=[rwy{i},double(dem(rwy{i}{1}(1),rwy{i}{1}(2)))/1000*33,dist(rwy{i}{1},rwy{i}{2})]; 
    %adding starting/end point's alt.    
end

for i = 1:length(rwy)
    if rwy{i}{2}(1)>=rwy{i}{1}(1)
        direction=atan((rwy{i}{2}(2)-rwy{i}{1}(2))/(rwy{i}{2}(1)-rwy{i}{1}(1)));
        rwy{i}=[rwy{i},direction];
    else
        direction=atan((rwy{i}{2}(2)-rwy{i}{1}(2))/(rwy{i}{2}(1)-rwy{i}{1}(1)));
        rwy{i}=[rwy{i},direction+pi];
    end
end

k=length(rwy);
%% plotting
% figure('name','generated runway');
% imshow(m)
% hold on
% for i=1:length(point)
%     hold on
%     plot(point{i}(2),point{i}(1),'ro')
% end
% for i = 1:length(rwy)
%     hold on
%     plot([rwy{i}{1}(2),rwy{i}{2}(2)],[rwy{i}{1}(1),rwy{i}{2}(1)],'b')
% end


end
%% define function
function r=dist(A,B)
r=sqrt((A(1)-B(1))^2+(A(2)-B(2))^2);
end