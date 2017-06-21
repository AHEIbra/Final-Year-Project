function loc_mat_graph = return_distance_coordinate(location)
loc_mat_graph = [  ];

%%%% [ROW, COLUMN]
if location == 1
    loc_mat_graph = [1 1];
end
if location == 2
    loc_mat_graph = [1 3];
end
if location == 3
    loc_mat_graph = [1 5];
end
if location == 4
    loc_mat_graph = [1 7];
end
if location == 5
    loc_mat_graph = [1 9];
end
if location == 6
    loc_mat_graph = [3 9];
end
if location == 7
    loc_mat_graph = [5 9];
end
if location == 8
    loc_mat_graph = [5 7];
end
if location == 9
    loc_mat_graph = [5 5];
end
if location == 10
    loc_mat_graph = [3 5];
end
if location == 11
    loc_mat_graph = [5 3];
end
if location == 12
    loc_mat_graph = [5 1];
end 
if location == 13
    loc_mat_graph = [3 1];
end
end