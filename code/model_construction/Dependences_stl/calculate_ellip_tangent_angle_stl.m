% Here we loop all the points to find out the stuff
% input:
% model_mat                1*1 struct()
%     vertice_position      num_vertice*3
% output:
% possible_angles_left 1*202
% possible_angles_right 1*202

function [possible_angles_left,possible_angles_right] = calculate_ellip_tangent_angle_stl(model_mat)
beam_width = 10;
beam_gap = 10;
beam_height = 93;

%% left beam
y_range = [0,beam_width]+beam_gap/2;
points = model_mat.vertice_position;
points_i_selected = (points(:,2) >= y_range(1)) .* (points(:,2) <= y_range(2))==1;
if isempty(points_i_selected)
    possible_angles_left = [nan,nan];
else
    points_x_selected = points(points_i_selected,1);
    points_z_selected = points(points_i_selected,3);
    
    points_xz2_selected = (points_x_selected.*points_x_selected + points_z_selected.*points_z_selected);
    points_i_selected = points_xz2_selected<=beam_height^2;
    points_x_selected = points_x_selected(points_i_selected);
    points_z_selected = points_z_selected(points_i_selected);
    
    angles = atan2(points_x_selected,points_z_selected);
    possible_angles_left = [nanmax(angles),nanmin(angles)];
    % check for nothing
    if isempty(possible_angles_left)
        possible_angles_left = [nan,nan];
    end
end



%% right beam
y_range = [-beam_width,0]-beam_gap/2;
points = model_mat.vertice_position;
points_i_selected = (points(:,2) >= y_range(1)) .* (points(:,2) <= y_range(2))==1;
if isempty(points_i_selected)
    possible_angles_right = [nan,nan];
else
    points_x_selected = points(points_i_selected,1);
    points_z_selected = points(points_i_selected,3);
    
    points_xz2_selected = (points_x_selected.*points_x_selected + points_z_selected.*points_z_selected);
    points_i_selected = points_xz2_selected <= beam_height^2;
    points_x_selected = points_x_selected(points_i_selected);
    points_z_selected = points_z_selected(points_i_selected);
    
    angles = atan2(points_x_selected,points_z_selected);
    possible_angles_right = [nanmax(angles),nanmin(angles)];
    % check for nothing
    if isempty(possible_angles_right)
        possible_angles_right = [nan,nan];
    end
end

end