# Variables
network_name=test

docker_img=hadoop89
docker_tag=latest

master_name=${network_name}-master
worker_name=${network_name}-worker

nb_workers=2

# Stop and remove the containers
./clean.sh ${nb_workers}

# Create a network for the hadoop cluster
docker network inspect "${network_name}" >/dev/null 2>&1 || \
    docker network create --driver bridge "${network_name}"

echo "Network ${network_name} created"

# Modify workers confi}guration
rm -f config/workers
for i in $(seq 1 $((nb_workers))); do
    echo "${worker_name}${i}" >> config/workers
done

# Modify XML configuration files
xmlstarlet ed -L -u "/configuration/property[name='yarn.resourcemanager.hostname']/value" -v "${master_name}" config/yarn-site.xml
xmlstarlet ed -L -u "/configuration/property[name='hbase.rootdir']/value" -v "hdfs://${master_name}:9000/hbase" config/hbase-site.xml
xmlstarlet ed -L -u "/configuration/property[name='fs.defaultFS']/value" -v "hdfs://${master_name}:9000/" config/hbase-site.xml

# Modify ssh configuration
 sed -i '7 c\Host ${network_name}-*' config/ssh_config

# Build the docker image
docker build -t "${docker_img}:${docker_tag}" .

# Run the master container
docker run -itd --net="${network_name}" -p 9870:9870 -p 8088:8088 -p 7077:7077 -p 16010:16010 --name "${master_name}" --hostname "${master_name}" "${docker_img}:${docker_tag}"

# Run the worker containers
for i in $(seq 0 $((nb_workers-1))); do
    docker run -itd -p $((8040+i)):$((8040+nb_workers)) --net="${network_name}" --name "${worker_name}$((i+1))" --hostname "${worker_name}$((i+1))" "${docker_img}:${docker_tag}"
done
