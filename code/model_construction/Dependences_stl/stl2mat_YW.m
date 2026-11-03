% Yaqing created this to play with the stl
% input:
% old_stl_struct = stlread_EJ(stl_file);
% output:
% stl_struct                1*1 struct()
%     faces                 num_face*3 just like what an stl have
%     num_vertice           1*1 int
%     vertice_serial        raw_num_vertice*1
%     vertice_position      num_vertice*3
function new_stl_struct = stl2mat_YW(old_stl_struct)
% preserve the .faces
new_stl_struct.faces = old_stl_struct.faces;

% sort the points and extract each
points  = old_stl_struct.vertices;
size_points = size(points);
length_points = size_points(1);
%%% sort
for i = 1:length_points
    for j = i+1:length_points
        % if P_i>P_j
        if compare_points(points(i,:),points(j,:)) == 1 
            % swap P_i and P_j
            temp_point = points(i,:);
            points(i,:) = points(j,:);
            points(j,:) = temp_point;
        end
    end
end
%%% extract & record
extracted_points = nan(length_points,3);
extracted_points(1,:) =  points(1,:);
j = 1;
for i = 2:length_points
    if compare_points(points(i-1,:),points(i,:))~=0
        j = j+1;
        extracted_points(j,:) =  points(i,:);
    end
end
extracted_points = extracted_points(1:j,:); 
new_stl_struct.vertice_position = extracted_points;
new_stl_struct.num_vertice = j;

% match vertice_serial
new_stl_struct.vertice_serial = nan(length_points,1);
for i = 1:length_points
    old_point = old_stl_struct.vertices(i,:);
    for j = 1:new_stl_struct.num_vertice
        
        if compare_points(old_point,extracted_points(j,:)) == 0
            new_stl_struct.vertice_serial(i) = j;
        end
    end
end

% return or save 
end