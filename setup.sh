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

echo "\n\n\e[91m


      :::::::::: :::::::::::           ::::::::  :::::::::: :::::::::  :::     ::: ::::::::::: ::::::::  :::::::::: :::::::: 
     :+:            :+:              :+:    :+: :+:        :+:    :+: :+:     :+:     :+:    :+:    :+: :+:       :+:    :+: 
    +:+            +:+              +:+        +:+        +:+    +:+ +:+     +:+     +:+    +:+        +:+       +:+         
   :#::+::#       +#+              +#++:++#++ +#++:++#   +#++:++#:  +#+     +:+     +#+    +#+        +#++:++#  +#++:++#++   
  +#+            +#+                     +#+ +#+        +#+    +#+  +#+   +#+      +#+    +#+        +#+              +#+    
 #+#            #+#              #+#    #+# #+#        #+#    #+#   #+#+#+#       #+#    #+#    #+# #+#       #+#    #+#     
###            ###    ########## ########  ########## ###    ###     ###     ########### ########  ########## ########       

                                                                                        by abobas@student.codam.nl \n\n"

#############################################################################################################################

deploy()
{
    echo "\e[91mDeploying $1...\e[0m" 
	kubectl apply -f srcs/yml/$1.yml
    echo "\e[91mSuccesfully deployed $1 \e[0m"
}

build()
{
	echo "\e[91mBuilding $1...\e[0m"
	docker build -t services/$1 srcs/containers/$1/
    echo "\e[91mSuccesfully built $1\e[0m"
}

images="nginx mysql phpmyadmin"
containers="nginx mysql phpmyadmin"

#############################################################################################################################

if ! brew ; then
echo "\e[91mHomebrew not found, installing Homebrew...\e[0m"
curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh
fi

if ! minikube ; then
echo "\e[91mMinikube not found, installing Minikube...\e[0m"
brew install minikube
fi

if ! kubectl ; then
echo "\e[91mKubernetes not found, installing Kubernetes...\e[0m"
brew install kubectl
fi

curl https://github.com/alexandregv/42toolbox/blob/master/init_docker.sh
