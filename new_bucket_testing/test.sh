mkdir -p maps csvs decompiled_maps

# crushtool binary 위치
crushtool_dir=../build/bin/crushtool

##### build crushmap
build_crushmap_failure_domain_osd() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/${map_name} --build --num_osds ${num_osds} node ${bucket_type} ${num_osds} root ${bucket_type} 0
}

build_crushmap_failure_domain_node() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 root ${bucket_type} 0
}

build_crushmap_failure_domain_rack() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 rack ${bucket_type} 10 root ${bucket_type} 0
}

build_crushmap_failure_domain_datacenter() { # $1 map_name, $2 num_osds, $3 bucket_type 
  local map_name=${1}
  local num_osds=${2}
  local bucket_type=${3}
  ${crushtool_dir} -o ./maps/${map_name} --build --num_osds ${num_osds} node ${bucket_type} 10 rack ${bucket_type} 10 datacenter ${bucket_type} 50 root ${bucket_type} 0
}


function build_map() {
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

osd_array=("10;consthash" "10;straw2" "20;consthash" "20;straw2")
node_array=("30;consthash" "30;straw2" "100;consthash" "100;straw2")
rack_array=("1000;consthash" "1000;straw2" "5000;consthash" "5000;straw2")
datacenter_array=("1000;consthash" "1000;straw2" "5000;consthash" "5000;straw2")
build_map "osd" "${osd_array[@]}"
build_map "node" "${node_array[@]}"
build_map "datacenter" "${datacenter_array[@]}"




##### testmap
# test_crushmap() {

# }

# test crushmap
# test_crushmap() { # map-name, num-rep, min-x, max-x 
#   ../crushtool -o $1 --test --output-name $1 --output-csv --num-rep $2 --min-x $3 --max-x $4
# }

# num_rep=10
# min_x=0
# max_x=1024
# build_crushmap "10consthash" ${num_rep} ${min_x} ${max_x}



## 아래의 함수들은 Map 확인 용도
# crushmap을 텍스트 파일로 바꿔주는 역할. map_name을 받아서 map_name.txt로 만든다.
decompile_crushmap() { # $1 crushmap이름
  local map_name=${1}
  ${crushtool_dir} -d ./maps/${map_name} -o ./decompiled_maps/${map_name}.txt

}
# map_name.txt를 cat
print_crushmap() { # $1 map_name
  local map_name=${1}
  cat ./decompiled_maps/${map_name}.txt
}

decompile_and_print_crushmap() { # $1 map_name
  for ARG in "$@"
  do
    local map_name=${ARG} 
    decompile_crushmap ${map_name}
    echo "----------${map_name}----------"
    print_crushmap ${map_name}
    echo "-----------end-------------"
    echo ""
  done
  
}

# 잘 만들어졌는지 확인용도
echo "decompling maps.."
decompile_and_print_crushmap 10consthash 10straw2 20consthash 20straw2 > ./decompiled_maps/collection.txt
echo "done."
