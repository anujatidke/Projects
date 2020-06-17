clc
clear all
close all
bg=imresize(rgb2gray(imread("mumbai low.jpeg")),[300 300]);
fg=imresize(rgb2gray(imread("mumbai high.jpg")),[300 300]);
edge_bg=canny_edge(bg);
edge_fg=canny_edge(fg);
matchpercent=picture_match(bg,fg)
message1='RED for 90sec';
message2='Green for 20 sec';
message3='Green for 30 sec';
message4='Green for 60 sec';
message5='Green for 90 sec';
if matchpercent>= 90          %can add flexability at this point by reducing the amount of matching.
   message1
elseif matchpercent<=90 & matchpercent>70
    message2
elseif matchpercent<=70 & matchpercent>50
    message3
elseif matchpercent<=50 & matchpercent>10
    message4
else
    message5
end