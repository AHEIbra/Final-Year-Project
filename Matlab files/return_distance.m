function conv_row = return_distance(rowcol)
conv_row = [  ];

%%%% [ROW, COLUMN]
if rowcol == [1 1] %1
    conv_row = [1 1];
end
if rowcol == [1 2] %2
    conv_row = [1 3];
end
if rowcol == [1 3] %3
    conv_row = [1 5];
end
if rowcol == [1 4] %4
    conv_row = [1 7];
end
if rowcol == [1 5] %5
    conv_row = [1 9];
end
if rowcol == [2 5] %6
    conv_row = [3 9];
end
if rowcol == [3 5] %7
    conv_row = [5 9];
end
if rowcol == [3 4] %8
    conv_row = [5 7];
end
if rowcol == [3 3] %9
    conv_row = [5 5];
end
if rowcol == [2 3] %10
    conv_row = [3 5];
end
if rowcol == [3 2] %11
    conv_row = [5 3];
end
if rowcol == [3 1] %12
    conv_row = [5 1];
end 
if rowcol == [2 1] %13
    conv_row = [3 1];
end
end