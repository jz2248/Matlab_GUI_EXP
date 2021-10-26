function [ M ] = fetch_LV_region(img, mask, lower, upper, row, col, mode)
% fetch_LV_region: Detect region from one seed
% Parameters:
% - img: 2D grayscale image;
% - mask: established mask of blood region
% - lower: lower bound of LV content
% - upper: upper bound of LV content
% - row: row of seed pixel
% - col: column of seed pixel
% - mode: default find region only, while set 1 for edge only

M = false(size(img));
M(row, col) = 1;
for x = upper:-5:lower
    M_cached = false(size(img));
    while (sum(M(:)) ~= sum(M_cached(:)))
        M_cached = M; % cached before new round propagation
        se = strel('disk', 3, 0);
        M_se = imdilate(M, se);
        candidate_index = M_se - M;
        candidate_pos_index = find(candidate_index);
        candidate_value = img(candidate_pos_index);
        is_accepted = (candidate_value >= x);
        M(candidate_pos_index(is_accepted)) = 1;
    end
end

if (mode == 1)
    M = M - imerode(M, se);
end
end

