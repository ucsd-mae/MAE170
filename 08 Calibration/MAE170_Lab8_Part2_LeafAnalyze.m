
%% Enter your measured / experimentally determined parameters here
T_correction = 0; % experimentally determined relative temp offset
H_correction = 0; % experimentally determined relative RH offset
leaf_area = 0; % leaf cross-sectional area (cm^2)
flow_rate = 0; % pump flow rate (cm^3 / min)

% assuming chamber sensor is "correct":
% apply corrections to ambient temp & RH
Tamb2 = Tamb + T_correction;
Hamb2 = Hamb + H_correction;

% calculate chamber saturation vapor pressure & vapor density
% using the equations in the lab procedure
SVPchb = _____;
VDchb = _____;

% calculate ambient saturation vapor pressure & vapor density
% using the equations in the lab procedure
SVPamb = _____;
VDamb = _____;

% calculate vapor density gradient
deltaRHO = VDchb - VDamb;

% Calculate transpiration rate
% UNITS
% mg/m^2/sec = mg / m3    *         m3 / s          *    1 / m2                       
tRate = (deltaRHO * 1e3) * (flow_rate /60 * 1e-6)  * (1 / leaf_area * 1e4);

figure(1)
plot(t, tRate, 'b')
ylabel('Transpiration Rate (mg/m^2/s)')
xlabel('Time (s)')