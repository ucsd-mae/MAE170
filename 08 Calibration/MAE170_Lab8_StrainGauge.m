%% Known properties of the cantilevered beam
b = 31.9/1000; % cross section width of beam (meters)
h = 4.8/1000; % cross section height of beam (meters)

momentInertia = b * h^3 / 12; % axis area moment of inertia  (m^4)

E = 68.9*10^9; %  Young's modulus of Aluminum (Pascal)

opamp_gain = 100;

%% Your measurements go here
% be sure to use SI units
L = ____/1000; % length of beam in meters
x = ____/1000; % location of strain gauge in meters

%        [m1 m2 m3 m4 m5]
masses = [__ __ __ __ __]; % should be in kg
%             [y1 y2 y3 y4 y5]
deflections = [__ __ __ __ __]; % should be in m
%
Vex = ____; % Measure Vex in volts
%       [V1 V2 V3 V4 V5]
deltaVout =  [__ __ __ __ __]; % Vout in volts


%% Functions for Calculating Strain, Deflection, and Change in Resistance
function strain_from_theory = predictStrain(mass, momentInertia, E, L, x, y)
    % -----------------calculate strain from known values------------------
    strain_from_theory = _________;% < your equation here
end

function deflection_from_theory = predictDeflection(mass, momentInertia, E, L, x)
     % -----------------calculate deflection from known values-------------
    deflection_from_theory = _________; % < your equation here
end

function deltaRoverR = calculateDeltaRratio(deltaVout, Vex, Gain)
    % ---------calculate change in resistance ratio from known values------
    deltaRoverR = _________;% < your equation here
end

%% Calculate Strain and Predicted Deflection
epsilon_theory = predictStrain(masses, momentInertia, E, L, x, h/2);

deflection_theory = predictDeflection(masses, momentInertia, E, L, L);

%% plot strain vs deltaR/R
figure;
hold on;
% covert voltage measurements to resistance ratio
deltaRoverR = calculateDeltaRratio(deltaVout, Vex, opamp_gain);
% linear regression from values
lineOfBestFit = polyfit(deltaRoverR, epsilon_theory, 1);
% plot measured values
plot(deltaRoverR, epsilon_theory, "-o");
% plot linear regression
xs = linspace(min(deltaRoverR), max(deltaRoverR));
ys = lineOfBestFit(1) * xs + lineOfBestFit(2);
plot(xs, ys, "--");
legend("Strain vs. measured change in resistance", "Linear Regression")
% nicely format calculated values and report on plot
lineOfBestFitString = sprintf("$\\epsilon = %.4f \\cdot \\Delta R / R + %.2f $", lineOfBestFit(1), lineOfBestFit(2));
dim1 = [.2 .7 .1 .1];
annotation("textbox", dim, "String",lineOfBestFitString, "Interpreter","latex",'FitBoxToText','on');

xlabel("$\Delta R / R$", "Interpreter","latex");
ylabel("$\epsilon$ $\left(\frac{\Delta l}{ l}\right)$", "Interpreter","latex");
title("Calculating Gauge Factor")
hold off;

%% plot predicted and measured deflection
figure;
hold on;
% calculate force from masses used.
forces = masses * 9.81; % force in N
plot(forces, deflections, "-o");
plot(forces, deflection_theory, "-o");
legend("Measured deflection", "Predicted Deflection", "location", "southeast");
xlabel("Force (N)");
ylabel("Deflection (m)");
title("Comparing Predicted Deflection and Measured Deflection");
hold off;