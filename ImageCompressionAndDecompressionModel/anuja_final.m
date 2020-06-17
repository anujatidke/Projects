clear all;
close all;
quant_multiple = input('add the level of compression');%accepting level of compression from user
folder='MATLAB Drive/*.jpeg';%add the path here 
ext='*.jpeg' ; %the image extension
[filename, path] = uigetfile(fullfile(folder,ext)) ;%opens a dialog box that lists files in the current folder
original_image = imread(fullfile(path, filename));%reading the image
imshow(original_image);%display the image


display('Compressing the image...');
display('Please wait...');
original_image=rgb2ycbcr(original_image);%converting rgb to Y, Cb and Cr components;
original_image=original_image(:,:, 1);%uint8 is converted into range of Y [16, 235]




% ------------or replace line 4 and 5 by --------------
%       original_image=rgb2gray(original_image);
% -----------------------------------------------------
original_image=original_image-128;%level off by 128

blocksize=8;%taking a blocksize of 8
resized_image=imresize(original_image,[512 512]);%resizing the image 
resized_image=im2double(resized_image);%making the values double
[rows cols]=size(original_image);
imwrite(resized_image,'real.jpeg');


%-----------------Function for DCT MATRIX--------------%
i = 0;
for j = 0:blocksize-1
  DCT_transpose(i+1,j+1)=sqrt(1/ blocksize)*cos((2*j+1)*i*pi/(2*blocksize));
end
 
for i = 1:blocksize-1
  for j = 0:blocksize-1
    DCT_transpose(i+1,j+1) = sqrt(2/blocksize)*cos((2*j+1)*i*pi/(2*blocksize));
  end
end
%------------------Function for DCT MATRIX ENDS---------%




%-------------------Step 6-------------------------------%
dct_matrix = @(block_struct) DCT_transpose * block_struct.data * DCT_transpose';%D=T*(Image)*T; function to compress the image
resultant_dct_matrix = blockproc(resized_image,[8 8],dct_matrix);%applying above function for 8x8 matrix of resized image and store the result in resultant_matrix

%--------------------Step 6 ends--------------------------%





%-----------------Quantization of image--------------------%



quant_multiple=0.05*10/quant_multiple;

DCT_quantizer = [ 16 11 10 16 24 40 51 61;            %quantization matrix
12 12 14 19 26 58 60 55;
14 13 16 24 40 57 69 56; 
14 17 22 29 51 87 80 62;
18 22 37 56 68 109 103 77;
24 35 55  64 81 104 113 92;
49 64 78 87 103 121 120 101;
72 92 95 98 112 100 103 99 ];



quant_func= @(block_struct)((block_struct.data) ./ (DCT_quantizer* quant_multiple)+0.5); %Declaring Quantization function
quantized_image = blockproc(resultant_dct_matrix,[8 8],quant_func);%Applying above function for each 8x8 matrix of resultant_dct_matrix and store result in quantization_image
%Process the image, block-by-block.
quantized_image = floor(quantized_image);%applying func floor (to round off to the lowest) to quantized_image
figure,imshow(quantized_image);%displaying quantized_image
imwrite(quantized_image,' Compressed.jpeg');%storing the quantized_image in Compressed.jpeg
display('Compression completed!!!');


%------------------End of Quantization------------------%


%-------------------Compression is Done-----------------------%



%-----------------------Decompression of Image-------------------%
display('Decompressing the image for you...');
display('Please wait....');
reconstructed_matrix= blockproc(quantized_image,[8 8],@(block_struct)DCT_quantizer.*block_struct.data); %reconstruction of matrix
inverse_dct = @(block_struct)ceil(DCT_transpose' * block_struct.data * DCT_transpose);     %Inverse DCT   inv_D=T'*(Image)*T
decompressed_image = blockproc(reconstructed_matrix,[8 8],inverse_dct);%applying the above function for 8x8 to reconstructed_mattrix
decompressed_image=decompressed_image+128;
figure, imagesc(decompressed_image), colormap gray;
imwrite(decompressed_image,'decompressed Image.jpeg');%storing the decompressed image in Decompressed.jpeg
imresize(decompressed_image,[rows cols]);
display('Compression and Decompression Successfull');
display('Please check the "Quantization.jpeg" & "Decompressed.jpeg" in your folder');





%Plot 2D DFT magnitude spectrum of original signal
fs = 1000;
t = 0:1/fs:1-(1/fs);
X1 = fftshift(fft(original_image));
X1 = abs(X1);
figure,plot(X1/fs);
title('Magnitude Spectrum of original signal');
 
X2=fftshift(fft(decompressed_image));
X2=abs(X2);

figure ,plot(X2/fs);
title('Magnitude Spectrum of reconstructed image signal');




fprintf(1, 'Finding the signal-to-noise ratio...\n');
 
 
PSNR=0;
for row=1:rows
  for col=1:cols
    PSNR=PSNR+(resized_image(row,col)-decompressed_image(row,col))^2;
  end
end
X=(255^2)/(1/(((rows+cols)/2)^2)*PSNR);
PSNR=log10(X);
fprintf(1,'\nThe signal-to-noise ratio (PSNR) for one half of the coefficient to be zero is: %1.3f dB\n\n', PSNR);



