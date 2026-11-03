% like making preparation for ploting a histogram
% errorbar(x_array,y_array,e_array,'LineWidth',2,'Color','r');
function [x_array,mean_array,std_array] = histo_YW(x,y,tree_array)
% Check
interval_num = length(tree_array)-1;
if interval_num<1
    error('Histo_YW must have at least one interval!')
end
element_num = length(x);
if element_num ~= length(y)
    error('X and Y must be the same length!')
end

% Holder
list_array = zeros(element_num,interval_num);
num_array = zeros(1,interval_num);
mean_array = nan(1,interval_num);
std_array = nan(1,interval_num);

% loop element
for i = 1:element_num
    % find an interval for it
    for j = 1:interval_num
        if tree_array(j)<x(i) && tree_array(j+1)>x(i)
            num_array(j) = num_array(j)+1;
            list_array(num_array(j),j) = y(i);
            break;
        end
    end
end

% loop interval
for j = 1:interval_num
    if num_array(j) == 0
        continue;
    end
    mean_array(j) = mean(list_array(1:num_array(j),j));
    std_array(j) = std(list_array(1:num_array(j),j));
end

x_array = (tree_array(1:end-1)+tree_array(2:end))./2;
end