#!/bin/bash

# 设置根目录
base_dir="/root"

# 设置源目录和目标目录
src_dir="$base_dir/PoC-in-GitHub"
dest_dir="$base_dir/poc-repo"
progress_file="$base_dir/clone_progress.txt"  # 记录进度的文件

# 创建一个进度文件（如果不存在）
touch "$progress_file"

# 函数：检查仓库是否已经克隆
is_cloned() {
    local repo_url="$1"
    grep -q "$repo_url" "$progress_file"
}

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
                    # 使用awk从url中提取所有者和仓库名
                    owner=$(echo "$url" | awk -F'/' '{print $(NF-1)}')
                    repo=$(echo "$url" | awk -F'/' '{print $NF}')
                    
                    # 为每个仓库创建目录（使用所有者和仓库名）
                    clone_dir="$dest_dir/$dir_name/$json_name/$owner/$repo"
                    mkdir -p "$clone_dir"
                    
                    # 检查该仓库是否已经克隆
                    if is_cloned "$url"; then
                        echo "Skipping already cloned repo: $url"
                    else
                        # 克隆仓库到指定目录
                        echo "Cloning $url into $clone_dir"
                        git clone --depth 1 "$url" "$clone_dir"
                        
                        # 将克隆完成的仓库链接记录到进度文件中
                        echo "$url" >> "$progress_file"
                    fi
                done
            fi
        done
    fi
done

