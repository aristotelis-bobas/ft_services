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

echo "

      :::::::::: :::::::::::           ::::::::  :::::::::: :::::::::  :::     ::: ::::::::::: ::::::::  :::::::::: :::::::: 
     :+:            :+:              :+:    :+: :+:        :+:    :+: :+:     :+:     :+:    :+:    :+: :+:       :+:    :+: 
    +:+            +:+              +:+        +:+        +:+    +:+ +:+     +:+     +:+    +:+        +:+       +:+         
   :#::+::#       +#+              +#++:++#++ +#++:++#   +#++:++#:  +#+     +:+     +#+    +#+        +#++:++#  +#++:++#++   
  +#+            +#+                     +#+ +#+        +#+    +#+  +#+   +#+      +#+    +#+        +#+              +#+    
 #+#            #+#              #+#    #+# #+#        #+#    #+#   #+#+#+#       #+#    #+#    #+# #+#       #+#    #+#     
###            ###    ########## ########  ########## ###    ###     ###     ########### ########  ########## ########       

                                                                                        by abobas@student.codam.nl \n"

#############################################################################################################################

deploy()
{
    echo "Deploying $1..." 
	kubectl apply -f srcs/yml/$1.yml > /dev/null 2>>logs
}

build()
{
	echo "Building $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null 2>>logs 
}

services="nginx mysql phpmyadmin wordpress influxdb telegraf grafana ftps"
start=`date +%s`
rm -rf logs

#############################################################################################################################

which -s brew
if [[ $? != 0 ]] ; then
echo "Installing homebrew..."
curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh > /dev/null 2>>logs 
fi

which -s minikube
if [[ $? != 0 ]] ; then
echo "Installing minikube..."
brew install minikube > /dev/null 2>>logs 
fi

#############################################################################################################################

echo "Cleaning files..."
minikube delete > /dev/null 2>>logs 
docker system prune -f > /dev/null 2>>logs
rm -rf srcs/containers/nginx/srcs/index.html
rm -rf srcs/containers/wordpress/Dockerfile
rm -rf srcs/containers/telegraf/srcs/telegraf.conf
rm -rf srcs/containers/grafana/srcs/datasource.yml
rm -rf srcs/containers/ftps/Dockerfile

#############################################################################################################################

echo "Setting up minikube..."
minikube start --cpus=2 --memory 2g --disk-size 2g --driver=virtualbox --extra-config=apiserver.service-node-port-range=1-22000 > /dev/null 2>>logs 
minikube addons enable dashboard > /dev/null 2>>logs 
minikube addons enable ingress > /dev/null 2>>logs 
eval $(minikube docker-env)

#############################################################################################################################

echo "Preparing temporary files..."
IP=`minikube ip`
cp srcs/containers/nginx/srcs/source.html srcs/containers/nginx/srcs/index.html
sed -i '' "s/CLUSTER_IP/$IP/g" srcs/containers/nginx/srcs/index.html
cp srcs/containers/wordpress/srcs/Source srcs/containers/wordpress/Dockerfile
sed -i '' "s/CLUSTER_IP/$IP/g" srcs/containers/wordpress/Dockerfile
cp srcs/containers/telegraf/srcs/source.conf srcs/containers/telegraf/srcs/telegraf.conf
sed -i '' "s/CLUSTER_IP/$IP/g" srcs/containers/telegraf/srcs/telegraf.conf
cp srcs/containers/grafana/srcs/datasource_source.yml srcs/containers/grafana/srcs/datasource.yml
sed -i '' "s/CLUSTER_IP/$IP/g" srcs/containers/grafana/srcs/datasource.yml
cp srcs/containers/ftps/srcs/Source srcs/containers/ftps/Dockerfile
sed -i '' "s/CLUSTER_IP/$IP/g" srcs/containers/ftps/Dockerfile

#############################################################################################################################

for service in $services
do
	build $service
    deploy $service
done

#############################################################################################################################

echo "Cleaning temporary files..."
rm -rf srcs/containers/nginx/srcs/index.html
rm -rf srcs/containers/wordpress/Dockerfile
rm -rf srcs/containers/telegraf/srcs/telegraf.conf
rm -rf srcs/containers/grafana/srcs/datasource.yml
rm -rf srcs/containers/ftps/Dockerfile

#############################################################################################################################

end=`date +%s`
runtime=$((end-start))

echo "\n=================================================================================================================="
echo "Cluster succesfully deployed at http://$IP in $runtime seconds"
echo "=================================================================================================================="

echo "Login credentials for all services are user=root with password=password"
echo "Enter container shell: kubectl exec -it \$(kubectl get pods | grep wordpress | cut -d\" \" -f1) -- sh" 
echo "Restart container: kubectl exec -it \$(kubectl get pods | grep mysql | cut -d\" \" -f1) --  kill 1"
echo "Connect to FTPS server: lftp -u root -p 21 $IP -e \"set ssl:verify-certificate/$IP no\""
echo "Command to download inside FTPS server: mirror --verbose --use-pget-n=8 -c --verbose /file-to-download /directory-to-download-to"
echo "Connect to Nginx container using SSH: ssh root@$IP"
echo "Open Kubernetes web dashboard: minikube dashboard"
echo "Show Kubernetes pods: kubectl get pods"
echo "Show Kubernetes services: kubectl get services"
echo "Show Kubernetes persistent storages: kubectl get pv"
echo "=================================================================================================================="

kubectl get pods
echo "------------------------------------------------------------------------------------------------------------------"
kubectl get services
echo "------------------------------------------------------------------------------------------------------------------"
kubectl get pv
echo "------------------------------------------------------------------------------------------------------------------"

