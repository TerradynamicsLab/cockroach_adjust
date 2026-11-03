% compare_points: 0:=, -1:A<B, 1:A>B
function result = compare_points(A,B)
for i = 1:length(A)
    if A(i)<B(i)
        result = -1;
        return;
    end
    if A(i)>B(i)
        result = 1;
        return;
    end
end
result = 0;
return;
end