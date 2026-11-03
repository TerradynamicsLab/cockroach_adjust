% Yaqing write this to calculate head, com and eul, based on body
% information and head_eul_b
% input:
% input           struct
%     body        ------
%         dia     1*3
%         eul     1*3
%         com     1*3
%     head        ------
%         dia     1*3
%         eul_b   1*3
% output:
% output          struct
%     body        ------
%         dia     1*3
%         eul     1*3
%         com     1*3
%     head        ------
%         dia     1*3
%         eul     1*3
%         com     1*3
%      

function output = calculate_head_based_on_body_head_b(input)
output = input;
Rw2b = eul2rotm(input.body.eul);
Rb2h = eul2rotm(input.head.eul_b);
Rw2h = Rw2b * Rb2h;
output.head.eul = rotm2eul(Rw2h);
output.head.com = input.body.com + (Rw2b*[input.body.dia(1);0;0]+Rw2h*[input.head.dia(1);0;0])';
end