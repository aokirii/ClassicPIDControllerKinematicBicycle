function persistent_anim_update(x, y, theta)
% CANLI ANİMASYON MOTORU
% Referans yolu workspace'teki x_ref_arr, y_ref_arr'dan okur.

persistent hFig hTrail hSprite trailX trailY idx
persistent carImg carAlpha hasAlpha halfW halfH theta_offset
persistent initialized updateCounter

if isempty(initialized)
    initialized = true;
    updateCounter = 0;
    idx = 0;
    trailX = [];
    trailY = [];
    theta_offset = -pi/2;
    
    % Sprite yükle
    iconPath = '/Users/kasimesen/Desktop/Tasarım/car.png';
    try
        [carImg, ~, carAlpha] = imread(iconPath);
        carImg = im2double(carImg);
        hasAlpha = ~isempty(carAlpha);
        if hasAlpha, carAlpha = im2double(carAlpha); end
    catch
        carImg = ones(20,20,3);
        hasAlpha = false;
        carAlpha = [];
    end
    
    halfW = 3;
    halfH = 3;
    
    % Figür oluştur
    hFig = figure('Name','Live Tracking','Color','w','NumberTitle','off');
    hold on; grid on; axis equal;
    title('PID Live Tracking'); xlabel('x'); ylabel('y');
    
    % Referans yol — workspace'teki dizilerden oku
    try
        xr_data = evalin('base', 'x_ref_arr');
        yr_data = evalin('base', 'y_ref_arr');
        plot(xr_data, yr_data, 'b--', 'LineWidth', 2);
        
        pad = 15;
        xlim([min(xr_data)-pad max(xr_data)+pad]);
        ylim([min(yr_data)-pad max(yr_data)+pad]);
    catch
    end
    
    % Trail
    hTrail = plot(nan, nan, 'm-', 'LineWidth', 1.5);
    
    % Sprite
    rotImg = imrotate(carImg, -rad2deg(theta + theta_offset), 'bilinear', 'crop');
    hSprite = image([x-halfW x+halfW], [y-halfH y+halfH], rotImg);
    if hasAlpha
        rotAlpha = imrotate(carAlpha, -rad2deg(theta + theta_offset), 'bilinear', 'crop');
        set(hSprite, 'AlphaData', rotAlpha);
    end
    uistack(hSprite, 'top');
end

if ~isvalid(hFig)
    return;
end

idx = idx + 1;
trailX(idx) = x;
trailY(idx) = y;

updateCounter = updateCounter + 1;

if mod(updateCounter, 10) == 0
    set(hTrail, 'XData', trailX(1:idx), 'YData', trailY(1:idx));
    set(hSprite, 'XData', [x-halfW x+halfW], 'YData', [y-halfH y+halfH]);
    
    if mod(updateCounter, 50) == 0
        rotImg = imrotate(carImg, -rad2deg(theta + theta_offset), 'bilinear', 'crop');
        set(hSprite, 'CData', rotImg);
        if hasAlpha
            rotAlpha = imrotate(carAlpha, -rad2deg(theta + theta_offset), 'bilinear', 'crop');
            set(hSprite, 'AlphaData', rotAlpha);
        end
    end
    
    drawnow limitrate;
end
end