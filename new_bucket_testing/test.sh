
# crushtool binary 위치
crushtool_dir=../build/bin/crushtool

# build crushmap
build_crushmap_failure_domain_osds() { # $1 map_name, $2 num_osds, $3 bucket_type 
    local map_name=${1}
    local num_osds=${2}
    local bucket_type=${3}
    ${crushtool_dir} -o ./maps/${map_name} --build --num_osds ${num_osds} node ${bucket_type} ${num_osds} root ${bucket_type} 0
}

build_crushmap_failure_domain_osds 10consthash 10 consthash # 10consthash
build_crushmap_failure_domain_osds 10straw2 10 straw2 # 10straw2



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
  ${crushtool_dir} -d ${map_name} -o ${map_name}.txt

}
# map_name.txt를 cat
print_crushmap() { # $1 map_name
  local map_name=${1}
  cat ${map_name}.txt
}

decompile_and_print_crushmap() { # $1 map_name
  local map_name=${1}
   decompile_crushmap ${map_name}
   print_crushmap ${map_name}
}

# 잘 만들어졌는지 확인용도
# decompile_and_print_crushmap 10consthash

