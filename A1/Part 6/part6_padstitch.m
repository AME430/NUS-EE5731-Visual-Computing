function [output,stitched] = part6_padstitch(displacement,img1,img2_T)
h1 = size(img1,1);          % vertical y axis,
len1 = size(img1,2);          % horizontal x axis
h2 = size(img2_T,1);
len2 = size(img2_T,2);
x_d = displacement(1,1);
y_d = displacement(2,1);


if y_d < 0             
    output2 = cat(1,zeros(abs(y_d),len2,3),img2_T,zeros(h1-h2+y_d,len2,3));  	% add rows
    if size(output2,1) ~= size(img1,1)
        output = cat(1,img1,zeros(abs(h1-h2+y_d),size(img1,2),3));
    else
        output = img1;
    end
    if x_d > 0          % negative y, positive x %%%% not done
        output2 = cat(2,zeros(size(output2,1),x_d,3),output2);                                  % add cols
        output = cat(2,img2_T,zeros(size(img2_T,1),size(output2,2)-size(img2_T,2),3));          % finish padding
    else                % negative y, negative x
        output2 = cat(2,zeros(size(output2,1),abs(x_d),3),output2);                             % add cols
        output = cat(2,img1,zeros(size(img1,1),size(output2,2)-size(img1,2),3));                                % finish padding        
    end
end

if y_d > 0              
    output2 = cat(1,zeros(y_d,len1,3),img1,zeros(size(img2_T,1)-h1-y_d,len1,3));  	% add rows
    if x_d > 0          % positve y, positive x
        output2 = cat(2,zeros(size(output2,1),x_d,3),output2);                                  % add cols
        output = cat(2,img2_T,zeros(size(img2_T,1),size(output2,2)-size(img2_T,2),3));          % finish padding
    else                % positve y, negative x
        output = cat(2,zeros(size(img2_T,1),abs(x_d),3),img2_T);                                % add cols
        output2 = cat(2,output2,zeros(size(output2,1),size(output,2)-size(output2,2),3));       % finish padding
    end
end
disp(size(output));
disp(size(output2));
stitched = max(output,output2);
figure; imshow(stitched); title("Part 6: RANSAC homography and stitching");

end

