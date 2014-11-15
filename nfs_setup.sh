share_dir=$1
if [ $# -ne 1 ]; then
    echo "$0 share_dir"
    exit 
fi

nfs_utils=`rpm -qa | grep nfs-utils`
if [ "$nfs_utils" == "" ]; then
    echo "nfs utils not found and yum install it"
    yum install nfs-utils
    if [ $? -ne 0 ]; then
        echo "nfs utils install failed"
        exit 1
    else
        echo "nfs utils install success"  
fi

portmap=`rpm -qa | grep portmap`
if [ "$portmap" == "" ]; then
    echo "portmap not find and yum install if"
    yum install portmap
    if [ $? -ne  0 ]; then
        echo "portmap install faied" 
        exit 1
    else
        echo "portmap install success"
    fi
fi

################config exports###############

echo "$share_dir *(rw)" >> /etc/exports
export -v

echo "mountd 1011/tcp" >> /etc/services
echo "mountd 1011/udp" >> /etc/services
 
#######################start nfs and portmap#####################

service portmap restart

service nfs restart
##################insert into chkconfig ##########################
chkconfig --level 345 portmap on
chkconfig --level 345 nfs on

###################test port start or not #######################
rpcinfo -p  localhost | grep grep mountd

#####################show the share dir ###################

showmount -e  localhost

echo "success"
