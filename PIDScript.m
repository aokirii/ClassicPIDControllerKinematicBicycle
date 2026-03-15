clc;

%% 1. HARİTA SEÇİMİ
map_type = 3;   % 1=Çember, 2=Dikdörtgen, 3=Hand Figure

switch map_type
    case 1
        run('/Users/kasimesen/Desktop/Tasarım/2. Week/YuvarlakMap.m');
    case 2
        run('/Users/kasimesen/Desktop/Tasarım/2. Week/KareMap.m');
    case 3
        run('/Users/kasimesen/Desktop/Tasarım/2. Week/HandFigureMap.m');
    otherwise
        error('Geçersiz harita seçimi.');
end

if ~exist('waypoints','var') || size(waypoints,2)~=2 || size(waypoints,1)<2
    error('waypoints bulunamadı veya format yanlış. Nx2 olmalı.');
end

%% 2. SİSTEM PARAMETRELERİ
v_ref = 1.2;

%% 3. REFERANS YOL
wp = waypoints;
wp = wp([true; sqrt(sum(diff(wp).^2,2)) > 1e-9], :);
s  = [0; cumsum(sqrt(sum(diff(wp).^2,2)))];
[sU, ia] = unique(s, 'stable'); wpU = wp(ia,:);

sEnd = sU(end);
T_1lap = sEnd / v_ref;
N_loops = 5;
T_sim = T_1lap * N_loops;

% Dense referans dizileri (nearest_ref_point okuyacak)
s_dense   = linspace(0, sEnd, 1500)';
x_ref_arr = interp1(sU, wpU(:,1), s_dense, 'pchip');
y_ref_arr = interp1(sU, wpU(:,2), s_dense, 'pchip');

dx = gradient(x_ref_arr);
dy = gradient(y_ref_arr);
theta_ref_arr = atan2(dy, dx);

%% 4. START / GOAL
if exist('startPt','var') && numel(startPt)==2
    sp = startPt(:).';
else
    sp = [wp(1,1), wp(1,2)];
end

%% 5. BAŞLANGIÇ KOŞULLARI
x_init = 10;
y_init = 25;

% En yakın referans noktasının heading'i
dists = (x_ref_arr - x_init).^2 + (y_ref_arr - y_init).^2;
[~, closest_idx] = min(dists);
theta_init = theta_ref_arr(closest_idx);

%% 6. WORKSPACE'E YÜKLEME
assignin('base', 'T_sim', T_sim);
assignin('base', 'x_init', x_init);
assignin('base', 'y_init', y_init);
assignin('base', 'theta_init', theta_init);

% Referans diziler (nearest_ref_point okuyacak)
assignin('base', 'x_ref_arr', x_ref_arr);
assignin('base', 'y_ref_arr', y_ref_arr);
assignin('base', 'theta_ref_arr', theta_ref_arr);

%% 7. BİLGİ ÇIKTISI
fprintf('\n========================================\n');
fprintf('  PID Master Script (Nearest Point)\n');
fprintf('========================================\n');
fprintf('Harita tipi      : %d\n', map_type);
fprintf('Referans nokta   : %d\n', numel(x_ref_arr));
fprintf('Toplam yol       : %.1f m\n', sEnd);
fprintf('Tek tur süresi   : %.1f s\n', T_1lap);
fprintf('Tur sayısı       : %d\n', N_loops);
fprintf('Toplam süre      : %.1f s\n', T_sim);
fprintf('Başlangıç        : [%.2f, %.2f]\n', x_init, y_init);
fprintf('theta_init       : %.1f deg\n', rad2deg(theta_init));
fprintf('========================================\n');
fprintf('From Workspace blokları SİLİNEBİLİR.\n');
fprintf('ErrorCalc sadece x, y, theta alır.\n');
fprintf('========================================\n');

%% 8. REFERANS YOL GÖRSELLEŞTİRME
figure('Color','w'); hold on; grid on; axis equal;
plot(x_ref_arr, y_ref_arr, 'b--', 'LineWidth', 2);
plot(x_init, y_init, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
title('Referans Yol'); xlabel('x'); ylabel('y');
legend('Referans', 'Start', 'Location', 'best');