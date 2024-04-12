import argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import cv2
import math

parser = argparse.ArgumentParser()
parser.add_argument('task', help="Task number")
parser.add_argument('-img', '--image', help="Image path")
parser.add_argument('-cs', '--colorspace', help="Color space", choices=['HSV', 'LAB'], default='HSV')
parser.add_argument('-img1', '--image1', help="1st image path")
parser.add_argument('-img2', '--image2', help="2nd image path")
parser.add_argument('-d', '--debug', help="debug output images",type=bool, choices=[True, False], default=True)


def script1_1(img_path, color_space, debug=True):
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

    hist = cv2.calcHist([cv2.cvtColor(img, cv2.COLOR_BGR2RGB)], [0], None, [256], [0, 256]).flatten()

    if debug:
        axs[1][0].fill_between(range(len(hist)), hist, color='blue')
        if debug : axs[1][0].plot(hist, color='blue')

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
        
        hist_component = cv2.calcHist([img[:, :, i]], [0], None, [256], [0, 256]).flatten()
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

    img1 = mpimg.imread(img1_path)
    img2 = mpimg.imread(img2_path)

    # Convert the images to the same color space
    if color_space == 'HSV':
        img1 = cv2.cvtColor(img1, cv2.COLOR_RGB2HSV)
        img2 = cv2.cvtColor(img2, cv2.COLOR_RGB2HSV)
    elif color_space == 'LAB':
        img1 = cv2.cvtColor(img1, cv2.COLOR_RGB2LAB)
        img2 = cv2.cvtColor(img2, cv2.COLOR_RGB2LAB)
    else:
        print("Invalid color space")
        return
    
    # Get the histograms of the images
    hist1 = script1_1(img1_path, color_space, True)
    hist2 = script1_1(img2_path, color_space, False)

    normalized_hist1 = hist1 / sum(hist1)
    normalized_hist2 = hist2 / sum(hist2)

    # Calculate the similarity between the histograms
    euclidean_distance = np.linalg.norm(normalized_hist1 - normalized_hist2)
    cosine_similarity = np.dot(hist1, hist2) / (np.linalg.norm(hist1) * np.linalg.norm(hist2))
    intersection_distance = np.sum(np.minimum(normalized_hist1, normalized_hist2))

    # You will need to establish a threshold to take the decision between similar/dissimilar. Run the script with different images and different options for the color space and comment on the results.
    threshold = 0.5
    if euclidean_distance < threshold and cosine_similarity > threshold and intersection_distance > threshold:
        if debug : 
            fig, axs = plt.subplots(1, 2, figsize=(10, 5))
            axs[0].imshow(cv2.cvtColor(img1, cv2.COLOR_BGR2RGB))
            axs[0].set_title(f'Image 1 in {color_space}')
            axs[1].imshow(cv2.cvtColor(img2, cv2.COLOR_BGR2RGB))
            axs[1].set_title(f'Image 2 in {color_space}')
            plt.show()
    else:
        print("Conclusion: The images are dissimilar")



    print(f"Euclidean distance: {euclidean_distance}")
    print(f"Cosine similarity: {cosine_similarity}")
    print(f"Intersection distance: {intersection_distance}")



if __name__ == '__main__':
    args = parser.parse_args()
    if args.task == '1.1':
        print(script1_1(args.image, args.colorspace))
    elif args.task == '1.2':
        script1_2(args.image1, args.image2, args.colorspace, args.debug)
        pass
    else:
        print("Invalid task number")
