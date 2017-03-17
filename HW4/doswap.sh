#/bin/bash

if (("$#" != "1"))
then
	echo "Error: exactly one argument expected"
	exit 0
fi

docker images > /tmp/img$$

if grep --quiet $1 /tmp/img$$ 
then
    docker ps -a > /tmp/ctr$$

    if grep --quiet web1 /tmp/ctr$$
    then
        docker run -d --network ecs189_default --name web2 $1
        sleep 5 && docker exec ecs189_proxy_1 /bin/bash /bin/swap2.sh
        docker rm -f `docker ps -a | grep web1 | sed -e 's: .*$::'`

    elif grep --quiet web2 /tmp/ctr$$
    then
        docker run -d --network ecs189_default --name web1 $1
        sleep 5 && docker exec ecs189_proxy_1 /bin/bash /bin/swap1.sh
        docker rm -f `docker ps -a | grep web2 | sed -e 's: .*$::'`
    fi
else
	echo "Error: image $1 not found"
	exit 0
fi

