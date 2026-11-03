% Yaqing created this to play with the stl
% input:
% old_stl_struct            1*1 struct()
%     faces                 num_face*3 just like what an stl have
%     num_vertice           1*1 int
%     vertice_serial        raw_num_vertice*1
%     vertice_position      num_vertice*3
% output:
% new_stl_struct = stlread_EJ(stl_file);
%     faces                 num_face*3 just like what an stl have
%     vertices              raw_num_vertice*3

function new_stl_struct = mat2stl_patchable_YW(old_stl_struct)
% preserve the .faces
new_stl_struct.faces = old_stl_struct.faces;

% get out vertices
new_stl_struct.vertices = nan(length(old_stl_struct.vertice_serial),3);
for i = 1:length(old_stl_struct.vertice_serial)
    new_stl_struct.vertices(i,:) = old_stl_struct.vertice_position(old_stl_struct.vertice_serial(i),:);
end

end