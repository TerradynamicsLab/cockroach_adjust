% check_point: 0:out, 1:good edge, 2:nomal
function result = check_point_BFS(landscape_size,x,y)
if x == 1 || x == landscape_size(2)
    result = 1;
    return;
end
if x>=1 && x<=landscape_size(2) && y>=1 && y<=landscape_size(1)
    result = 2;
    return;
else
    result = 0;
end

end