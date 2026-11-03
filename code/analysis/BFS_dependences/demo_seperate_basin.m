


x = -10:10;
y = -10:10;
[X,Y] = meshgrid(x,y);
for i = 1:length(x)
    for j = 1:length(y)
        x_ = X(j,i);
        y_ = Y(j,i);
        z_ = +sqrt((x_-7)^2+(y_-7)^2) +sqrt((x_+7)^2+(y_+7)^2)-0.5*sqrt(x_^2+y_^2);
        Z(j,i) = z_;
    end
end

figure(1);
colormap(fire);
surf(X,Y,Z,'EdgeAlpha',0);
xlabel('x');
ylabel('y');
zlabel('z');
view([-70,40])

landscape = Z;
[basin_l,basin_s] = seperate_basin(landscape,0,0);
for i = 1:length(x)
    for j = 1:length(y)
        if basin_l(j,i) == 1
            c(j,i,1:3) = [1,0.5,0.5];
        elseif basin_l(j,i) == 2
            c(j,i,1:3) = [0.5,0.5,1];
        else
            c(j,i,1:3) = [0,0,0];
        end
    end
end


figure(2);
surf(X,Y,Z,c,'EdgeAlpha',0);
xlabel('x');
ylabel('y');
zlabel('z');
view([-70,40])