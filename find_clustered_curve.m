function [temp_radii,avg_ring_prob,std_ring_prob,ring_prob] = find_clustered_curve(all_centers,group_indices,varargin)

% inputs: list of all centers, indices of one group, 
% params: ring step size, start point

% output: probability of cells being in the same group for different distances

default_radius_step = 25;
default_radius_start = 5;
default_window_max = 796; % for FOV in pixels

p = inputParser;
addParameter(p,'radius_step',default_radius_step,@(x) isnumeric(x));
addParameter(p,'radius_start',default_radius_start,@(x) isnumeric(x));
addParameter(p,'window_max_dist',default_window_max,@(x) isnumeric(x));
addRequired(p,'all_centers');
addRequired(p,'group_indices');
parse(p,all_centers,group_indices,varargin{:});
params = p.Results;
radius_step = params.radius_step;
radius_start = params.radius_start;
window_max_dist = params.window_max_dist;

temp_radii = radius_start:radius_step:(window_max_dist+radius_step);

ring_prob = nan(length(temp_radii),length(group_indices));
circ_prob = nan(length(temp_radii),length(group_indices));

% find curve for grouped data
if length(group_indices) < 3 % don't run with too few cells
    avg_ring_prob = nan(1,length(temp_radii));
    std_ring_prob = nan(1,length(temp_radii));
else
    for cc = 1:length(group_indices) % each cell within the group
        index = group_indices(cc);
        this_center = all_centers(index,:);
        % find the furthest cell from this one as the max concentric circle
        distances = sqrt(sum((all_centers - this_center) .^ 2, 2));
        largest_radius = max(distances);
        if largest_radius > window_max_dist
            largest_radius = window_max_dist; % only go out as far as this parameter
        end
        % concentric circles to use
        radii = radius_start:radius_step:largest_radius+radius_step;
        cells_in_circ = nan(1,length(radii));
        same_in_circ = nan(1,length(radii));
        same_in_ring = zeros(1,length(radii));
        cells_in_ring = zeros(1,length(radii));
        for r = 1:length(radii)
            this_radius = radii(r);
            % get cells within that circle
            in_circle_inds = find(distances<=this_radius);
            % get fraction of those cells that are in the same group
            in_group_inds = intersect(in_circle_inds,group_indices);
            cells_in_circ(r) = length(in_circle_inds)-1;
            same_in_circ(r) = length(in_group_inds)-1;

        end
        circ_prob(1:length(radii),cc) = same_in_circ./cells_in_circ;
        for r = 2:length(radii)
            same_in_ring(r) = same_in_circ(r) - (same_in_circ(r-1));
            cells_in_ring(r) = cells_in_circ(r) - (cells_in_circ(r-1));
        end
        ring_prob(1:length(radii),cc) = same_in_ring./cells_in_ring;

    end

    avg_ring_prob = nanmean(ring_prob,2);
    std_ring_prob = nanstd(ring_prob,[],2);

end


end

