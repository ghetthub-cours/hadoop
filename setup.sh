# Variables
network_name=hadoop89

docker_img=hadoop89
docker_tag=latest

master_name=hadoop89-master
worker_name=hadoop89-worker

nb_workers=3

# Stop and remove the containers
./clean.sh ${nb_workers}

# Create a network for the hadoop cluster
docker network inspect "${network_name}" >/dev/null 2>&1 || \
    docker network create --driver bridge "${network_name}"

echo "Network ${network_name} created"

# Modify workers confi}guration
rm -f config/workers
for i in $(seq 1 $((nb_workers))); do
    echo "hadoop89-worker${i}" >> config/workers
done

# Build the docker image
docker build -t "${docker_img}:${docker_tag}" .

# Run the master container
docker run -itd --net="${network_name}" -p 9870:9870 -p 8088:8088 -p 7077:7077 -p 16010:16010 --name "${master_name}" --hostname "${master_name}" "${docker_img}:${docker_tag}"

# Run the worker containers
for i in $(seq 0 $((nb_workers-1))); do
    docker run -itd -p $((8040+i)):$((8040+nb_workers)) --net="${network_name}" --name "${worker_name}$((i+1))" --hostname "${worker_name}$((i+1))" "${docker_img}:${docker_tag}"
done
