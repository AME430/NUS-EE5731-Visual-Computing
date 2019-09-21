function [best_mat1,best_mat2,best_h] = part6_ransac(matches1,matches2,img1,img2)
% Initialise RANSAC parameters
iter = 7000;
best_inline_count = 0;
e_threshold = 0.5;

% start RANSAC iterations
for k = 1:iter
    % choose 4 random pairs of matches and do homography
    idx = randperm(size(matches1,2),4);
    mat1 = matches1(:,idx);
    mat2 = matches2(:,idx);
    h = part6_hmat(mat2, mat1);
    
    % check homography for all matches and count
    norms = vecnorm(part6_dohomography(matches2,h) - matches1) < e_threshold;
    inline_count = sum(norms);
    
    % best inline count will correspond to best homography matrix
    if inline_count > best_inline_count
        best_norm = norms;
        best_inline_count = inline_count;
        best_h = h;
    end
end

[~, best_cols] = find(best_norm);
best_mat1 = matches1(:,best_cols);
best_mat2 = matches2(:,best_cols);

%% for plotting
% match_fig = [img1 img2];
% figure; imshow(match_fig); axis on; hold on ;
% for k = 1:best_inline_count
%     x = [best_mat1(1,k), best_mat2(1,k)] + [0, size(img2,2)];
%     y = [best_mat1(2,k), best_mat2(2,k)] ;
%     plot(x,y,'color',rand(1,3),'LineWidth', 1.2); title('Part 6: Matches found from best RANSAC');
% end; hold off;
end

