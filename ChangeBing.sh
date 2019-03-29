#如需收集每日美图去掉下面注释设置保存文件夹路径
#savepath="/volume1/wallpaper"
#在FileStation里面右键文件夹属性可以看到路径

# 请求接口数据
result=$(wget -t 5 --no-check-certificate -qO- "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1")

# 解析接口数据
echo $result|grep -q url||exit
url=$(echo https://www.bing.com$(echo $result|sed 's/.*"url":"//g'|sed 's/","urlbase".*//g'))
enddate=$(echo $result|sed 's/.*"enddate":"//g'|sed 's/","url".*//g')
hsh=$(echo $result|sed 's/.*"hsh":"//g'|sed 's/","drk".*//g')

echo "url="$url
echo "enddate="$enddate
echo "hsh="$hsh

title=$(echo $result|sed 's/.*"title":"//g'|sed 's/","quiz".*//g')
copyright=$(echo $result|sed 's/.*"copyright":"//g'|sed 's/","copyrightlink".*//g')
word=$(echo $copyright|sed 's/(.\+//g')

if [ -z "$title" ];then
cninfo=$(echo $copyright|sed 's/，/"/g'|sed 's/,/"/g'|sed 's/(/"/g'|sed 's/ //g'|sed 's/\//_/g'|sed 's/)//g')
title=$(echo $cninfo|cut -d'"' -f1)
word=$(echo $cninfo|cut -d'"' -f2)
fi

echo "copyright="$copyright
echo "title="$title
echo "word="$word

# 判断文件是否存在, 不存在则下载
tmpfile=/tmp/bing_$enddate_$hsh".jpg"
echo "tmpfile="$tmpfile
[ ! -f "$tmpfile" ]||exit
echo "文件不存在, 开始下载..."
wget -t 5 --no-check-certificate $url -qO $tmpfile
[ -s $tmpfile ]||exit
echo "下载成功"
rm -rf /usr/syno/etc/login_background*.jpg
cp -f $tmpfile /usr/syno/etc/login_background.jpg &>/dev/null
cp -f $tmpfile /usr/syno/etc/login_background_hd.jpg &>/dev/null
cp -f $tmpfile /usr/syno/synoman/webman/resources/images/default_wallpaper/01.jpg &>/dev/null
cp -f $tmpfile /usr/syno/synoman/webman/resources/images/default/1x/default_wallpaper/dsm6_01.jpg &>/dev/null
cp -f $tmpfile /usr/syno/synoman/webman/resources/images/default/2x/default_wallpaper/dsm6_01.jpg &>/dev/null
cp -f $tmpfile /usr/syno/synoman/webman/resources/images/default/1x/default_wallpaper/dsm6_02.jpg &>/dev/null
cp -f $tmpfile /usr/syno/synoman/webman/resources/images/default/2x/default_wallpaper/dsm6_02.jpg &>/dev/null
echo "背景替换成功"

# 写入欢迎信息
sed -i s/login_background_customize=.*//g /etc/synoinfo.conf
echo "login_background_customize=\"yes\"">>/etc/synoinfo.conf
sed -i s/login_welcome_title=.*//g /etc/synoinfo.conf
echo "login_welcome_title=\"$title\"">>/etc/synoinfo.conf
sed -i s/login_welcome_msg=.*//g /etc/synoinfo.conf
echo "login_welcome_msg=\"$word\"">>/etc/synoinfo.conf
echo "写入欢迎信息成功"

# 保存背景图
if (echo $savepath|grep -q '/') then
cp -f $tmpfile $savepath/$enddate@$title-$word.jpg
fi
rm -rf /tmp/bing_*.jpg
echo "删除临时文件成功"
