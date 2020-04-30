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
    echo "Deploying $1..." 
	kubectl apply -f srcs/yml/$1.yml > /dev/null 2>&1
}

build()
{
	echo "Building $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null 2>&1
}

volume()
{
    echo "Setting up $1 volume..."
    kubectl apply -f srcs/yml/$1_volume.yml > /dev/null 2>&1
}

volumes="mysql"
services="nginx mysql phpmyadmin"
start=`date +%s`

#############################################################################################################################

echo "Cleaning files..."
minikube delete > /dev/null 2>&1
docker system prune -f > /dev/null 2>&1
rm -rf srcs/containers/nginx/srcs/index.html

#############################################################################################################################

echo "Setting up minikube..."
minikube start --cpus=2 --memory 2g --extra-config=apiserver.service-node-port-range=1-6000 > /dev/null 2>&1
minikube addons enable ingress > /dev/null 2>&1
eval $(minikube docker-env)

#############################################################################################################################

IP=`minikube ip`

cp srcs/containers/nginx/srcs/source.html srcs/containers/nginx/srcs/index.html
sed -i "s/CLUSTER_IP/$IP/" srcs/containers/nginx/srcs/index.html

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

echo "====================================================================================================="
echo "\e[92mCluster succesfully deployed at http://$IP in $runtime seconds\e[0m"
echo "====================================================================================================="
kubectl get pods
echo "-----------------------------------------------------------------------------------------------------"
kubectl get services
echo "-----------------------------------------------------------------------------------------------------"
kubectl get pv