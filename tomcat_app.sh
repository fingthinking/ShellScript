#########################################################################
# File Name: tomcat_app.sh
# Author: 柳汝滕
# Email: fingthinking@qq.com

# 该程序用于部署多个tomcat实例,提供以下功能:
# 1. 修改端口号(Shutdown/HTTP/AJP);
# 2. 增加app部署目录;
# 3. tomcat目录;
########################################################################
#!/bin/bash

function help(){
	#  帮助函数
	echo "${0} -t tomcat_home -p Shutdown:HTTP:AJP -a app_home -d tomcat_deploy -w war_package"
	echo "    -p 端口号,默认格式 Shutdown:HTTP:AJP, 原始值为8005:8080:8009"
	echo "    -a app所在目录,默认为webapps"
	echo "    -w war文件"
	echo "    -t tomcat的默认目录"
	echo "    -d tomcat的部署目录,parents/tomcat_deploy"
	echo "    -h 呼出help"
}

function file_exist_or_make(){
	# 目录若不存在则创建目录
	f_name=$1
	pwd_home=`pwd`
	if [ ${f_name:0:1} != "/" ];then
		f_name=$pwd_home/$f_name
	fi
	if [ ! -f $f_name ];then
		mkdir -p $f_name
	fi
	echo $f_name
}

############# 获取参数 #######
arg=false
while getopts "p:d:a:w:t:h" opt
do
	arg=true
	case ${opt} in
		p)
			s_port=`echo $OPTARG | cut -d \: -f 1`
			h_port=`echo $OPTARG | cut -d \: -f 2`
			a_port=`echo $OPTARG | cut -d \: -f 3`
			;;
		a)
			app_home="$OPTARG"
			;;
		t)
			tom_home="$OPTARG"
			;;
		d)
			tom_deploy="$OPTARG"
			;;
		w)
			war_name="$OPTARG"
			;;
		h) 
			help
			;;
		\?)
			help
			exit 1
			;;
	esac
done

# 如果不包含参数
if [ true != "$arg" ]
then
	help
	exit 1
fi
########### END #############

#### 逻辑处理 ####
if [ -f $tom_home ];then
	echo "tomcat_home目录不存在"
	exit 1
fi

pwd_home=`pwd`

tom_conf=$tom_home/conf/server.xml
# 替换端口号
echo "正在替换端口号... 8005->$s_port,8080->$h_port,8009->$a_port"
sed "s/8005/$s_port/g" $tom_conf > server.xml.tmp
sed -i"" "s/8080/$h_port/g" server.xml.tmp
sed -i"" "s/8009/$a_port/g" server.xml.tmp

# 拷贝tomcat目录
echo "正在拷贝tomcat到$tom_deploy目录"
file_exist_or_make $tom_deploy
rm -rf $tom_deploy && cp -R $tom_home $tom_deploy

# war包
zip_name=`echo ${war_name%.war} | awk -F "/" '{print $NF}'`
file_exist_or_make $app_home
echo "解压war包:$war_name到$app_home/$zip_name"
unzip -o $war_name -d $app_home/$zip_name

# 设置部署目录
if [ ${app_home:0:1} != "/" ];then
	app_home=$pwd_home/$app_home
fi

# 设置app部署目录
app_context="<Context path='${zip_name}' docBase='${app_home}/${zip_name}' reloadable='false'/>"
sed -i"" "/<\/Host>/i $app_context" server.xml.tmp
cp server.xml.tmp $tom_deploy/conf/server.xml
rm server.xml.tmp
