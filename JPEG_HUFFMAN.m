%%% JPEG Encoder %%%%
clc; clear all; close all;
img = imread('blueberries.jpg');
img = rgb2gray(img);

[x,y] = size(img);
blocksize=8;
if rem(x,8)~= 0
    img = padarray(img,[8-rem(x,8) 0],0,'post');
end
if rem(y,8)~= 0
    img = padarray(img,[0 8-rem(y,8)],0,'post');
end
all_zz = [];
block_idx = 1;
for i = 1:blocksize:x
    for j = 1:blocksize:y
        block = img(i:i+blocksize-1,j:j+blocksize-1);
        block = double(block);
        block = block-128;
        dct = dct2(block);
        Q_table = [16 11 10 16 24 40 51 61;
           12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;
           14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;
           24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101;
           72 92 95 98 112 100 103 99];
         Quantized_value = round(dct/Q_table);
         zz = zigzag(Quantized_value);
         all_zz(block_idx, :) = zz;     % Store as a row
         block_idx = block_idx + 1;
    end
end

zz_vector = all_zz(:);  

symbols = unique(zz_vector);
prob = histc(zz_vector, symbols) / numel(zz_vector);

dict = huffmandict(symbols, prob);

% Encode using Huffman coding
huff_encoded = huffmanenco(zz_vector, dict);
s = size(huff_encoded);
disp(s)
figure;
imshow(img);

function zz = zigzag(block);   
zigzag_order = [1 2 6 7 15 16 28 29;
                 3 5 8 14 17 27 30 43;
                 4 9 13 18 26 31 42 44;
                 10 12 19 25 32 41 45 54;
                 11 20 24 33 40 46 53 55;
                 21 23 34 39 47 52 56 61;
                 22 35 38 48 51 57 60 62;
                 36 37 49 50 58 59 63 64]; 
zz = zeros(1,64);
for i = 1:8
    for j = 1:8
        zz(zigzag_order(i,j)) = block(i,j); %Flatten the block into a 1D array using the zigzag pattern
    end
end
end
