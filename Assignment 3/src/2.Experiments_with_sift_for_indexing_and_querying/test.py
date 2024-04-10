import cv2 
import numpy as np
from scipy.spatial.distance import cosine

def calculate_cosine_similarity(descriptor1, descriptor2):
    return 1 - cosine(descriptor1, descriptor2)

def euclidean_distance(descriptor1, descriptor2):
    return np.linalg.norm(descriptor1 - descriptor2)

def intersection_distance(vectors):
    return np.sum([np.minimum(a, b) for a, b in vectors])

#sift
sift = cv2.SIFT_create()

#feature matching
bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)


img1 = cv2.imread('../resources/car_1.jpg')  
img2 = cv2.imread('../resources/car_2.jpg') 

img1 = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
img2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

keypoints_1, descriptors_1 = sift.detectAndCompute(img1,None)
keypoints_2, descriptors_2 = sift.detectAndCompute(img2,None)

matches = bf.match(descriptors_1,descriptors_2)
matches = sorted(matches, key = lambda x:x.distance)

img3 = cv2.drawMatches(img1, keypoints_1, img2, keypoints_2, matches[:600], img2, flags=2)

cv2.imshow('SIFT', img3)

# Calculate Euclidean distance for all matches manually
euclidean_distances = [
    euclidean_distance(descriptors_1[match.queryIdx], descriptors_2[match.trainIdx])
    for match in matches
]
average_euclidean_distance = np.mean(euclidean_distances) # Average Euclidean distance

# Calculate cosine similarity for all matches
cosine_similarities = [
    calculate_cosine_similarity(descriptors_1[match.queryIdx], descriptors_2[match.trainIdx])
    for match in matches
]
average_cosine_similarity = np.mean(cosine_similarities) # Average cosine similarity

# Calculate the intersection distance for all matches
matched_vectors = [
    (descriptors_1[m.queryIdx], descriptors_2[m.trainIdx]) 
    for m in matches 
    if np.any(descriptors_1[m.queryIdx]) and np.any(descriptors_2[m.trainIdx])
]
average_intersection_distance = intersection_distance(matched_vectors) / len(matches)
total_descriptor_sum = sum([sum(np.maximum(a, b)) for a, b in matched_vectors]) # Total sum of descriptor values for normalization
# Normalize the average intersection distance
normalized_average_intersection_distance = 0
if total_descriptor_sum > 0:
    normalized_average_intersection_distance = average_intersection_distance / (total_descriptor_sum / len(matches))


# Output the results
print("Average Euclidean Distance (manually calculated): ", average_euclidean_distance)
print("Average Cosine Similarity: ", average_cosine_similarity)
print("Average Intersection Distance: ", normalized_average_intersection_distance)

cv2.waitKey(0)