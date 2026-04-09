% --- PARAMETERS & PREALLOCATION ---
Number_files = 80;
A = 195; % Measuring time (sec)
B = 5;   % Saving time (sec)
C = 1024; % Frequency (Hz)
D = 0.1;  % Shaft Diameter (m)
block_size = 1024;

Ntotal = (A+B) * Number_files * C;

F = NaN(1, Ntotal); 
T = NaN(1, Ntotal); 
V = NaN(1, Ntotal); 
RPM = NaN(1, Ntotal);

% Main data directory for time-series plots
mat_dir = 'C:\Users\USER\OneDrive\文档\MATLAB\Data_Labview\After_30h';

%% --- DATA LOADING ---
fprintf('Loading .mat files for time-series analysis...\n');
for i = 1:Number_files
    filename = fullfile(mat_dir, ['data(', num2str(i), ').mat']);
    if exist(filename, 'file')
        load(filename); 
        
        if length(Force) >= A * C
            idx1 = (A+B)*(i-1)*C + 1;
            idx2 = ((A+B)*i-B)*C;
            
            % Apply calibrations
            F(idx1:idx2)   = abs(Force) * 12.5;
            T(idx1:idx2)   = Torque * 20;
            V(idx1:idx2)   = Kontakt_V; 
            RPM(idx1:idx2) = Rotation_speed * 268.75 - 537.5; 
        end
    end
end

% --- CLEANING: Remove unrealistic RPM drops and spikes ---
for k = 2:length(RPM)
    if (RPM(k-1) > 100 && RPM(k) < 20) || (RPM(k) < 0 || RPM(k) > 600)
        RPM(k) = NaN;
    end
end
