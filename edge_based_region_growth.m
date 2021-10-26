function [ M ] = edge_based_region_growth(img, fluctuation, row, col, mode)
% edge_based_region_growth: Detect region from one seed
% Parameters:
% - img: gray scaled image;
% - fluctuation: the final identified region will have intensity value in
% range of <fluctuation> of average;
% - row: row of seed pixel
% - col: column of seed pixel
% - mode: default find region only, while set 1 for edge only

[tot_row, tot_col] = size(img);

M = false(tot_row, tot_col);
M_cached = M;
M(row, col) = 1;
while (sum(M(:)) ~= sum(M_cached(:)))
    M_cached = M;
    M_val = img(M);
    M_avg = mean(M_val);
    se = strel('disk', 1, 0);
    M_se = imdilate(M, se);
    candidate_index = M_se - M;
    candidate_pos_index = find(candidate_index);
    candidate_value = img(candidate_pos_index);
    is_accepted = candidate_value > M_avg - fluctuation & candidate_value < M_avg + fluctuation;
    M(candidate_pos_index(is_accepted)) = 1;
end
if (mode == 1)
    M = M - imerode(M, se);
end
end

