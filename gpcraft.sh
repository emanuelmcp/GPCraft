#!/bin/bash

# FUNCIONES
LISTAR_PROYECTOS(){
        echo Tus proyectos son:
        echo
        gcloud projects list
}
CREAR_BUCKET(){
    read -p "Indica el nombre del bucket que vas a crear: " bucket
    echo
    echo "Indica el ID del proyeto principal..."
    echo
    LISTAR_PROYECTOS
    echo
    read -p "ID del proyecto: " proyecto
    echo
    gsutil mb -p $proyecto -b on -l europe-west2 gs://$bucket/
    gsutil iam ch -d allUsers:objectViewer gs://$bucket/
}
FINALIZADO(){
    echo
    echo --------------------
    echo F I N A L I Z A D O
    echo --------------------
}
PRIMER_INICIO(){
    echo Asignando RAM...
    echo
    sudo java -Xms4G -Xms8G -jar /home/minecraft/server.jar nogui
    sudo sed -i.orig 's/eula=false/eula=true/g' eula.txt
    echo
    echo Permitiendo el acceso de jugadores no premium...
    echo
    sudo sed -i.orig 's/online-mode=true/online-mode=false/g' server.properties
    sudo java -Xms4G -Xms8G -jar /home/minecraft/server.jar nogui
}
SLEEP(){
    sleep 3
}
LISTAR_BUCKETS(){
	echo Tus buckets son:
	echo
	gsutil ls
}
PRIMEROS_PASOS(){
		sudo apt-get update
		sudo apt-get upgrade
		echo
                echo Creando usuario minecraft...
                sudo adduser minecraft
                echo
                echo Creando grupo minecraft...
                sudo groupadd minecraft
                echo
                echo Creando directorio minecraft en /home
                sudo mkdir /home/minecraft
                echo
                echo Añadiendo usuario minecraft al grupo minecraft...
                sudo usermod -a -G minecraft minecraft
                echo
                read -p "Introduce un nombre para la regla: " regla
                echo
                echo Creando regla firewall $regla...
                echo
                echo Vincula la regla a una instancia...
                echo
                echo Estas son todas tus instancias:
                echo
                gcloud compute instances list
                echo
                read -p "Nombre de la instancia: " instancia
                echo
                echo Asociando regla a la instancia $instancia...
                echo
                echo Permitiendo el trafico entrante en el puerto 25565...
                echo
                gcloud compute firewall-rules create $regla \
                    --action allow \
                    --direction ingress \
                    --rules tcp:25565 \
                    --source-ranges 0.0.0.0/0 \
                    --target-tags $instancia
                echo
                echo Instalando Java...
                echo
                sudo apt-get install openjdk-16-jre-headless
                echo Desplazandose a /home/minecraft
                cd /home/minecraft
}

VOLVER_MENU(){
clear
echo
echo Volviendo al menu...
SLEEP
exec "$0"
}
OPCION_INVALIDA(){
echo
echo $seleccion no es una opcion valida
sleep 1
}
opcion=0
    echo
    echo -------------------------------
    echo --- GPCraft 1.0 by SDJuba ---
    echo -------------------------------
    echo
    ip=$(wget -qO- ifconfig.co/ip)
    echo "ACCEDE A TU SERVIDOR: $ip"
    echo
    echo "TWITTER: https://twitter.com/sd_juba"
    echo
    echo "APOYAR POR PAYPAL: sdjuba.tv@gmail.com"
    echo 
    echo "1) INSTALAR JAVA Y SERVIDOR OFICIAL"
    echo "2) CAMBIAR SERVIDOR A PAPERMC/SPIGOT"
    echo "3) INICIAR SERVIDOR EN SEGUNDO PLANO"
    echo "4) CARGAR PLUGINS"
    echo "5) CARGAR DATA PACKS"
    echo "6) COPIA DE SEGURIDAD DEL SERVIDOR"
    echo "7) CREAR BUCKET PARA SUBIR BACKUPS, PLUGINS O DATAPACKS"
    echo "8) RECUPERAR SERVER DESDE BACKUP"
    echo "9) BORRAR MUNDO"
    echo "10) BORRAR SERVIDOR"
    echo "11) SALIR DEL PROGRAMA"
    echo
    read -p "Selecione una opcion: " opcion
    echo
    case $opcion in
        1) clear
	    echo "ESTA OPCION INSTALA JAVA 16 (PARA MINECRAFT 1.17 Y POSTERIORES)"
	    echo "E INSTALA AUTOMATICAMENTE EL SERVIDOR OFICIAL DE MINECRFT JAVA"
	    echo
	    echo "ATENCION: EL SERVIDOR SE INSTALARA EN EL DIRECTORIO /home/minecraft/"
	    echo
            read -p "¿Estas seguro de que quieres instalar el servidor oficial de minecraft java? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
                PRIMEROS_PASOS
		read -p "Introduce el link oficial de mojang: " link_mojang
                wget $link_mojang
                PRIMER_INICIO
                FINALIZADO
                echo
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        2) clear
            echo "ESTA OPCION CAMBIA EL SERVIDOR OFICIAL DE MINECRAFT JAVA POR PAPERMC"
	    echo
            echo "ATENCIÓN: PARA QUE FUNCIONE BIEN PRIMERO INSTALA EL SERVER OFICIAL"
	    echo "DE MINECRAFT JAVA CON LA OPCION 1"
            echo
            read -p "¿Estas seguro de que quieres instalar el servidor PaperMC? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
		cd /home/minecraft
		echo
                read -p "Introduce el link oficial de papermc: " link_paper
                wget $link_paper
		echo
                echo Actualizando a PaperMC...
		echo
                sudo mv paper-* /home/minecraft/server.jar
                PRIMER_INICIO
                FINALIZADO
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        3) clear
	    echo "ESTA OPCION INICIA TU SERVIDOR MINECRAFT EN SEGUNDO PLANO"
            read -p "¿Estas seguro de que quieres iniciar el servidor (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
		cd /home/minecraft
		echo
                echo Iniciando el servidor de minecraft...
		echo
                sudo java -Xms4G -Xmx8G -jar server.jar nogui
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU

            else
		OPCION_INVALIDA
                VOLVER_MENU
            fi
            SLEEP
            ;;
        4) clear
	    echo "PARA UTILIZAR ESTA FUNCION, PRIMERO DEBES CREAR UN BUCKET (OPCION 7)"
	    echo "Y SUBIR LOS PLUGINS A ESE BUCKET EN FORMATO JAR. NO ARCHIVOS COMPRIMIDOS"
	    echo
            read -p "¿Estas seguro de que quieres cargar los plugins? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
                echo Selecciona el proyecto al que pertenece tu bucket:
                echo
		LISTAR_PROYECTOS
		echo
		read -p "ID del proyecto: " proyecto
		echo
		echo Selecciona el nombre del bucket donde estan subidos tus plugins
		echo
		LISTAR_BUCKETS
		echo
		read -p "Nombre del bucket: " bucket
		echo
                echo Copiando los plugins...
		echo
                echo ¡¡¡REINICIA EL SERVIDOR PARA APLICAR LOS CAMBIOS!!!
                gsutil cp gs://$bucket/* /home/minecraft/plugins
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
	5) clear
            echo "PARA UTILIZAR ESTA FUNCION, PRIMERO DEBES CREAR UN BUCKET (OPCION 7)"
            echo "Y SUBIR LOS DATA PACKS  A ESE BUCKET EN FORMATO ZIP."
            echo
            read -p "¿Estas seguro de que quieres cargar los data packs? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
                echo Selecciona el proyecto al que pertenece tu bucket:
                echo
                LISTAR_PROYECTOS
                echo
                read -p "ID del proyecto: " proyecto
                echo
                echo Selecciona el nombre del bucket donde estan subidos tus data packs
                echo
                LISTAR_BUCKETS
                echo
                read -p "Nombre del bucket: " bucket
                echo
                echo Copiando los data packs...
                echo
                echo ¡¡¡REINICIA EL SERVIDOR PARA APLICAR LOS CAMBIOS!!!
                gsutil cp gs://$bucket/* /home/minecraft/world/datapacks
                VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
 		OPCION_INVALIDA
                VOLVER_MENU
            fi
            SLEEP
            ;; 
        6) clear
	    echo "ESTA OPCION HACE UNA COPIA DE SEGURIDAD EN FORMATO TAR.GZ Y LO ALMACENA"
	    echo "EN UN BUCKET NUEVO CON ACCESO PUBLICO DE GOOGLE CLOUD. CON LA OPCION 8"
	    echo "PUEDES RESTAURAR TU SERVIDOR DESDE UN BUCKET"
	    echo
	    echo "ATENCION: AL SER UN BUCKET PUBLICO PUEDES ACCEDER A EL DESDE OTRA CUENTA GPC"
	    echo
            read -p "¿Estas seguro de que quieres hacer una copia de seguridad del servidor? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
                CREAR_BUCKET
		cd /home
                read -p "Indica el nombre del comprimido: " nombrecomprimido
                echo Comprimiendo archivos...
                tar -czf $nombrecomprimido.tar.gz minecraft
                echo Subiendo archivos al bucket...
                gsutil cp $nombrecomprimido.tar.gz gs://$bucket/
                FINALIZADO
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        7) clear
	    echo "ESTA OPCION CREA UN BUCKET CON ACCESO PUBLICO PARA PODER SUBIR TUS PLUGINS Y DATAPACKS"
	    echo
	    echo "ATENCIÓN: DESPUES DE SUBIR TUS COMPLEMENTOS PUEDES INSTALARLOS CON LAS OPCIONES 4 Y 5"
	    echo
            read -p "¿Estas seguro de que quieres crear un bucket? (s/n): " seleccion
	    echo
            if [[ $seleccion == "s" ]];
            then
                CREAR_BUCKET
                FINALIZADO
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        8) clear
	    echo "PUEDES RECUPERAR TU SERVIDOR DESDE UN BACKUP CREADO CON LA OPCION 6."
	    echo
	    echo "ATENCION: CUANDO CREAS UN BACKUP DEL SERVIDOR CON LA OPCION 6 SE CREA UN BUCKET CON"
	    echo "CON ACCESO PUBLICO. POR LO TANTO PUEDES ACCEDER A EL DESDE OTRA CUENTA DE GPC"
	    echo
            read -p "Estas seguro de que quieres recuperar el servidor desde un  bucket? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
		LISTAR_BUCKETS
		cd /home/minecraft
                read -p "Introduce el nombre del bucket: " bucket
		echo
		echo Accediendo a los archivos del bucket...
		echo
		gsutil ls -r gs://$bucket/**
		echo
		SLEEP
		read -p "Introduce el nombre de tu copia de seguridad (sin .tar.gz):" copia
                sudo gsutil cp gs://$bucket/$copia.tar.gz .
		echo
		echo Descomprimiendo archivo tu copia de seguridad...
		sudo tar xzvf $copia.tar.gz
		echo
		echo Borrando $copia.tar.gz...
		# sudo rm $copia.tar.gz
                FINALIZADO
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        9) clear
            echo "ESTA OPCION BORRA EL ,UNDO PERMANENTEMENTE"
            echo
            echo "ATENCION: SI ELIGES ESTA OPCION NO PODRAS RECUPERAR EL MUNDO A NO SER QUE"
            echo "TENGAS UNA COPIA DE SEGURIDAD DEL SERVIDOR CREADA PREVIAMENTE CON LA OPCION 6"
	    echo
            read -p "Estas seguro de que quieres borrar el mundo? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
                echo Borrando el mundo...
                cd /home/minecraft
                sudo rm -rf world
                FINALIZADO
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        10) clear
	    echo "ESTA OPCION BORRA EL SERVIDOR PERMANENTEMENTE"
	    echo
	    echo "ATENCION: SI ELIGES ESTA OPCION NO PODRAS RECUPERAR EL SERVIDOR"
	    echo "A NO SER QUE TENGAS UNA COPIA DE SEGURIDAD CREADA PREVIAMENTE"
            read -p "Estas seguro de que quieres borrar el servidor? (s/n): " seleccion
            if [[ $seleccion == "s" ]];
            then
		echo
                echo Borrando servidor...
                sudo rm -rf /home/minecraft
                FINALIZADO
		VOLVER_MENU
            elif [[ $seleccion == "n" ]]; then
                VOLVER_MENU
            else
                OPCION_INVALIDA
		VOLVER_MENU
            fi
            SLEEP
            ;;
        11) clear
	    echo Cerrando el programa...
            SLEEP
	    exit
            ;;
        *) clear
            echo $opcion no es una opcion valida
            SLEEP
            ;;
esac

