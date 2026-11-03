% Yaqing created this to find an index in the array that array[i]<=x,
% array[i+1]>=x;
function index = find_index_in_array(x,array)
for i = 1:length(array)
    if array(i)>x
        break;
    end
end
index = i-1+(x-array(i-1))/(array(i)-array(i-1));
end