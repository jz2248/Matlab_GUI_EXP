function meanValue = getMeans(img,mask)
[length,width] = size(img);
count = 0;
total = 0;
for i = 1:length
    for j = 1:width
        if mask(i,j) == 1
            count = count + 1;
            total = double(img(i,j)) + total;
        end
    end
end
meanValue = total/count;