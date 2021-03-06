%% Initialise
clc;
clear;
close all;
addpath(genpath('..\GCMex\'));
tic;

%% Parameters & Properties
% change this value to change the weight of smoothness or prior term. high value = encourage smoothness between neightbours
ratio = 65;         % ratio = number of patches per dimension (65)
% higher  = more patches, small patchers, take longer time but maybe better results
lambda = 50;        % smoothness factor (50)
num_of_labels = 2;  % number of labels (2)

source_colour = reshape([0; 0; 255],[1,1,3]);       % foreground, 0, blue,   source
sink_colour = reshape([245; 210; 110],[1,1,3]);     % background, 1, yellow, sink

%% Read images
img = imread('..\assg2\bayes_in.jpg');
[H, W, ~] = size(img);
vert = floor(H/ratio);   % height of patch
hor = floor(W/ratio);    % width of patch

%% GraphCut denoising
cleaned_img = zeros(size(img),'like',img);  % initialise canvas
disp('Start denoise...');

for idx_x = 1:floor(W/hor)
    for idx_y = 1:floor(H/vert)
        ylim = idx_y*vert;
        xlim = idx_x*hor;
        
        if idx_y == floor(H/vert)   % adding the last few rows for a given column
            ylim = H;
        end
        if idx_x == floor(W/hor)    % adding the last few columns for given rows
            xlim = W;
        end
        
        patch = img((idx_y-1)*vert+1 : ylim , (idx_x-1)*hor+1 : xlim,:);                    % get a patch
        patch_gray = rgb2gray(patch);
        patch_bin = imbinarize(patch_gray,'global');
        [h, w] = size(patch_bin);
        
        % CLASS
        % A 1xN vector which specifies the initial labels of each of the N nodes in the graph
        class = reshape(patch_bin,1,[]);
        
        % UNARY (data)
        % A CxN matrix specifying the potentials (data term) for each of the C possible classes at each of the N nodes.
        dist_source =   reshape(mean(abs(double(patch) - source_colour),3),1,[]);
        dist_sink   =  	reshape(mean(abs(double(patch) - sink_colour),3),1,[]);
        unary = [dist_source ; dist_sink];
        
        % PAIRWISE (prior)
        % An NxN sparse matrix specifying the graph structure and cost for each link between nodes in the graph.
        hor_conn = sparse(ones(w*(h-1), 1));
        vert_conn = sparse(repmat([ones(w-1, 1); 0], h, 1));
        vert_conn = vert_conn(1:end-1);
        pairwise = diag(vert_conn, 1) + diag(hor_conn, w);
        pairwise = pairwise + pairwise';
        
        % LABELCOST
        % A CxC matrix specifying the fixed label cost for the labels of each adjacent node in the graph.
        labelcost = [0 1 ; 1 0] * lambda;
        
        % EXPANSION:: A 0-1 flag which determines if the swap or expansion method is used to solve the minimization.
        % 0 == swap, 1 == expansion. If ommitted, defaults to swap.
        [labels, ~, ~] = GCMex(double(class), single(unary), pairwise, single(labelcost),1);
        new_img_bin = reshape(labels,[h,w]);
        
        restored_img  = [];
        
        for i = 1:3
            c = zeros(h,w);
            c(new_img_bin == 0) = source_colour(:,:,i);
            c(new_img_bin == 1) = sink_colour(:,:,i);
            restored_img = cat(3,restored_img,c);
        end
        restored_patch = uint8(restored_img);
        cleaned_img((idx_y-1)*vert+1 : ylim , (idx_x-1)*hor+1 : xlim,:) = restored_patch;	% add patch to canvas
    end
end

figure(1); imshow(img); title('Original noisy image');
figure(2); imshow(cleaned_img); title(['Lambda = ', num2str(lambda),' , Patch size = ',num2str(vert),' x ',num2str(hor)]);

disp('Denoise done!');
toc

