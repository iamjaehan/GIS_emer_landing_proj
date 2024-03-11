function [point_final,point_matrix]=boundary_pointgen(water,n)
%% sample point gen.
close all

water_bound = bound(water);

x_sample = linspace(1,length(water(1,:,1)),length(water(1,:,1))/length(water(:,1,1))*n);
y_sample = linspace(1,length(water(:,1,1)),n);

for j = 1 : length(x_sample)
    x_sample(j)=round(x_sample(j));
end
for j = 1: length(y_sample)
    y_sample(j)=round(y_sample(j));
end
x_sample(1)=[];
y_sample(1)=[];
x_sample(length(x_sample))=[];
y_sample(length(y_sample))=[];

% sampling start
point_x=[];
point_y=[];

for i = 1 : length(x_sample)
    point_x{i} = point_on(x_sample(i),x_sample(i),1,water_bound);
end

for i = 1 : length(y_sample)
    point_y{i} = point_on(y_sample(i),x_sample(i),0,water_bound);
end

point_edge_temp = edge(water,x_sample,y_sample);
point_edge=[];
for i = 1:length(point_edge_temp)
    point_edge{i}=point_edge_temp(i);
end

point_final = [point_x,point_y,point_edge];


%% sequencing (순서가 개판이라...)
point_matrix=zeros(length(water(:,1,1)),length(water(1,:,1)));
for i = 1:length(point_final)
    for j = 1:length(point_final{i})
        point_matrix(point_final{i}{j}(1),point_final{i}{j}(2))=1;
    end
end

% point_matrix=flipud(point_matrix);
point_final=[];
a=1;
for i = 1:length(point_matrix(:,1))
    for j = 1:length(point_matrix(1,:))
        if point_matrix(i,j)==1
            point_final{a}=[i,j];
            a=a+1;
        end
    end
end

%% plotting
% 
% figure('name','boundary');
% imshow(water_bound);
% hold on
% for i = 1 : length(point_final)
%     hold on
%     plot(point_final{i}(2),point_final{i}(1),'ro')
% end


end
%% function generator
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

function [point] = point_on(num,ref,mode,m)
point=[];
if mode==1 %x axis
    for i = 2:length(m(:,1,1))-1
        if m(i,num)==1
            point=horzcat(point,{[i,num]});
        end
    end
elseif mode==0 % y axis
    for i = 2:length(m(1,:,1))-1
        if m(num,i)==1 && ~ismember(i,ref)
            point=horzcat(point,{[num,i]});
        end
    end
end
end

function [point] = edge(m,refx,refy)
point=[];
for i = 1:length(refy)
    if m(refy(i),2)==1
        point=horzcat(point,{[refy(i),2]});
    elseif m(refy(i),length(m(1,:,1))-1)==1
        point=horzcat(point,{[refy(i),length(m(1,:,1))-1]});
    end
end
for i = 2:length(refx)-1
    if m(2,refx(i))==1
        point=horzcat(point,{[2,refx(i)]});
    elseif m(length(m(:,1,1))-1,refx(i))==1
        point=horzcat(point,{[length(m(:,1,1))-1,refx(i),]});
    end
end
end