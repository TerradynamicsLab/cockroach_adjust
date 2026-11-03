function array_output = central_finite_difference(array_input,varargin)

%% Basics
% Check input
size_input = size(array_input);
if length(size_input)~=2
    error('Only 1-D array!');
elseif sum(size_input==1)==0
    error('Only 1-D array!');
end
% Accuracy
if isempty(varargin)
    accuracy = 2;
else
    accuracy = varargin{1};
    if sum(accuracy*ones(1,4)==[2,4,6,8])~=1
        error('Accuracy should only be 2/4/6/8!');
    end
end
% coifficient
coifficient = [...
    0 0 0 0 -1/2 0 1/2 0 0 0 0;...
    0 0 0 1/12 -2/3 0 2/3 -1/12 0 0 0;...
    0 0 -1/60 3/20 -3/4 0 3/4 -3/20 1/60 0 0;...
    0 1/280 -4/105 1/5 -4/5 0 4/5 -1/5 4/105 -1/280 0;...
    ];

%% calculation
len = length(array_input);
array_output = NaN(1,len);
array_output(1+accuracy/2:len-accuracy/2) = zeros(1,len-accuracy);
for i = 1+accuracy/2:1:len-accuracy/2
    for cf = -accuracy/2:1:accuracy/2
        array_output(i) = array_output(i)+coifficient(accuracy/2,cf+6)*array_input(cf+i);
    end
end
array_output = reshape(array_output,size_input);
end
