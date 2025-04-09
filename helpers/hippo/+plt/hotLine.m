
% Plot a single line with multiple colors.
%
%   USAGE
%       plt.hotLine(x,y,z,c,<w>,<m>)
%       x       x values
%       y       y values
%       z       z values
%       c       color values (e.g. 0s and 1s would yield a two-tone line)
%       w       (optional) line width
%       m       (optional) colormap
%
%   EXAMPLES
%       x = 0:1/8*pi:2*pi;
%       y = sin(x);
%       z = zeros(1,length(x));
%       c = cos(x);
%       hotLine(x,y,z,c,8,viridis(round((2*pi) / (1/8*pi))));
%       xlabel 'Radians'
%       ylabel 'Sin(x)'
%       cbar = colorbar;
%       ylabel(cbar,'Cos(x)')
%
%       % 3D slinky
%       x = linspace(0,2*10*pi,100);
%       y = sin(x);
%       z = cos(x);
%       c = meshgrid(1:10,1:10);
%       c = c(:);
%       hotLine(x,y,z,c,8,viridis(10));
%       xlabel 'Radians'
%       ylabel 'Sin(x)'
%       zlabel 'Cos(x)'
%       cbar = colorbar;
%       ylabel(cbar,'Period')
%       view([45,90,45])
%
% Written by BRK 2018

function h = hotLine(x,y,z,c,w,m)

%% check inputs

% must be 1D
if ~any(size(x) == 1) | ~any(size(y) == 1) | ~any(size(z) == 1) | ~any(size(c) == 1)
    error('Input arguments x, y, z, and c must be one-dimensional.')
end

% force row vectors
if size(x,2) == 1
    x = x';
end
if size(y,2) == 1
    y = y';
end
if size(z,2) == 1
    z = z';
end
if size(c,2) == 1
    c = c';
end

% defaults for optional inputs
if ~exist('w','var')
    w = 8;
end
if ~exist('m','var')
    m = get(groot,'defaultfigurecolormap');
end

%% plot it
h = surface(repmat(x,2,1),repmat(y,2,1),repmat(z,2,1),repmat(c,2,1),...
    'facecol','no',...
    'edgecol','interp',...
    'marker','o',...
    'markersize',3,...
    'linew',w);
colorbar
colormap(gca,m);