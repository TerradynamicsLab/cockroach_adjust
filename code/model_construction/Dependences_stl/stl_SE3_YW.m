%% stl_struct SE(3) transfermation
%% Xi(?) = [yaw pitch roll, (x y z)] 
function new_stl_struct = stl_SE3_YW(old_stl_struct,Xi)
if length(Xi) == 3
    R = eul2rotm(Xi);
    new_positions = R*old_stl_struct.vertice_position';
elseif length(Xi) == 6
    G = [eul2rotm(Xi(1:3)),Xi(4:6)';0,0,0,1];
    old_positions = [old_stl_struct.vertice_position';ones(1,old_stl_struct.num_vertice)];
    new_positions = G*old_positions;
else
    error('? should be 1*3 in the SO(3) or 1*6 in the SE(3).');
end
new_stl_struct.faces = old_stl_struct.faces;
new_stl_struct.num_vertice = old_stl_struct.num_vertice;
new_stl_struct.vertice_serial = old_stl_struct.vertice_serial;
new_stl_struct.vertice_position = new_positions(1:3,:)';
end