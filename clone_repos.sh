#!/bin/bash

# 设置源目录和目标目录
src_dir="~/Downloads/cloner/PoC-in-GitHub"
dest_dir="~/Downloads/cloner/poc-repo"

# 遍历源目录下的所有目录
for dir in "$src_dir"/*; do
    if [ -d "$dir" ]; then
        # 获取目录的名字
        dir_name=$(basename "$dir")
        
        # 在目标目录中创建同名目录
        mkdir -p "$dest_dir/$dir_name"
        
        # 遍历该目录下的所有json文件
        for json_file in "$dir"/*.json; do
            if [ -f "$json_file" ]; then
                # 获取json文件的名字（不带扩展名）
                json_name=$(basename "$json_file" .json)
                
                # 在目标目录中为该json文件创建同名目录
                mkdir -p "$dest_dir/$dir_name/$json_name"
                
                # 提取json文件中的GitHub repo链接
                urls=$(jq -r '.[].html_url' "$json_file")
                
                # 克隆每个GitHub repo到该目录中
                for url in $urls; do
                    # 使用正则表达式提取 GitHub 仓库的所有者和仓库名
                    owner=$(echo "$url" | awk -F'/' '{print $(NF-1)}')
                    repo=$(echo "$url" | awk -F'/' '{print $NF}')
                    
                    # 为每个仓库创建目录（使用所有者和仓库名）
                    clone_dir="$dest_dir/$dir_name/$json_name/$owner/$repo"
                    mkdir -p "$clone_dir"
                    
                    # 克隆仓库到指定目录
                    git clone "$url" "$clone_dir"
                done
            fi
        done
    fi
done

