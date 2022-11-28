mkdir -p maps/{osd,node,rack,datacenter} csvs/{osd,node,rack,datacenter} decompiled_maps/{osd,node,rack,datacenter} edited_decompiled_maps/{osd,node,rack,datacenter} edited_maps/{osd,node,rack,datacenter} compare/{osd,node,rack,datacenter}

# crushtool binary 위치
crushtool_dir=/home/ceph/build/bin/crushtool



##### build crushmap
function build_crushmap_failure_domain_osd() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/osd/${map_name} --build --num_osds ${num_osds} node ${bucket_type} ${num_osds} root ${bucket_type} 0
}

function build_crushmap_failure_domain_node() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/node/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 root ${bucket_type} 0
}

function build_crushmap_failure_domain_rack() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/rack/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 rack ${bucket_type} 10 root ${bucket_type} 0
}

function build_crushmap_failure_domain_datacenter() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/datacenter/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 rack ${bucket_type} 10 datacenter ${bucket_type} 50 root ${bucket_type} 0
}


function build_crushmap() {
   local failure_domain="$1"   # Save first argument in a variable
   shift            # Shift all arguments to the left (original $1 gets lost)
   local arr=("$@") # Rebuild the array with rest of arguments
   echo "building crush map... failure domain ${failure_domain}"
   for el in "${arr[@]}";
    do
      local split=(${el//;/ })
      local num_osds=${split[0]}
      local bucket_type=${split[1]}
      local map_name="${num_osds}${bucket_type}"
      echo "  ${map_name}"
      build_crushmap_failure_domain_${failure_domain} ${map_name} ${num_osds} ${bucket_type}
    done
    echo "done"
}


function decompile_crushmap() {
   local failure_domain="$1"   # Save first argument in a variable
   shift            # Shift all arguments to the left (original $1 gets lost)
   local arr=("$@") # Rebuild the array with rest of arguments
   echo "decompiling crush map... failure domain ${failure_domain}"
   for el in "${arr[@]}";
    do
      local split=(${el//;/ })
      local num_osds=${split[0]}
      local bucket_type=${split[1]}
      local map_name="${num_osds}${bucket_type}"
      echo "  ${map_name}"
      ${crushtool_dir} -d ./maps/${failure_domain}/${map_name} -o ./decompiled_maps/${failure_domain}/${map_name}.txt
    done
    echo "done"
}



### edit crushmap by using python script
function edit_crushmap() {
  python3 ./edit_crushmap.py
}




##### testmap
function test_crushmap() { ## $1 num-rep $2 min-x $3 max-x 
  local failure_domain="$1"
  local num_rep="$2"
  local min_x="$3"
  local max_x="$4"
  shift 4
  local arr=("$@")
  echo "testing crush map.. failure domain ${failure_domain}" 
  for el in "${arr[@]}";
  do
    local split=(${el//;/ })
    local num_osds=${split[0]}
    local bucket_type=${split[1]}
    local map_name="${num_osds}${bucket_type}"
    echo "  ${map_name}"
    mkdir -p ./csvs/${failure_domain}/${map_name}
    cd ./csvs/${failure_domain}/${map_name}
    ${crushtool_dir} -i /home/ceph/new_bucket_testing/maps/${failure_domain}/${map_name} --test --output-name ${map_name} --output-csv --num-rep ${num_rep} --min-x ${min_x} --max-x ${max_x}
    cd ../../../
  done
  echo "done."

}


################ 여기서부터 명령어 실행

# osd_array=("10;consthash" "10;straw2" "20;consthash" "20;straw2")
osd_array=("10;uniform2" "10;straw2" "20;uniform2" "20;straw2")
node_array=("30;consthash" "30;straw2" "100;consthash" "100;straw2")
rack_array=("1000;consthash" "1000;straw2" "5000;consthash" "5000;straw2")
datacenter_array=("1000;consthash" "1000;straw2" "5000;consthash" "5000;straw2")



build_crushmap "osd" "${osd_array[@]}"
build_crushmap "node" "${node_array[@]}"
decompile_crushmap "osd" "${osd_array[@]}"
decompile_crushmap "node" "${node_array[@]}"

edit_crushmap
# compile_crushmap

test_crushmap "osd" "2" "0" "1024" "${osd_array[@]}"
test_crushmap "node" "2" "0" "1024" "${node_array[@]}"


