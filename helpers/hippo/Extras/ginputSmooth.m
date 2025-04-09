% ginputSmooth: continuously store mouse position while left mouse button is held down
%
% Returns list of x and y coordinates in axes units
% Ideal for use in MClust cutter utility (e.g. DrawPolygonOnAxes) instead of ginput
%
% Written by BRK 2015. Please distribute and modify freely.

function [X,Y] = ginputSmooth(maxPts)

% initialize coordinate vectors and handles structure
if nargin == 0
    maxPts = 15;
end
X = [];
Y = [];
finalData = [];
dynamicData = guihandles(gcf);
dynamicData.x = [];
dynamicData.y = [];
guidata(gcf,dynamicData);

% set button functions (need uicontrol off)
z = zoom;
p = pan;
zSwitch = false;
pSwitch = false;
if strcmpi(z.Enable,'on')
    zoom off
    zSwitch = true;
elseif strcmpi(p.Enable,'on')
    pan off
    pSwitch = true;
end
set(gcf,'windowbuttondownfcn',@click);

    function click(~,~)
        % clicking activates motion and release functions
        set(gcf,'windowbuttonmotionfcn',@move);
        set(gcf,'windowbuttonupfcn',@release);
        function move(~,~)
            % store mouse coordinates as it moves
            currentPos = get(gca,'CurrentPoint');
            currentX = currentPos(1,1);
            currentY = currentPos(1,2);
            dynamicData = guidata(gcbo);
            dynamicData.x = [dynamicData.x; currentX];
            dynamicData.y = [dynamicData.y; currentY];
            guidata(gcbo,dynamicData);
        end
        function release(~,~)
            % reset button fcns and get output
            set(gcf,'windowbuttondownfcn','');
            set(gcf,'windowbuttonmotionfcn','');
            set(gcf,'windowbuttondownfcn','');
            finalData = guidata(gcbo);
            X = finalData.x;
            Y = finalData.y;
            % limit number of stored coordinates to save memory
            totalPoints = length(X);
            if totalPoints > maxPts
                inds = round(linspace(1, totalPoints, maxPts));
                X = X(inds);
                Y = Y(inds);
            end
            % need to alter fig property to trigger resume of waitfor
            set(gcf,'UserData',datestr(now))
        end
    end
% wait for fig property change triggered by button release
waitfor(gcf,'UserData')
% resume uicontrol
if zSwitch
    zoom on
elseif pSwitch
    pan on
end
end

