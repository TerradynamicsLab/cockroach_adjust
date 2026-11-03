% Yaqing created this on 09/16/2019 to visualize the reconstruction result.
% The stucture of input_stuct is as follows:
% input
%     body
%         dia 1*3
%         com 1*3
%         eul 1*3
%     head
%         dia 1*3
%         com 1*3
%         eul 1*3
%     beam
%         angle_left 1*1
%         angle_right 1*1

function reconstruction_visualization(input)
% paper and background
f = figure(1);
clf;
set(gca,'fontsize',40);axis equal;
light('Position',[500 0 100]);light('Position',[-500 0 100]);light('Position',[0 0 200]);
xlabel('X');ylabel('Y'); 
view(-35,26);
xlim([-130 130]);ylim([-30 30]*1.5); zlim([0 80]);
ground = patch([-1 -1 1 1]*120,[-1 1 1 -1]*40,[0 0 0 0],'black');
set(ground,'facealpha' ,0.3);lighting gouraud;
hold on
% body
[body_pts_x , body_pts_y , body_pts_z ]  = ellipsoid(0, 0, 0,  input.body.dia(1),  input.body.dia(2),  input.body.dia(3) );
body_pts_raw_x_reshaped = reshape(body_pts_x, [1,prod(size(body_pts_x))]);
body_pts_raw_y_reshaped = reshape(body_pts_y, [1,prod(size(body_pts_y))]);
body_pts_raw_z_reshaped = reshape(body_pts_z, [1,prod(size(body_pts_z))]);
body_t = [eul2rotm(input.body.eul),input.body.com';0,0,0,1];
body_pts_now = body_t*[body_pts_raw_x_reshaped;body_pts_raw_y_reshaped;body_pts_raw_z_reshaped;ones(1,length(body_pts_raw_x_reshaped))];
body_XData = reshape(body_pts_now(1,:),size(body_pts_x));
body_YData = reshape(body_pts_now(2,:),size(body_pts_x));
body_ZData = reshape(body_pts_now(3,:),size(body_pts_x));
body_surf = surf(body_XData , body_YData , body_ZData,'edgealpha',0, 'facecolor',[0.75 0 0], 'facealpha', 1,'FaceLighting','gouraud');
% head
[head_pts_x , head_pts_y , head_pts_z ]  = ellipsoid(0, 0, 0,  input.head.dia(1),  input.head.dia(2),  input.head.dia(3) );
head_pts_raw_x_reshaped = reshape(head_pts_x, [1,prod(size(head_pts_x))]);
head_pts_raw_y_reshaped = reshape(head_pts_y, [1,prod(size(head_pts_y))]);
head_pts_raw_z_reshaped = reshape(head_pts_z, [1,prod(size(head_pts_z))]);
head_t = [eul2rotm(input.head.eul),input.head.com';0,0,0,1];
head_pts_now = head_t*[head_pts_raw_x_reshaped;head_pts_raw_y_reshaped;head_pts_raw_z_reshaped;ones(1,length(head_pts_raw_x_reshaped))];
head_XData = reshape(head_pts_now(1,:),size(head_pts_x));
head_YData = reshape(head_pts_now(2,:),size(head_pts_x));
head_ZData = reshape(head_pts_now(3,:),size(head_pts_x));
head_surf = surf(head_XData , head_YData , head_ZData,'edgealpha',0, 'facecolor',[1 0.75 0], 'facealpha', 1,'FaceLighting','gouraud');
% beams
beam_width = 10;
beam_height = 80;
beam_gap = 10;
beam_left_corners_x = [0 beam_height*sin(input.beam.angle_left) beam_height*sin(input.beam.angle_left) 0]';
beam_left_corners_y = [-1 -1 1 1]'*beam_width/2+(beam_gap + beam_width)/2;
beam_left_corners_z = [0 beam_height*cos(input.beam.angle_left) beam_height*cos(input.beam.angle_left) 0]';
beam_left = patch('XData',beam_left_corners_x,'YData',beam_left_corners_y,'ZData',beam_left_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);
beam_right_corners_x = [0 beam_height*sin(input.beam.angle_right) beam_height*sin(input.beam.angle_right) 0]';
beam_right_corners_y = [-1 -1 1 1]'*beam_width/2-(beam_gap + beam_width)/2;
beam_right_corners_z = [0 beam_height*cos(input.beam.angle_right) beam_height*cos(input.beam.angle_right) 0]';
beam_right = patch('XData',beam_right_corners_x,'YData',beam_right_corners_y,'ZData',beam_right_corners_z,'facecolor','g','facealpha',0.3,'facelighting','gouraud','linewidth',2);
end