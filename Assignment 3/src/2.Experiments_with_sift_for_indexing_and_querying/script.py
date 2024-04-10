import cv2 
import matplotlib.pyplot as plt
import numpy as np
from scipy.spatial import distance

def euclidean_distance(vectors):
    return np.sum([np.linalg.norm(a - b) for a, b in vectors])

def cosine_similarity(vectors):
    similarities = [1 - distance.cosine(a, b) for a, b in vectors if np.any(a) and np.any(b)]
    return np.mean(similarities) if similarities else 0

def intersection_distance(vectors):
    return np.sum([np.minimum(a, b) for a, b in vectors])

def calculate_histogram(image, mask=None, bins=256, hist_range=(0, 256)):
    # Calculate the histogram for each color channel
    histogram = [cv2.calcHist([image], [i], mask, [bins], hist_range) for i in range(3)]
    # Concatenate the histograms into a single feature vector
    histogram = np.concatenate(histogram).flatten()
    return histogram



# read images
img1 = cv2.imread('../resources/car_1.jpg')  
img2 = cv2.imread('../resources/car_2.jpg') 

# Calculate color histograms for both images
hist1 = calculate_histogram(img1)
hist2 = calculate_histogram(img2)

# Convert images to grayscale
img1 = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
img2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

# SIFT algorithm
sift = cv2.SIFT_create()
keypoints_1, descriptors_1 = sift.detectAndCompute(img1, None)
keypoints_2, descriptors_2 = sift.detectAndCompute(img2, None)

# Feature matching with SIFT descriptors
bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)
matches = bf.match(descriptors_1, descriptors_2)
matches = sorted(matches, key = lambda x: x.distance)

# Draw the matches
img3 = cv2.drawMatches(img1, keypoints_1, img2, keypoints_2, matches[300:600], img2, flags=2)

# # Concatenate color histograms with SIFT descriptors
# matched_vectors = [
#     (descriptors_1[m.queryIdx], descriptors_2[m.trainIdx]) 
#     for m in matches 
#     if np.any(descriptors_1[m.queryIdx]) and np.any(descriptors_2[m.trainIdx])
# ]


# # Calculate similarity metrics
# euclidean_dist = euclidean_distance(matched_vectors) / len(matches)
# cosine_sim = cosine_similarity(matched_vectors)
# intersection_dist = intersection_distance(matched_vectors) / len(matches)

# # Calculate the thresholds
# euclidean_threshold = np.sqrt(len(matched_vectors[0][0])) * 0.1  # 10% of the max possible distance
# cosine_threshold = 0.8  # Indicates vectors are closely aligned
# intersection_threshold = 0.5 * np.sum([np.maximum(a, b) for a, b in matched_vectors])  # 50% intersection

# print(f"Euclidean distance (lower is more similar): {euclidean_dist}")
# print(f"Cosine similarity (higher is more similar): {cosine_sim}")
# print(f"Intersection distance (higher is more similar): {intersection_dist}")

# print(f"Euclidean threshold: {euclidean_threshold}")
# print(f"Cosine threshold: {cosine_threshold}")
# print(f"Intersection threshold: {intersection_threshold}")


# # Display the images side by side if they are similar based on a threshold
# # Define the threshold for deciding if images are similar (this needs to be tuned)

# similar_images = False
# if euclidean_dist < euclidean_threshold:
#     # Concatenate images horizontally
#     similar_images = True
#     images_side_by_side = np.concatenate((img1, img2), axis=1)
#     plt.imshow(cv2.cvtColor(images_side_by_side, cv2.COLOR_BGR2RGB))
#     plt.title('Similar images (in euclidian distance)')
# if cosine_sim > cosine_threshold:
#     # Concatenate images horizontally
#     similar_images = True
#     images_side_by_side = np.concatenate((img1, img2), axis=1)
#     plt.imshow(cv2.cvtColor(images_side_by_side, cv2.COLOR_BGR2RGB))
#     plt.title('Similar images (in cosine similarity)')
# if intersection_dist > intersection_threshold:
#     # Concatenate images horizontally
#     similar_images = True
#     images_side_by_side = np.concatenate((img1, img2), axis=1)
#     plt.imshow(cv2.cvtColor(images_side_by_side, cv2.COLOR_BGR2RGB))
#     plt.title('Similar images (in intersection distance)')


cv2.imshow('SIFT', img3)

# if not similar_images:
#     plt.title('Images are not similar (neither in Euclidian distance, cosine similarity nor intersection distance)')

cv2.waitKey(0)