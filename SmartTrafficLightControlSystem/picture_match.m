function [total_matched_percentage]=picture_match(pic1,pic2)
[x,y] = size(pic1);
[x,y] = size(pic2);
%applying edge detection on first and seecond picture
%so that we obtain white and black points and edges of the objects present
%in the picture.
edge_det_pic1 = edge(pic1,'sobel');
edge_det_pic2 = edge(pic2,'sobel');
%defining different variables which are to be used in the code below

matched_data = 0;
white_points = 0;
black_points = 0;
x=0;
y=0;
l=0;
m=0;
%detecting black and white points in the picture.
for a = 1:1:256
    for b = 1:1:256
        if(edge_det_pic1(a,b)==1)
            white_points = white_points+1;
        else
            black_points = black_points+1;
        end
    end
end
%comparing the edge points in the two pictures
for i = 1:1:256
    for j = 1:1:256
        if(edge_det_pic1(i,j)==1)&(edge_det_pic2(i,j)==1)
            matched_data = matched_data+1;
            else
                ;
        end
    end
end
    
%calculating percentage matching.
total_data = white_points;
total_matched_percentage = (matched_data/total_data)*100;
%outputting the result of the system.
end