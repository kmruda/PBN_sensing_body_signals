function [temp_radii,avg_ring_prob,std_ring_prob,shuffle_avg_prob,shuffle_std_prob,ring_prob,hold_sh_ring_prob] = ...
    clustered_curve_wrapper(all_centers,group_indices,nsh,make_plot,varargin)
% wrapper for find_clustered_curve. 
% Inputs: 
% all_centers: center locations of neurons. Number of neurons x 2 (x, y)
% group_indices: indices of neurons in a response category (for example, activated by LiCl). Number of neurons x 1
% nsh: number of shuffles
% make_plot: flag to plot results
% other options: see find_clustered_curve

% run on actual data/groups, then shuffle identities

% actual data
[temp_radii,avg_ring_prob,std_ring_prob,ring_prob] = find_clustered_curve(all_centers,group_indices,varargin{:});


% shuffled data
num_in_group = length(group_indices);
hold_temp_radii = nan(length(temp_radii),nsh);
hold_sh_avg_prob = nan(length(temp_radii),nsh);
hold_sh_std_prob = nan(length(temp_radii),nsh);
hold_sh_ring_prob = cell(1,nsh);

if num_in_group < 3
    shuffle_avg_prob = nan(length(temp_radii),1);
    shuffle_radii = nan(length(temp_radii),1);
    shuffle_std_prob = nan(length(temp_radii),1);
else
    for sh = 1:nsh
        if mod(sh,10) == 0
            sh
        end
        shuffled_indices = randperm(length(all_centers),num_in_group);
        [sh_temp_radii,sh_avg_ring_prob,sh_std_ring_prob,sh_ring_prob] = find_clustered_curve(all_centers,shuffled_indices,varargin{:});
        hold_temp_radii(:,sh) = sh_temp_radii;
        hold_sh_avg_prob(:,sh) = sh_avg_ring_prob;
        hold_sh_std_prob(:,sh) = sh_std_ring_prob;
        hold_sh_ring_prob{sh} = sh_ring_prob;
    end
    shuffle_avg_prob = nanmean(hold_sh_avg_prob,2);
    shuffle_radii = sh_temp_radii;
    shuffle_std_prob = nanstd(hold_sh_std_prob,[],2);
end

if make_plot
    figure;shadedErrorBar(temp_radii,avg_ring_prob,std_ring_prob./sqrt(length(group_indices)),'lineprops','-b');
    hold on;
    shadedErrorBar(shuffle_radii,shuffle_avg_prob,shuffle_std_prob);
    legend('data','shuffle')
    xlabel('Distance (pixels)');
    ylabel('Probability of other cells in the same group')
    hline(0,'k-')
end




end

