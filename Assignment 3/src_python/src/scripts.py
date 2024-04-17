import argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import cv2
import os
from utils.utils import calculate_euclidean_distance, calculate_cosine_similarity, calculate_intersection_distance, calculate_distance, calculate_precision_recall_f1_score

parser = argparse.ArgumentParser()
parser.add_argument('task', help="Task number")
parser.add_argument('-img', '--image', help="Image path")
parser.add_argument('-cs', '--colorspace', help="Color space", choices=['HSV', 'LAB'], default='HSV')
parser.add_argument('-img1', '--image1', help="1st image path")
parser.add_argument('-img2', '--image2', help="2nd image path")
parser.add_argument('-imgdb', '--images-database', help="Images database", nargs='*', default=[])
parser.add_argument('-topk', '--top-k', help="Top k images", type=int)
parser.add_argument('-distmet', '--distance-metric', help="Distance metric", choices=['euclidean_distance', 'cosine_similarity', 'intersection_distance'], default='euclidean_distance')
parser.add_argument('-expimgs', '--expected-images', help="Expected images", nargs='*', default=[])
parser.add_argument('-nbins', '--num-bins', help="Number of bins from 0 to 256", type=int, choices=range(0, 257), default=256)
parser.add_argument('-expimgdb', '--expected-images-database', help="Expected images database", nargs='*', default=[])
parser.add_argument('-d', '--debug', help="debug output images", action='store_true')


def script1_1(img_path, color_space, num_bins=256, debug=True):
    img = mpimg.imread(img_path)

    # Give me a plot that is 2 rows by 5 columns
    if debug : fig = plt.figure(figsize=(20, 8))

    # Create an array to store the images cells
    if debug : axs = [[_ for _ in range(5)] for _ in range(2)]
    components_histograms = []

    # Put the original figure in the cell (1,1)
    if debug:
        axs[0][0] = fig.add_subplot(2, 5, 1)
        axs[0][0].set_title('Original image')
        axs[0][0].imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))

    # Get the histogram of the original image
    if debug:
        axs[1][0] = fig.add_subplot(2, 5, 6)
        axs[1][0].set_title('Original histogram')

    hist = cv2.calcHist([cv2.cvtColor(img, cv2.COLOR_BGR2RGB)], [0], None, [num_bins], [0, 256]).flatten()

    if debug:
        axs[1][0].fill_between(range(len(hist)), hist, color='blue')
        if debug : axs[1][0].plot(hist, color='blue')

    # Check if the images is in grayscale
    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)

    # Convert the image into the color space specified by the user
    labels = []
    if color_space == 'HSV':
        img = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        labels = ['H (Hue)', 'S (Saturation)', 'V (Value)']
    elif color_space == 'LAB':
        img = cv2.cvtColor(img, cv2.COLOR_RGB2LAB)
        labels = ['L (Lightness)', 'A (Green-Red)', 'B (Blue-Yellow)']
    else:
        print("Invalid color space")
        return
    
    if debug: 
        axs[0][1] = fig.add_subplot(2, 5, 2)
        axs[0][1].set_title(f'{color_space} image')
        axs[0][1].imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))

    # Get the images and the histograms of each component of the color space selected
    if debug: 
        axs[0][2] = fig.add_subplot(2, 5, 3)
        axs[0][2].set_title('H component')
        axs[0][2].set_title(f"Channel {labels[0]}")
        axs[0][2].imshow(img[:,:,0], cmap='gray')

    for i in range(img.shape[2]):
        if debug: 
            axs[0][2+i] = fig.add_subplot(2, 5, 3+i)
            axs[0][2+i].set_title(f"Channel {labels[i]}")
            axs[0][2+i].imshow(img[:,:,i], cmap='gray')

        if debug:
            axs[1][2+i] = fig.add_subplot(2, 5, 8+i)
            axs[1][2+i].set_title(f'{color_space} channel {i} histogram')
        
        hist_component = cv2.calcHist([img[:, :, i]], [0], None, [num_bins], [0, 256]).flatten()
        components_histograms.append(hist_component)

        if debug:
            axs[1][2+i].fill_between(range(len(hist_component)), hist_component, color='blue')
            axs[1][2+i].plot(hist_component, color='blue')


    # Get the histogram of the concatenated components
    hist_concatenate = np.concatenate(components_histograms).flatten()
    if debug:
        axs[1][1] = fig.add_subplot(2, 5, 7)
        axs[1][1].fill_between(range(len(hist_concatenate)), hist_concatenate, color='blue')
        axs[1][1].set_title(f'{color_space} histogram')
        axs[1][1].plot(hist_concatenate, color='blue')

    # Show the final result
    if debug:
        plt.tight_layout()
        plt.show()

    return hist_concatenate

def script1_2(img1_path, img2_path, color_space, debug=True):
    """
    Generates concatenated vectors with color histograms for pairs of images and compares those vectors, evaluating their distance and thus the similarity of images. Whenever it finds that the images
    are similar it displays them side-by-side. Use different similarity metrics such as Euclidean distance,
    cosine similarity or intersection distance.
    """

    original_img1 = mpimg.imread(img1_path)
    original_img2 = mpimg.imread(img2_path)
    
    # Get the histograms of the images
    hist1 = script1_1(img_path=img1_path, color_space=color_space, debug=False)
    hist2 = script1_1(img_path=img2_path, color_space=color_space, debug=False)

    normalized_hist1 = hist1 / sum(hist1)
    normalized_hist2 = hist2 / sum(hist2)

    # Calculate the similarity between the histograms
    euclidean_distance = calculate_euclidean_distance(normalized_hist1, normalized_hist2)
    cosine_similarity = calculate_cosine_similarity(hist1, hist2)
    intersection_distance = calculate_intersection_distance(hist1, hist2)

    # You will need to establish a threshold to take the decision between similar/dissimilar. Run the script with different images and different options for the color space and comment on the results.
    threshold = 0.5
    if euclidean_distance < threshold and cosine_similarity > threshold and intersection_distance > threshold:
        print("Conclusion: The images are similar\n")
        if debug : 
            fig, axs = plt.subplots(1, 2, figsize=(10, 5))
            axs[0].imshow(cv2.cvtColor(original_img1, cv2.COLOR_BGR2RGB))
            axs[0].set_title(f'Image 1 in {color_space}')
            axs[1].imshow(cv2.cvtColor(original_img2, cv2.COLOR_BGR2RGB))
            axs[1].set_title(f'Image 2 in {color_space}')
            plt.show()
    else:
        print("Conclusion: The images are dissimilar\n")



    print(f"Euclidean distance: {euclidean_distance}")
    print(f"Cosine similarity: {cosine_similarity}")
    print(f"Intersection distance: {intersection_distance}")



def script1_3(query_img_path, images_database, color_space, k, distance_metric, num_bins=256, debug=True):
    """
    developing a “searchAndRetrieve”” function, which receives one reference/query image and an
    array of candidate images (“image database”). This function should return the top_k most similar
    images to the query image, indicated by their index in the array.
    """

    # Get the histogram of the query image
    query_hist = script1_1(img_path=query_img_path, color_space=color_space, num_bins=num_bins, debug=debug)
    query_hist = query_hist / sum(query_hist) # normalize the histogram

    # Get the histograms of the candidate images
    candidate_histograms = []
    for idx, img_path in enumerate(images_database):
        filename = os.path.basename(img_path)
        candidate_histograms.append((idx, filename, script1_1(img_path=img_path, color_space=color_space, num_bins=num_bins, debug=debug)))

    # Calculate the similarity between the histograms
    distances = []
    for idx, filename, candidate_histogram in candidate_histograms:
        distances.append((idx, filename, calculate_distance(query_hist, candidate_histogram, distance_metric)))

    if distance_metric == 'euclidean_distance':
        distances.sort(key=lambda x: x[2], reverse=False)
    elif distance_metric == 'cosine_similarity' or distance_metric == 'intersection_distance':
        distances.sort(key=lambda x: x[2], reverse=True)

    if debug:
        print("distances: ", distances)
    
    return [item[0] for item in distances[:k]] # Only return the images 

def script1_4(query_img_path, images_database, expected_images, color_space, k, distance_metric, num_bins=256, debug=True):
    """
    evaluate the performance of the comparison algorithm by computing the values of Precision, Recall
    and F1 score (after running the algorithm several times with different images). Based on the ob-
    tained results, re-run the algorithm manipulating the resolution of the histogram (number of bins
    used when generating the histograms) and the value of the threshold. Recall that in a RGB image
    (bmp or png) each color channel is represented with 8 bits, thus the full resolution histogram will
    have 256 possible bins (see slides “challengesMMstorageRetrieval”).
    """

    # Call the algorithmfor the color space specified
    returned_imgs_indexes = script1_3(query_img_path=query_img_path, images_database=images_database, color_space=color_space, k=k, distance_metric=distance_metric, num_bins=num_bins, debug=debug)

    # Get the images from the indexes returned in script1_3
    returned_imgs = [images_database[idx] for idx in returned_imgs_indexes]

    # Calculate the precision, recall and F1 score
    precision, recall, f1_score = calculate_precision_recall_f1_score(obtained_imgs=returned_imgs, expected_images=expected_images)

    if debug:
        print(f"Precision: {precision}")
        print(f"Recall: {recall}")
        print(f"F1 score: {f1_score}")

def script_2(img1_path, img2_path, color_space, debug=True):
    # Load images
    img1 = cv2.imread(img1_path)
    img2 = cv2.imread(img2_path)

    # Convert images to grayscale
    img1_gray = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
    img2_gray = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

    # Initialize SIFT detector
    sift = cv2.SIFT_create()

    # Detect SIFT features and compute descriptors.
    keypoints_1, descriptors_1 = sift.detectAndCompute(img1_gray, None)
    keypoints_2, descriptors_2 = sift.detectAndCompute(img2_gray, None)

    # Initialize Brute Force Matcher
    bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)

    # Match descriptors
    matches = bf.match(descriptors_1, descriptors_2)

    # Sort them in the order of their distance (lower distance is better)
    matches = sorted(matches, key=lambda x: x.distance)

    # Compute the average distance of the top 30 matches
    if len(matches) > 30:
        selected_matches = matches[:30]
    else:
        selected_matches = matches

    # Draw first 30 matches.
    img_matches = cv2.drawMatches(img1, keypoints_1, img2, keypoints_2, selected_matches, None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)

    

    # Display the resulting frame
    plt.imshow(cv2.cvtColor(img_matches, cv2.COLOR_BGR2RGB))
    plt.title(f'Average Distance: {average_distance:.2f}')
    plt.show()

    print("average_distance: ", average_distance)


if __name__ == '__main__':
    args = parser.parse_args()
    if args.task == '1.1':
        script1_1(img_path=args.image, color_space=args.colorspace, debug=args.debug)
    elif args.task == '1.2':
        script1_2(img1_path=args.image1, img2_path=args.image2, color_space=args.colorspace, debug=args.debug)
    elif args.task == '1.3':
        print(script1_3(query_img_path=args.image, images_database=args.images_database, color_space=args.colorspace, k=args.top_k, distance_metric=args.distance_metric, debug=args.debug))
    elif args.task == '1.4':
        script1_4(query_img_path=args.image, images_database=args.images_database, expected_images=args.expected_images_database, color_space=args.colorspace, k=args.top_k, distance_metric=args.distance_metric, num_bins=args.num_bins, debug=args.debug)
    elif args.task == '2':
        script_2(img1_path=args.image1, img2_path=args.image2, color_space=args.colorspace, debug=args.debug)
    else:
        print("Invalid task number")
