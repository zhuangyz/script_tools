#!/bin/bash
# 电脑需要先安装 wget

# 选项：
# -d [dir] : podfile所在目录
# --install : 重装所有库
# --repo-update : 更新本地仓库

sh_path="$(pwd)"

proj_dir=""
podcmd="pod update --no-repo-update"
need_update_pod_repo=false

# 读取选项
while true
do
  # echo "选项：$1"
  case "$1" in
    -d)
      # echo "选项 -d ：$2"
      proj_dir="$2"
      shift 2
      ;;
    --install)
      # echo "重装所有第三方库"
      podcmd="pod install --no-repo-update"
      shift
      ;;
    --repo-update)
      # echo "需要更新本地仓库"
      need_update_pod_repo=true
      shift
      ;;
    --)
      shift;
      break
      ;;
    *)
      shift
      break
      ;;
  esac
done

if [ -z $proj_dir ]; then
  echo "项目地址不能为空"
  exit 1
fi

cd $proj_dir
echo $(pwd)

# 先更新第三方库
## 如果需要更新本地仓库，则更新，如果更新失败，则退出脚本
if [ ${need_update_pod_repo} == true ]
then
  echo ""
  echo "更新本地仓库"
  repo_update_cmd="pod repo update"
  echo "执行命令 $repo_update_cmd"
  eval $repo_update_cmd
  repo_update_res=$?
  if [ $repo_update_res != 0 ]
  then
    echo "$repo_update_cmd 执行失败"
    exit 1
  fi
fi

## 更新pod库
echo ""
echo "更新项目pod"
echo "执行命令 $podcmd"
echo "$podcmd"
eval $podcmd
pod_res=$?

if [ $pod_res != 0 ]
then
  echo "$podcmd 执行失败"
  exit 1
fi

# 下载完整版微信SDK
cd $sh_path
echo ""
echo "下载完整微信SDK"
wxsdk_url="https://res.wx.qq.com/op_res/DHI055JVxYur-5c7ss5McQZj2Y9KZQlp24xwD7FYnF88x8LA8rWCzSfdStN5tiCD"
wxsdk_dir="WechatOpenSDK"
wxsdk_download_cmd="wget -O $wxsdk_dir.zip $wxsdk_url"
echo "执行命令 $wxsdk_download_cmd"
eval $wxsdk_download_cmd
if [ $? != 0 ]
then
  echo "$wxsdk_download_cmd 执行失败"
  exit 1
fi

echo ""
echo "解压 WechatOpenSDK"
unzip -oq "$wxsdk_dir.zip" -d "$wxsdk_dir"
if [ $? != 0 ]
then
  echo "解压 WechatOpenSDK 失败"
  exit 1
fi
rm -f "$wxsdk_dir.zip"
# 获取SDK里所需的.a和.h文件 的路径
cd $wxsdk_dir
sdk_files_dir=""
for dir in $(ls)
do
  if [[ $dir =~ "OpenSDK" ]];
  then
    cd "$dir"
    sdk_files_dir="$(pwd)"
    break
  fi
done

echo $sdk_files_dir
if [ -z $sdk_files_dir ]
then
  echo "$sdk_files_dir 不存在"
  exit 1
fi

# 替换 pod 中的微信SDK
echo ""
echo "替换 pod 中的微信SDK"
cd $sh_path
um_wxsdk_files_dir="$proj_dir/Pods/UMShare/UMShare/SocialLibraries/WeChat/WechatSDK"
replace_filenames=("WXApi.h" "WXApiObject.h" "WechatAuthSDK.h" "libWeChatSDK.a")
for replace_filename in ${replace_filenames[*]}
do
  cp -rf "$sdk_files_dir/$replace_filename" "$um_wxsdk_files_dir/$replace_filename"
  if [ $? != 0 ]
  then
    echo "替换 $um_wxsdk_files_dir/$replace_filename 失败"
    exit 1
    break
  fi
done

# 删除下载的完整版微信SDK
echo ""
echo "删除下载的完整版微信SDK $sdk_files_dir"
cd $sh_path
rm -rf "$wxsdk_dir"
















