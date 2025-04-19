
% Script for spatial clustering analysis, tied to Figure 5
% functions called: clustered_curve_wrapper.m and find_clustered_curve.m


%% run clustering
% all_center_pts: center location of neuron ROIs in Allen coordinates. Number of neurons x 3 (x, y, z)
% group_inds: indices of neurons in a response category (for example, activated by LiCl). Number of neurons x 1

make_plot =  1;
nnsh = 100; 
maxwindow = 1100;
[temp_radii,avg_ring_prob,std_ring_prob,shuffle_avg_prob,shuffle_std_prob,ring_prob,hold_sh_ring_prob] = ...
            clustered_curve_wrapper(all_center_pts(:,1:2),group_inds,nsh,make_plot,'window_max_dist',maxwindow);

% Plot probability curve (as in Figure 5C)
figure;shadedErrorBar(temp_radii,avg_ring_prob,std_ring_prob./sqrt(length(group_inds)),'lineprops','-b');
hold on;
shadedErrorBar(temp_radii,shuffle_avg_prob,shuffle_std_prob);
legend('data','shuffle')
xlabel('Distance (um)');
ylabel('Probability of other cells in the same group')
hline(0,'k-')
xlim([0 400])


