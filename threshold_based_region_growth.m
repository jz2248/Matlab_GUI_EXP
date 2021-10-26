function [i_list, vol_list, M] = threshold_based_region_growth(img, mask, row, col, mode)
% threshold_based_region_growth: Detect region from one seed
% Parameters:
% - img: 2D grayscale image;
% - mask: generated mask for the tumor region
% - row: row of seed pixel
% - col: column of seed pixel
% - mode: default find region only, while set 1 for edge only

mask_val = img(mask);
theta = mean(mask_val);
mask_val_std = std(double(mask_val));

M = false(size(img));
M(row, col) = 1;

i_list = 1:0.1:4;
vol_list = zeros(size(i_list));
fluctuation = 0;

for x = 1:size(i_list, 2)
    i = i_list(x);
    growth_theta = theta / i;
    % initial cached mask for new growth_theta to turn on the while loop
    M_cached = false(size(img));
    while (sum(M(:)) ~= sum(M_cached(:)))
        M_cached = M; % cached before new round propagation
        se = strel('disk', 1, 0);
        M_se = imdilate(M, se);
        candidate_index = M_se - M;
        candidate_pos_index = find(candidate_index);
        candidate_value = img(candidate_pos_index);
        % Lower-bound thresholding region-growth
        is_accepted = (candidate_value >= growth_theta - fluctuation); 
        M(candidate_pos_index(is_accepted)) = 1;
    end

    vol = sum(M(:));
    vol_list(x) = vol;
end

if (mode == 1)
    M = M - imerode(M, se);
end
end
