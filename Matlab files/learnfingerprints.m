function all_fgps = learnfingerprints(offline_db)
A = load(offline_db);

A = struct2cell(A);
A = A{1};

unique_locations = unique(A.Location);

all_location = [];
all_macs = {};
all_meanRSSI = [];
all_varRSSI = [];

for i = 1:length(unique_locations)
    % Grab all the rows where the location is
    B = A( A.Location==unique_locations(i) , : );

    % Get the list of all mac addresses
    mac_list = unique(B.BSSID);
    num_of_macs = size(mac_list,1);
    
    all_location = [all_location; unique_locations(i)*ones(num_of_macs,1)];
    all_macs = [all_macs; mac_list];
    
    % Initialise vector for mean-rssi and var-rssi
    meanRSSI = zeros(num_of_macs,1);
    varRSSI = zeros(num_of_macs,1);

    % For each mac address
    for i = 1:size(mac_list,1)
        % Grab all rows with particular mac address
        C = B( strcmp(B.BSSID, mac_list{i,1}), : );
        meanRSSI(i) = mean(C.RSSI);
        varRSSI(i) = var(C.RSSI);
    end
    
    all_meanRSSI = [all_meanRSSI; meanRSSI];
    all_varRSSI = [all_varRSSI; varRSSI];
end
% Create final table 
all_fgps = table(all_location, all_macs, all_meanRSSI, all_varRSSI);

end 