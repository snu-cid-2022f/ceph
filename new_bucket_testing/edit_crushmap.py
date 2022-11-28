
import os


decompiled_maps_directory = "decompiled_maps"
edited_decompiled_maps_directory = "edited_decompiled_maps"

os.makedirs(edited_decompiled_maps_directory, exist_ok=True)
os.makedirs(decompiled_maps_directory, exist_ok=True)


new_rule = lambda failure_domain : f"""# rules
rule replicated_rule {{
    id 0
    type replicated
    step take root
    step chooseleaf firstn 0 type {failure_domain}
    step emit
}}
# end crush map
"""



for failure_domain in os.listdir(decompiled_maps_directory):
    failue_domain_path = os.path.join(decompiled_maps_directory, failure_domain)
    for crushmap_file_name in os.listdir(failue_domain_path):
        crushmap_path = os.path.join(failue_domain_path, crushmap_file_name)
        with open(crushmap_path, 'r') as f:
            content = f.readlines()[:-10]
            with open(f"{edited_decompiled_maps_directory}/{failure_domain}/{crushmap_file_name}", "w") as ef:
                ef.writelines(content)
                ef.write(new_rule(failure_domain))