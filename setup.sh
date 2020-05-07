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
	kubectl apply -f srcs/yml/$1.yml > /dev/null 2>&1
}

build()
{
	echo "Building $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null 2>&1 
}

services="nginx mysql phpmyadmin wordpress influxdb telegraf grafana ftps"
start=`date +%s`

#############################################################################################################################

which -s brew
if [[ $? != 0 ]] ; then
echo "Installing homebrew..."
curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh > /dev/null 2>&1 
echo "Homebrew installed, please restart your terminal for brew to work"
exit
fi

which -s minikube
if [[ $? != 0 ]] ; then
echo "Installing minikube..."
brew install minikube > /dev/null 2>&1 
fi

#############################################################################################################################

echo "Cleaning files..."
minikube delete > /dev/null 2>&1 
docker system prune -f > /dev/null 2>&1
rm -rf srcs/containers/nginx/srcs/index.html
rm -rf srcs/containers/wordpress/Dockerfile
rm -rf srcs/containers/telegraf/srcs/telegraf.conf
rm -rf srcs/containers/grafana/srcs/datasource.yml
rm -rf srcs/containers/ftps/Dockerfile
pkill -9 -f "kubectl proxy" && sleep 1 > /dev/null 2>&1 

#############################################################################################################################

echo "Setting up minikube..."
rm -rf ~/goinfre/minikube
mkdir ~/goinfre/minikube
rm -rf ~/.minikube/machines
ln -s ~/goinfre/minikube ~/.minikube/machines
minikube start --cpus=2 --memory 2g --disk-size 10g --driver=virtualbox --extra-config=apiserver.service-node-port-range=1-22000 > /dev/null 2>&1 
minikube addons enable ingress > /dev/null 2>&1 
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

echo "Deploying dashboard..."
kubectl apply -f srcs/yml/dashboard.yml > /dev/null 2>&1 
kubectl proxy & && sleep 1 > /dev/null 2>&1 

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
open http://$IP

echo "\n=================================================================================================================="
echo "Cluster succesfully deployed at http://$IP in $runtime seconds"
echo "Login credentials for all services are user=root with password=password"
echo "=================================================================================================================="
echo "Enter container: kubectl exec -it \$(kubectl get pods | grep 'service-name' | cut -d\" \" -f1) -- sh"
echo "Connect using SSH: ssh root@$IP" 
echo "Connect to FTPS server: lftp -u root -p 21 $IP -e \"set ssl:verify-certificate/$IP no\""
echo "Download from FTPS server: mirror --use-pget-n=8 -c /source /destination"
echo "=================================================================================================================="
