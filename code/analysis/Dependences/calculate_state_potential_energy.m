% Yaqing created this to calculate potential energy of a certain system
% state.
% input
%     body
%         mass         % kg
%         com          % mm 1*3
%     beam
%         % stiffness    % n.mm/rad
%         angle_left   % rad
%         angle_right  % rad
% output:
% potential_energy     % mJ
        
function potential_energy = calculate_state_potential_energy(input)
% settings
g = 9.815;
beam_com = 0.1 /2*1000; %mm
beam_mass = 0.731 * 1e-3; %kg
beam_stiffness = 2.5; %n.mm/rad

% calculate potential energy
cockroach_gravitational_potential_energy = input.body.mass * g * input.mass_z;
beam_gravitational_potential_energy = beam_mass * g * beam_com * (cos(input.beam.angle_left)-1+cos(input.beam.angle_right)-1);
beam_elastic_potential_energy = 0.5 * beam_stiffness * (input.beam.angle_left^2 + input.beam.angle_right^2);
potential_energy = cockroach_gravitational_potential_energy + beam_gravitational_potential_energy + beam_elastic_potential_energy;
end
