
clear; close all; clc;

x = 0:20;%-10:10;
y = 0:20;%-10:10;
[X,Y] = meshgrid(x,y);
for i = 1:length(x)
    for j = 1:length(y)
        x_ = X(j,i);
        y_ = Y(j,i);
%         z_ = +sqrt((x_-7)^2+(y_-7)^2) +sqrt((x_+7)^2+(y_+7)^2)-0.5*sqrt(x_^2+y_^2);
        z_ = +sqrt((x_-17)^2+(y_-17)^2) +sqrt((x_-3)^2+(y_-3)^2)-0.5*sqrt((x_-10)^2+(y_-10)^2);
        
        Z(j,i) = z_;
    end
end

figure(1);
set(gcf, 'Position',[480 169 600 500]);
colormap(fire);
% surf(X,Y,Z,'EdgeAlpha',0);
surf(X, Y, Z,'EdgeAlpha',0);
xlabel('x');
ylabel('y');
zlabel('z');
view([-62,52])
set(gca,'FontSize', 20);
hold on;

landscape = Z;
[saddleXYZ,routeXYZ,basin_landscape] = mini2mini(landscape,4,4,18,18,0,0);
for i = 1:length(x)
    for j = 1:length(y)
        if basin_landscape(j,i) == 2
            c(j,i,1:3) = [1,0.5,0.5];
        elseif basin_landscape(j,i) == 1
            c(j,i,1:3) = [0.5,0.5,1];
        else
            c(j,i,1:3) = [0,0,0];
        end
    end
end


figure(2);
set(gcf, 'Position',[480 169 600 500]);
hold on;
surf(Z,c,'EdgeAlpha',0,'FaceAlpha',0.5);
xlabel('x');
ylabel('y');
zlabel('z');
view([-62,52])
set(gca,'FontSize', 20);

plot3(routeXYZ(1,:)+0.5,routeXYZ(2,:)+0.5,routeXYZ(3,:)+0.5,'LineStyle','-','LineWidth',3,'Color','g');
plot3(routeXYZ(1,1)+0.5,routeXYZ(2,1)+0.5,routeXYZ(3,1)+0.5,'o','MarkerFaceColor','b','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
plot3(routeXYZ(1,end)+0.5,routeXYZ(2,end)+0.5,routeXYZ(3,end)+0.5,'o','MarkerFaceColor','r','MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
plot3(saddleXYZ(1)+0.5,saddleXYZ(2)+0.5,saddleXYZ(3)+0.5,'o','MarkerFaceColor',[0.9294,0.6902,0.1294],'MarkerSize',12,'LineWidth',2,'MarkerEdgeColor','g');
          
plot3([saddleXYZ(1),saddleXYZ(1)]+0.5,[saddleXYZ(2),saddleXYZ(2)]+0.5,[saddleXYZ(3),routeXYZ(3,1)],'LineStyle',':','LineWidth',3,'Color','k');
plot3([saddleXYZ(1),routeXYZ(1,1)]+0.5,[saddleXYZ(2),routeXYZ(2,1)]+0.5,[routeXYZ(3,1),routeXYZ(3,1)],'LineStyle',':','LineWidth',3,'Color','k');

figure(3)
plot(routeXYZ(3,:),'LineWidth',5,'Color','k');
set(gcf, 'Position',[680 558 200 420]);
set(gca,'FontSize', 20);
xlim([-2,32])