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
    printf "%s" "\nDeploying $1..." 
	kubectl apply -f srcs/yml/$1.yml > /dev/null 2>&1 & spin
}

build()
{
	printf "%s" "\nBuilding $1..."
	docker build -t services/$1 srcs/containers/$1 > /dev/null 2>&1 & spin
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
    printf "%s" " \b\c"
}

services="nginx mysql phpmyadmin wordpress influxdb telegraf grafana ftps"
start=`date +%s`

#############################################################################################################################

which -s brew
if [[ $? != 0 ]] ; then
printf "%s" "\nInstalling Homebrew..."
curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh > /dev/null 2>&1 & spin
fi

which -s minikube
if [[ $? != 0 ]] ; then
printf "%s" "\nInstalling Minikube..."
brew install minikube > /dev/null 2>&1 & spin
fi

which -s kubectl
if [[ $? != 0 ]] ; then
printf "%s" "\nInstalling Kubernetes..."
brew install kubectl > /dev/null 2>&1 & spin
fi

#############################################################################################################################

printf "%s" "\nCleaning files..."
minikube delete > /dev/null 2>&1 & spin
docker system prune -f > /dev/null 2>&1 & spin
rm -rf srcs/containers/nginx/srcs/index.html & spin
rm -rf srcs/containers/wordpress/Dockerfile & spin
rm -rf srcs/containers/telegraf/srcs/telegraf.conf & spin
rm -rf srcs/containers/grafana/srcs/datasource.yml & spin
rm -rf srcs/containers/ftps/Dockerfile & spin

#############################################################################################################################

printf "%s" "\nSetting up minikube..."
minikube start --cpus=2 --memory 2g --extra-config=apiserver.service-node-port-range=1-22000 > /dev/null 2>&1 & spin
minikube addons enable dashboard > /dev/null 2>&1 & spin
minikube addons enable ingress > /dev/null 2>&1 & spin
eval $(minikube docker-env)

#############################################################################################################################

printf "%s" "\nPreparing temporary files..."
IP=`minikube ip`
cp srcs/containers/nginx/srcs/source.html srcs/containers/nginx/srcs/index.html & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/nginx/srcs/index.html & spin
cp srcs/containers/wordpress/srcs/Source srcs/containers/wordpress/Dockerfile & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/wordpress/Dockerfile & spin
cp srcs/containers/telegraf/srcs/source.conf srcs/containers/telegraf/srcs/telegraf.conf & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/telegraf/srcs/telegraf.conf & spin
cp srcs/containers/grafana/srcs/datasource_source.yml srcs/containers/grafana/srcs/datasource.yml & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/grafana/srcs/datasource.yml & spin
cp srcs/containers/ftps/srcs/Source srcs/containers/ftps/Dockerfile & spin
sed -i "s/CLUSTER_IP/$IP/g" srcs/containers/ftps/Dockerfile & spin

#############################################################################################################################

for service in $services
do
	build $service
    deploy $service
done

#############################################################################################################################

printf "%s" "\nCleaning temporary files..."
rm -rf srcs/containers/nginx/srcs/index.html & spin
rm -rf srcs/containers/wordpress/Dockerfile & spin
rm -rf srcs/containers/telegraf/srcs/telegraf.conf & spin
rm -rf srcs/containers/grafana/srcs/datasource.yml & spin
rm -rf srcs/containers/ftps/Dockerfile & spin

#############################################################################################################################

end=`date +%s`
runtime=$((end-start))

echo "\n=================================================================================================================="
echo "\e[92mCluster succesfully deployed at http://$IP in $runtime seconds\e[0m"
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

