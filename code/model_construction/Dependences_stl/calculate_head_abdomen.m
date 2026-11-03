% Yaqing made this oin 7/13/2020 to calculate head and abdomen's com and
% eul base on their relative eul_b to the body

% input
%     total 0
%         mass         % kg  1*1 0
%     head
%         eul_b          % rad 1*3
%     body
%         com          % mm  1*3
%         eul          % rad 1*3
%     abdomen
%         eul_b          % rad 1*3

% output
%     total 0
%         mass         % kg  1*1 0
%     head
%         com          % mm  1*3
%         eul          % rad 1*3
%     body
%         com          % mm  1*3
%         eul          % rad 1*3
%     abdomen
%         com          % mm  1*3
%         eul          % rad 1*3


function  input = calculate_head_abdomen(animal_dia,input)

% head
neck_point = animal_dia.total.neck_point;
Rw2b = eul2rotm(input.body.eul);
Rbwh = eul2rotm(input.head.eul_b);
Rw2h = Rw2b * Rbwh;
input.head.eul = rotm2eul(Rw2h);
input.head.com = input.body.com + (Rw2b * neck_point)';
try
% abdomen
waist_point = animal_dia.total.waist_point;
% Rw2b = eul2rotm(input.body.eul);
Rbwa = eul2rotm(input.abdomen.eul_b);
Rw2a = Rw2b * Rbwa;
input.abdomen.eul = rotm2eul(Rw2a);
input.abdomen.com = input.body.com + (Rw2b * waist_point)';
catch
end

end