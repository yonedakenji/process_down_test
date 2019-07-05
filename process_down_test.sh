TARGET_CONTAINER=process_down_test_01
RESTART_CONTAINER=process_down_test_02
COUNT=100

# check ps output.
# /usr/libexec/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/log/mariadb/mariadb.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/lib/mysql/mysql.sock
PS_1="/usr/libexec/mysqld "
# /system/MW/java/bin/java -Djava.util.logging.config.file=/system/MW/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dignore.endorsed.dirs= -classpath /system/MW/tomcat/bin/bootstrap.jar:/system/MW/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/system/MW/tomcat -Dcatalina.home=/system/MW/tomcat -Djava.io.tmpdir=/system/MW/tomcat/temp org.apache.catalina.startup.Bootstrap start
PS_2="/system/MW/java/bin/java "
# /system/MW/apache/bin/httpd -DNO_DETACH
PS_3="httpd -DNO_DETACH"

function docker_top_check {
    docker top $1 2>&1 > $1.top
    PS_1_exist=`grep --count "${PS_1}" $1.top`
    PS_2_exist=`grep --count "${PS_2}" $1.top`
    PS_3_exist=`grep --count "${PS_3}" $1.top`
    echo "$1 ${PS_1}:${PS_1_exist}"
    echo "$1 ${PS_2}:${PS_2_exist}"
    echo "$1 ${PS_3}:${PS_3_exist}"

    if [ $((PS_1_exist * PS_2_exist * PS_3_exist)) -eq 0 ]; then
        echo "exit"
        exit -1
    fi
}

for i in `seq $COUNT`
do
    date
    echo "COUNT:$i"
    echo "docker stop $RESTART_CONTAINER"
          docker stop $RESTART_CONTAINER
    echo "docker_top_check $TARGET_CONTAINER"
          docker_top_check $TARGET_CONTAINER
    echo "docker start $RESTART_CONTAINER"
          docker start $RESTART_CONTAINER
    sleep 10s
done
