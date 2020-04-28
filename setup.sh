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
	kubectl apply -f srcs/yml/$1.yml > /dev/null
}

build()
{
	echo "Building $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null
}

services="nginx mysql phpmyadmin"
start=`date +%M`

#############################################################################################################################

echo "Cleaning files..."
minikube delete > /dev/null 2>&1
docker system prune -f > /dev/null 2>&1

#############################################################################################################################

echo "Setting up minikube..."
minikube start --cpus=2 --memory 2g --extra-config=apiserver.service-node-port-range=1-6000 > /dev/null 2>&1
minikube addons enable ingress > /dev/null 2>&1
eval $(minikube docker-env)

for service in $services
do
	build $service
    deploy $service
done

#############################################################################################################################

end=`date +%M`
runtime=$((end-start))
ip=`minikube ip`

echo "================================================="
echo "\e[92mCluster deployed: http://$ip"
echo "Runtime: $runtime minutes\e[0m"