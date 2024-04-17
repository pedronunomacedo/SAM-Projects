# Assuming you have a list of image paths in 'images_database'
# and a list of expected similar image paths in 'expected_images_database'
from src.scripts import script1_3
from src.utils.utils import calculate_precision_recall_f1_score

images_database = ['resources/coins.png', 'resources/yellowlily-segmented.png', 'resources/floresVermelhas.bmp', 'resources/casa2.jpg', 'resources/foggysf2.jpg', 'resources/hallway.jpg', 'resources/indiancorn.jpg', 'resources/lighthouse.png', 'resources/peppers.png', 'resources/toysflash.png']
expected_images_database = ['resources/yellowlily-segmented.png', 'resources/casa2.jpg', 'resources/parkavenue.jpg']

# Set the parameters for the evaluation
query_img_path = 'resources/car_1.jpg'
color_space = 'HSV'  # or 'LAB'
k = 5  # Number of top similar images to retrieve
distance_metric = 'euclidean_distance'  # or 'cosine_similarity', 'intersection_distance'

# Bin counts to test
bin_counts = [256, 128, 64, 32, 16, 8]

# Store the results
results = []

for num_bins in bin_counts:
    # Run the search and retrieve script
    returned_imgs_indexes = script1_3(
        query_img_path=query_img_path,
        images_database=images_database,
        color_space=color_space,
        k=k,
        distance_metric=distance_metric,
        num_bins=num_bins,
        debug=True
    )

    # Get the filenames of the returned images
    returned_imgs = [images_database[idx] for idx in returned_imgs_indexes]

    # Calculate precision, recall, and F1 score
    precision, recall, f1_score = calculate_precision_recall_f1_score(
        obtained_imgs=returned_imgs,
        expected_images=expected_images_database
    )

    # Save the results
    results.append({
        'num_bins': num_bins,
        'precision': precision,
        'recall': recall,
        'f1_score': f1_score
    })

# Print the results for each bin count
for result in results:
    print(f"Num bins: {result['num_bins']}, Precision: {result['precision']}, Recall: {result['recall']}, F1 Score: {result['f1_score']}")
