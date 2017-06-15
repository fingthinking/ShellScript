# ShellScript
自用shell脚本

### tomcat多部署脚本 [tomcat_app.sh](tomcat_app.sh)
使用shell脚本设置单个机器部署多个tomcat实例

Demo: sh tomcat_app.sh -t apache-tomcat-8.5.15\(副本\) -p 28005:28080:28009 -w web/SpringWeb.war -a web -d tomcat_springweb
