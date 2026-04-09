%% --- GRAPH SET 3: MULTI-DURATION STRIBECK COMPARISON ---
data_folders = { ...
    'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_3h', ...
    'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_6h', ...
    'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_30h', ...
    'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_36h', ...
    'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_60h'};
labels = {'3h','6h','30h','36h','60h'};
colors = lines(numel(data_folders));

figure('Color', 'w', 'Position', [100, 100, 1000, 700], 'Name', 'Stribeck Comparison'); 
hold on; grid on;
global_rpm_min = [];

for i = 1:numel(data_folders)
    mat_dir_strib = data_folders{i};
    file_list = dir(fullfile(mat_dir_strib, 'data(*).mat'));
    if isempty(file_list); continue; end
    
    N_files = numel(file_list);
    S_F = NaN(1, (A+B)*N_files*C); S_T = S_F; S_RPM = S_F;
    for j = 1:N_files
        f_name = fullfile(mat_dir_strib, ['data(', num2str(j), ').mat']);
        load(f_name);
        idx1 = (A+B)*(j-1)*C + 1; idx2 = ((A+B)*j-B)*C;
        S_F(idx1:idx2) = abs(Force) * 12.5;
        S_T(idx1:idx2) = Torque * 20;
        S_RPM(idx1:idx2) = Rotation_speed * 268.75 - 537.5;
    end
    
    n_b = floor(length(S_F) / block_size);
    Fc_s = zeros(1, n_b); Tc_s = zeros(1, n_b); Rc_s = zeros(1, n_b);
    for k = 1:n_b
        idx_s = (k-1)*block_size + 1 : k*block_size;
        Fc_s(k) = mean(S_F(idx_s), 'omitnan'); Tc_s(k) = mean(S_T(idx_s), 'omitnan'); Rc_s(k) = mean(S_RPM(idx_s), 'omitnan');
    end
    mu_raw = (2 * Tc_s) ./ (max(1, Fc_s) * 1000 * D);
    
    valid_s = ~isnan(mu_raw) & Rc_s > 40 & Rc_s < 180 & mu_raw < 0.1;
    x_f = Rc_s(valid_s)'; y_f = mu_raw(valid_s)';
    
    if length(x_f) > 10
        ft = fittype('a*exp(-x/20) + c*x^1.6 + d', 'independent', 'x');
        fitres = fit(x_f, y_f, ft, 'StartPoint', [0.1, 1e-7, 0.003]);
        rpm_p = linspace(40, 180, 500);
        mu_p = feval(fitres, rpm_p);
        plot(rpm_p, mu_p, '-', 'LineWidth', 3, 'Color', colors(i,:), 'DisplayName', labels{i});
        [~, m_idx] = min(mu_p);
        global_rpm_min = [global_rpm_min, rpm_p(m_idx)];
    end
end

% Regime Annotations
if ~isempty(global_rpm_min)
    m_rpm = mean(global_rpm_min, 'omitnan');
    xlim([40, 180]); ylim([0.002, 0.008]);
    fill([40, m_rpm, m_rpm, 40], [0 0 0.01 0.01], [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.2, 'HandleVisibility', 'off');
    fill([m_rpm, 180, 180, m_rpm], [0 0 0.01 0.01], [0.9 1 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.2, 'HandleVisibility', 'off');
    text(55, 0.0075, 'Mixed Friction', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(140, 0.0075, 'Hydrodynamic', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end
xlabel('Rotation Speed (RPM)'); ylabel('Friction Coefficient (\mu)');
title('Scientific Stribeck Transition Comparison'); legend('show');
