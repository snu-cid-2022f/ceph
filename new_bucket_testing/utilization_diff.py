import os
import csv
import math

csv_directory = "csvs"
compare_directory = "compare"
utilization_diff_directory = "utilization_diff"

for failure_domain in os.listdir(csv_directory):
    failue_domain_path = os.path.join(csv_directory, failure_domain)
    for crushmap_name in os.listdir(failue_domain_path):
        crushmap_dir_path = os.path.join(failue_domain_path, crushmap_name)
        utilization_csv = os.path.join(crushmap_dir_path,f"{crushmap_name}-replicated_rule-device_utilization_all.csv")
        with open(utilization_csv, 'r') as f:
            rdr = csv.reader(f)
            next(rdr) 
            diff_sum = 0
            for line in rdr:
                actual = float(line[1])
                ideal = float(line[2])
                diff_sum += math.fabs(actual-ideal)
            util_diff_path = os.path.join(utilization_diff_directory, failure_domain, crushmap_name)
            with open(util_diff_path, 'w') as uf:
                uf.write(str(diff_sum))


    
    