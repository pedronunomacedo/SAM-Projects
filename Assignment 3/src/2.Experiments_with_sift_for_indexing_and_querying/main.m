function main(image_path)
    clc;
    image = imread(image_path);
    image = rgb2gray(image);
    image = double(image);
    keyPoints = SIFT(image,3,5,1.3);
    image = SIFTKeypointVisualizer(image,keyPoints);
    imshow(uint8(image))
end