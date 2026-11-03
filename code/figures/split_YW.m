function array = split_YW(start,ending,total_num)
interval = (ending-start)/(total_num-1);
array = start:interval:ending;
end