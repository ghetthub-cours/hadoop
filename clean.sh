master_name=hadoop89-master
worker_name=hadoop89-worker

default_nb_workers=3
input_nb_workers=${@:1}
nb_workers=${input_nb_workers:-${default_nb_workers}}

if [ "$(docker ps -a -q -f name="${master_name}")" ]; then
    docker stop "${master_name}"
    echo "Container ${master_name} stopped"
    docker rm "${master_name}"
    echo "Container ${master_name} removed"
fi

for i in $(seq 1 ${nb_workers}); do
    cur_worker_name="${worker_name}${i}"
    if [ "$(docker ps -a -q -f name="${cur_worker_name}")" ]; then
        docker stop "${cur_worker_name}"
        echo "Container ${cur_worker_name} stopped"
        docker rm "${cur_worker_name}"
        echo "Container ${cur_worker_name} removed"
    fi
done