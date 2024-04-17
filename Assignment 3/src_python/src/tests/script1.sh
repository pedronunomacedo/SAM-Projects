# Test the script 1 for question 1.1
python scripts.py 1.1 -img ../resources/car_1.jpg -cs HSV

# Test the script 3 for question 1.3
python3 scripts.py 1.3 -img ../resources/car_1.jpg -imgdb ../resources/car_2.jpg ../resources/casa1.jpg ../resources/car_3.jpg -cs HSV -topk 2 -distmet euclidean_distance -d

# Test the script 4 for question 1.4
python3 scripts.py 1.4 -img ../resources/floresVermelhas.bmp -imgdb ../resources/elephant.bmp ../resources/folhasVerdes.bmp ../resources/lena_gray.bmp ../resources/lena.bmp ../resources/nenufares.bmp ../resources/testRGB.bmp -expimgdb ../resources/lena.bmp -cs HSV -topk 3 -distmet euclidean_distance -d
python3 scripts.py 1.4 -img ../resources/folhasVerdes.bmp -imgdb ../resources/forest.bmp ../resources/greens.bmp ../resources/lena.bmp ../resources/nenufares.bmp  -expimgdb ../resources/nenufares.bmp ../resources/forest.bm -cs HSV -topk 2 -distmet euclidean_distance -d
python3 scripts.py 1.4 -img ../resources/folhasVerdes.bmp -imgdb ../resources/forest.bmp ../resources/greens.bmp ../resources/lena.bmp ../resources/nenufares.bmp ../resources/peacock.bmp  -expimgdb ../resources/nenufares.bmp ../resources/forest.bm ../resources/peacock.bmp -cs HSV -topk 3 -distmet euclidean_distance -d