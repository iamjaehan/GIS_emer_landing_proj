function image=pixeladj(x,y,m)
image=[];
X=length(m(:,1,1));
Y=length(m(1,:,1));
for i = 1:x
    for j = 1:y
        image(i,j,:)=m(round(X/x*i),round(Y/y*j),:);
    end
end
image=uint8(image);
end