#!/bin/sh


selectBox () {
echo "\e[92mQuelle box voulez-vous installer: \e[0m"
echo "Pour ubuntu/xenial64: tapez 1"
echo "Pour ubuntu/trusty64: tapez 2"
echo "Pour puphpet/ubuntu1404-x64: tapez 3"
read boxChoice

case $boxChoice in
    1) echo "config.vm.box = \"ubuntu/xenial64\"" >> Vagrantfile
	   ;;
    2) echo "config.vm.box = \"ubuntu/trusty64\"" >> Vagrantfile
	   ;;
    3) echo "config.vm.box = \"puphpet/ubuntu1404-x64\"" >> Vagrantfile
	   ;;
    *) echo "\e[92mChoix invalide\e[0m"
    #echo -e "\e[92m Bienvenue sur mon script !\e[0m "

	   rm -f Vagrantfile
       selectBox
       ;; 
    esac
    # put network config after box choice
}

changeDirectoriesName () {
    echo "\e[92mVoulez-vous changer le nom des dossiers synchronisés ? (oui/non):\e[0m"
    read response

    case $response in
        "oui") echo "\e[92mcomment voulez-vous nommer le dossier local: \e[0m" 
            read localDirName
            echo "\e[92mcomment voulez-vous nommer le dossier distant: \e[0m" 
            read remoteDirName	
            echo "config.vm.synced_folder \"./${localDirName}\", \"/${remoteDirName}\"" >> Vagrantfile
            mkdir $localDirName
            ;;
        "non") echo "config.vm.synced_folder \"./data\", \"/var/www/html\"" >> Vagrantfile	
            mkdir data 
            ;;
        *)     echo "\e[92mMerci de répondre par oui ou par non\e[0m"
            changeDirectoriesName
            ;; 
    esac
    }

changeIp () {
    echo "\e[92mVoulez-vous modifier l'adresse ip? (oui/non)\e[0m"
    read choice
    case $choice in
        "oui") echo "\e[92mQuelle adresse ip voulez-vous mettre: \e[0m" 
            read ip
            echo "config.vm.network \"private_network\", ip: \"${ip}\"" >> Vagrantfile
            ;;
        "non") echo "config.vm.network \"private_network\", ip: \"192.168.33.10\"" >> Vagrantfile
            ;;
        *)     echo "\e[92mMerci de répondre par oui ou par non\e[0m"
            changeIp
            ;; 
    esac
}

stopMachine () {
    echo "\e[92mVoulez-vous arrêter une machine? (oui/non) \e[0m"
    read stopMachine

    case $stopMachine in
        "oui") echo "\e[92mVoulez-vous arrêter votre machine? \e[0m" 
            vagrant halt            
            ;;
        "non") echo "\e[92mVous pouvez continuer à l'utiliser :)\e[0m"
            ;;
        *)  echo "\e[92mMerci de répondre par oui ou par non\e[0m"
            stopMachine
            ;; 
    esac
}

# To finish , cat the vagrantfile is not so bad.... nearly
#installPackages () {
#    echo "\e[92mVoulez-vous installer les paquets Mysql Php7.0 et Apach2 ? (oui/non) \e[0m"
#    read paquetResponse
#
#    case $paquetResponse in
#        "oui")  echo "config.vm.provision \"shell\", inline: <<-SHELL\n 
#                sudo apt-get -y update\n
#                sudo apt-get -y install apache2\n
#                sudo debconf-set-selections <<< \"mysql-server mysql-server/0000\"\n
#                sudo debconf-set-selections <<< \"mysql-server mysql-server/0000\"\n
#                sudo apt-get -y install mysql-server\n
#                sudo apt-get -y install php7.0\n
#                SHELL \n
#                end" >> Vagrantfile       
#                ;;
#        "non") echo "\e[92mTrès bien, nous allons lancer la Vm en ssh, enjoy!)\e[0m"
#            ;;
#        *)  echo "\e[92mMerci de répondre par oui ou par non\e[0m"
#            install
#            ;; 
#    esac
#
#}

# strating script
if [ ! dpkg -s 'vagrant' >/dev/null 2>&1 ]
then 
    echo "nous allons installer Vagrant"
    sudo apt install vagrant -y
else 
    echo "Vagrant est déjà installé"
fi

if [ ! dpkg -s 'virtualbox' >/dev/null 2>&1 ]
then 
    echo "nous allons installer Virtualbox"
    sudo apt install virtuabox -y
else 
    echo "Virtualbox est déjà installé"
fi

touch Vagrantfile

echo "Nous allons maintenant initialiser le Vagrantfile: "

echo "Vagrant.configure("2") do |config|" >> Vagrantfile

selectBox
changeIp
changeDirectoriesName


echo "\e[92mVotre machine est en cours d'installation...\e[0m"

stopMachine
installPackages
vagrant status --machine-readable | grep state,running
echo "\e[92mVoici la liste des vm en cours d'utilisation sur la système \e[0m"
#finalize Vagranfile
vagrant up
echo "\e[92mVous allez être connecté à votre machine en ssh\e[0m"
vagrant ssh

