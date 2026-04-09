%% --- COMPRESSION & MAKIMA INTERPOLATION ---
num_blocks = floor(length(F) / block_size);
F_comp = zeros(1, num_blocks); T_comp = zeros(1, num_blocks);
V_comp = zeros(1, num_blocks); RPM_comp = zeros(1, num_blocks);

for k = 1:num_blocks
    idx = (k-1)*block_size + (1:block_size);
    F_comp(k)   = mean(F(idx), 'omitnan');
    T_comp(k)   = mean(T(idx), 'omitnan');
    V_comp(k)   = mean(V(idx), 'omitnan');
    RPM_comp(k) = mean(RPM(idx), 'omitnan');
end

x_c = 1:num_blocks;
x_i = linspace(1, num_blocks, length(F));

% Your preferred Makima Interpolation
F_interp_makima   = makima(x_c, F_comp, x_i);
T_interp_makima   = makima(x_c, T_comp, x_i);
V_interp_makima   = makima(x_c, V_comp, x_i);
RPM_interp_makima = makima(x_c, RPM_comp, x_i);

% Final RPM clean-up
RPM_interp_makima = fillmissing(RPM_interp_makima, 'linear');
RPM_interp_makima(RPM_interp_makima < 0 | RPM_interp_makima > 600) = NaN;
RPM_interp_makima = fillmissing(RPM_interp_makima, 'linear');

t = (0:length(F)-1)/C/60; % Time in min

%% --- GRAPH SET 1: QUALITY CHECK (Original vs Compressed vs Makima) ---
% Voltage Check
figure('Name', 'Voltage Quality Check');
plot(1:length(V), V, 'b'); hold on;
plot(linspace(1, length(V), length(V_comp)), V_comp, 'r', 'LineWidth', 2);
plot(1:length(V), V_interp_makima, 'g', 'LineWidth', 1.5);
title('Contact Voltage: Original (blue), Compressed (red), Makima (green)');
grid on; legend('Original', 'Compressed', 'Makima');
