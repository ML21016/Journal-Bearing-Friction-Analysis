% Force Check
figure('Name', 'Force Quality Check');
plot(1:length(F), F, 'b'); hold on;
plot(linspace(1, length(F), length(F_comp)), F_comp, 'r', 'LineWidth', 2);
plot(1:length(F), F_interp_makima, 'g', 'LineWidth', 1.5);
title('Force: Original (blue), Compressed (red), Makima (green)');
grid on; ylabel('Force [N]');

%% --- GRAPH SET 2: SCIENTIFIC TIME-SERIES PLOTS ---

% Plot 1: Contact Voltage & RPM vs. Time (Dual Axis)
figure('Color', 'w', 'Name', 'Dual Axis Voltage-RPM');
yyaxis left
plot(t, V_interp_makima, 'Color', [0 0.447 0.741], 'LineWidth', 1.2); 
ylabel('Contact Voltage [V]'); ylim([0, max(V_interp_makima)*1.2]);
ax = gca; ax.YColor = [0 0.447 0.741];
yyaxis right
plot(t, RPM_interp_makima, 'Color', [0.85 0.325 0.098], 'LineWidth', 1.2); 
ylabel('Rotation Speed [RPM]'); ylim([0, 600]);
ax.YColor = [0.85 0.325 0.098];
xlabel('Time [min]'); title('Contact Voltage & Rotation Speed vs. Time');
grid on;

% Plot 2: ISO Cleanliness & RPM
iso_file = 'C:\Users\USER\OneDrive\文档\MATLAB\Data_Hydak\After_30h.dat';
if exist(iso_file, 'file')
    opts = detectImportOptions(iso_file, 'Delimiter', '\t');
    opts.VariableNamesLine = 7; opts.DataLines = 8;         
    tbl = readtable(iso_file, opts);
    ISO_4 = tbl.Var4; ISO_6 = tbl.Var5; ISO_14 = tbl.Var6;
    t_iso = linspace(min(t), max(t), length(ISO_4));
    
    I4_i = fillmissing(interp1(t_iso, ISO_4, t, 'linear', 'extrap'), 'linear');
    I6_i = fillmissing(interp1(t_iso, ISO_6, t, 'linear', 'extrap'), 'linear');
    I14_i = fillmissing(interp1(t_iso, ISO_14, t, 'linear', 'extrap'), 'linear');

    figure('Color', 'w', 'Name', 'ISO Cleanliness');
    yyaxis left
    plot(t, RPM_interp_makima, 'b'); ylabel('Rotation Speed [RPM]'); ylim([0, 600]);
    yyaxis right
    plot(t, I4_i, '--c', t, I6_i, '--m', t, I14_i, '--k');
    ylabel('ISO-Class'); xlabel('Time [min]');
    title('ISO-Class & Rotation Speed vs. Time');
    legend('RPM', 'ISO 4μm', 'ISO 6μm', 'ISO 14μm'); grid on;
end
