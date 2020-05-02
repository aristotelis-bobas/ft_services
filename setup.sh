# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    setup.sh                                           :+:    :+:             #
#                                                      +:+                     #
#    By: abobas <abobas@student.codam.nl>             +#+                      #
#                                                    +#+                       #
#    Created: 2020/04/28 01:10:43 by abobas        #+#    #+#                  #
#    Updated: 2020/04/28 01:10:43 by abobas        ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

echo "\e[91m

      :::::::::: :::::::::::           ::::::::  :::::::::: :::::::::  :::     ::: ::::::::::: ::::::::  :::::::::: :::::::: 
     :+:            :+:              :+:    :+: :+:        :+:    :+: :+:     :+:     :+:    :+:    :+: :+:       :+:    :+: 
    +:+            +:+              +:+        +:+        +:+    +:+ +:+     +:+     +:+    +:+        +:+       +:+         
   :#::+::#       +#+              +#++:++#++ +#++:++#   +#++:++#:  +#+     +:+     +#+    +#+        +#++:++#  +#++:++#++   
  +#+            +#+                     +#+ +#+        +#+    +#+  +#+   +#+      +#+    +#+        +#+              +#+    
 #+#            #+#              #+#    #+# #+#        #+#    #+#   #+#+#+#       #+#    #+#    #+# #+#       #+#    #+#     
###            ###    ########## ########  ########## ###    ###     ###     ########### ########  ########## ########       

                                                                                        by abobas@student.codam.nl \n\e[0m"

#############################################################################################################################

deploy()
{
    echo -n "\nDeploying $1..." 
	kubectl apply -f srcs/yml/$1.yml > /dev/null 2>&1 & spin
}

build()
{
	echo -n "\nBuilding $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null 2>&1 & spin
}

volume()
{
    echo -n "\nMounting $1 volume..."
    kubectl apply -f srcs/yml/$1_volume.yml > /dev/null 2>&1 & spin
}

spin()
{
    pid=$!
    i=0
    while ps -a | awk '{print $1}' | grep -q "${pid}"
    do
        c=`expr ${i} % 4`
        case ${c} in
            0) echo "/\c";;
            1) echo "-\c";;
            2) echo "\\ \b\c";;
            3) echo "|\c";;
        esac
        i=`expr ${i} + 1`
        sleep 0.65
        echo "\b\c"
    done
    echo -n " \b\c"
}

volumes="mysql"
services="nginx mysql phpmyadmin wordpress"
start=`date +%s`

#############################################################################################################################

echo -n "Cleaning files..."
minikube delete > /dev/null 2>&1 & spin
docker system prune -f > /dev/null 2>&1 & spin
rm -rf srcs/containers/nginx/srcs/index.html & spin
rm -rf srcs/containers/wordpress/Dockerfile & spin

#############################################################################################################################

echo -n "\nSetting up minikube..."
minikube start --cpus=2 --memory 2g --extra-config=apiserver.service-node-port-range=1-6000 > /dev/null 2>&1 & spin
minikube addons enable ingress > /dev/null 2>&1 & spin
eval $(minikube docker-env)

#############################################################################################################################

IP=`minikube ip`
cp srcs/containers/nginx/srcs/source.html srcs/containers/nginx/srcs/index.html & spin
cp srcs/containers/wordpress/srcs/Source srcs/containers/wordpress/Dockerfile & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/nginx/srcs/index.html & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/wordpress/Dockerfile & spin

#############################################################################################################################

for volume in $volumes
do
    volume $volume
done

for service in $services
do
	build $service
    deploy $service
done

#############################################################################################################################



end=`date +%s`
runtime=$((end-start))
echo "\n====================================================================================================="
echo "\e[92mCluster succesfully deployed at http://$IP in $runtime seconds\e[0m"
echo "====================================================================================================="
kubectl get pods
echo "-----------------------------------------------------------------------------------------------------"
kubectl get services
echo "-----------------------------------------------------------------------------------------------------"
kubectl get pv
echo "-----------------------------------------------------------------------------------------------------"

