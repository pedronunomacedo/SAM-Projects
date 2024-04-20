import numpy as np
from scipy.spatial import distance

def calculate_distance(query_hist, candidate_hist, metric):
    """
    Calculate the distance between two histograms
    """
    if metric == 'euclidean_distance':
        normalized_query_hist = query_hist / sum(query_hist)
        normalized_candidate_hist = candidate_hist / sum(candidate_hist)
        return calculate_euclidean_distance(normalized_query_hist, normalized_candidate_hist)
    elif metric == 'cosine_similarity':
        return calculate_cosine_similarity(query_hist, candidate_hist)
    elif metric == 'intersection_distance':
        normalized_query_hist = query_hist / sum(query_hist)
        normalized_candidate_hist = candidate_hist / sum(candidate_hist)
        return calculate_intersection_distance(normalized_query_hist, normalized_candidate_hist)
    else:
        raise ValueError(f"Invalid distance metric '{metric}'")
    
def calculate_euclidean_distance(hist1, hist2):
    return np.linalg.norm(hist1 - hist2)

def calculate_cosine_similarity(hist1, hist2):
    return np.dot(hist1, hist2) / (np.linalg.norm(hist1) * np.linalg.norm(hist2))

def calculate_intersection_distance(hist1, hist2):
    intersection = np.sum(np.minimum(hist1, hist2))
    maximum_intersection = np.minimum(np.sum(hist1), np.sum(hist2))  # Maximum possible intersection
    normalized_intersection_distance = 1 - (intersection / maximum_intersection)
    return normalized_intersection_distance

def calculate_distances(matches, descriptors_1, descriptors_2):
    # Euclidean distances
    euclidean_distances = [np.linalg.norm(descriptors_1[m.queryIdx] - descriptors_2[m.trainIdx]) for m in matches]

    # Cosine similarities
    cosine_similarities = [1 - distance.cosine(descriptors_1[m.queryIdx], descriptors_2[m.trainIdx]) for m in matches]

    # Intersection distances (using histograms or simple min vector operation)
    intersection_distances = [np.sum(np.minimum(descriptors_1[m.queryIdx], descriptors_2[m.trainIdx])) for m in matches]

    return euclidean_distances, cosine_similarities, intersection_distances



def calculate_precision_recall_f1_score(obtained_imgs, expected_images):
    # True positives (TP): Obtained images that are correctly identified as similar
    true_positives = set(obtained_imgs).intersection(set(expected_images))
    
    # False positives (FP): Obtained images that are incorrectly identified as similar
    false_positives = set(obtained_imgs) - set(expected_images)
    
    # False negatives (FN): Expected images that are not identified as similar
    false_negatives = set(expected_images) - set(obtained_imgs)

    precision = len(true_positives) / (len(true_positives) + len(false_positives)) if (len(true_positives) + len(false_positives)) > 0 else 0
    recall = len(true_positives) / (len(true_positives) + len(false_negatives)) if (len(true_positives) + len(false_negatives)) > 0 else 0
    f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0

    return precision, recall, f1_score