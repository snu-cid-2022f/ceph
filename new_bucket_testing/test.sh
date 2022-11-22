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


##### failure domain osd
temp_build_crush_map_failure_domain_osds() {
  echo "building crush map... failure domain osd. "
  local array=("10;consthash", "10;straw2")
  for el in ${arryay[@]}; do
    local split=(${el//;/ })
    local num_osds=${split[0]}
    local bucket_type=${split[1]}
    build_crushmap_failure_domain_osd "${num_osds}${bucket_type}" ${num_osds} ${bucket_type} # 10straw2
  done
  echo "done."
}
temp_build_crush_map_failure_domain_osds

##### failure domain node
echo "building crush map... failure domain node. "
build_crushmap_failure_domain_node 30consthash 30 consthash 
build_crushmap_failure_domain_node 30straw2e 30 straw2
build_crushmap_failure_domain_node 100consthash 100 consthash 
build_crushmap_failure_domain_node 100straw2 100 straw2 
echo "done."

##### failure domain rack
echo "building crush map... failure domain rack. "
echo "  building 1000"
build_crushmap_failure_domain_rack 1000consthash 1000 consthash
build_crushmap_failure_domain_rack 1000consthash 1000 consthash
echo "  building 5000 "
build_crushmap_failure_domain_rack 5000consthash 5000 consthash
build_crushmap_failure_domain_rack 5000consthash 5000 consthash
echo "done."

##### failure domain datacenter
echo "building crush map... failure domain datacenter. "
echo "  building 25000 consthash "
build_crushmap_failure_domain_datacenter 25000consthash 25000 consthash
echo "  building 25000 straw2 "
build_crushmap_failure_domain_datacenter 25000straw2 25000 straw2
echo "done."



##### testmap
test_crushmap() {

}

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
decompile_and_print_crushmap 1000consthash > ./decompiled_maps/collection.txt
echo "done."
