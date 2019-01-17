#!/bin/bash

#FUNCIONES#

OPERACION1(){
    echo "Introduce la fecha en el formato 23 agosto"
    read fecha
    dia=`echo $fecha | cut -d" " -f1` #El primer campo corresponde a el día
    mes=`echo $fecha | cut -d" " -f2` #El segundo campo corresponde a el mes
    usuarios=`cat usuarios.txt | grep -w $dia | grep -w $mes$ | cut -d$'\t' -f1` #Busca por el día y por el mes. Recorta por el primer campo para extraer los nombres solo
    if [ -z "$usuarios" ] #Si $usuarios es NULL...
    then
        echo "Ningún usuario se logueó este día."
    else
        echo $usuarios
    fi
}

OPERACION2(){
    echo -n "Introduce el nombre de usuario: "
    read usuario
    logs=`cat usuarios.txt | grep -w ^$usuario | wc -l` #Cuenta el número de líneas en las que aparece $usuario
    if [ $logs -eq 0 ]
    then
        echo "El usuario $usuario no existe"
    else 
        echo "El usuario $usuario se ha logueado $logs veces"
    fi
}

OPERACION3(){
    echo -n "Introduce el nombre de usuario: "
    read usuario
    #Transforma las tabulaciones en . y las nuevas líneas en espacio
    #para poder recorrer el bucle for más facilmente.
    logs=`cat usuarios.txt | grep -w ^$usuario | tr '\t' "." | tr '\n' " "` 
    if [ -z "$logs" ] #Si $logs es NULL...
    then
        echo "El usuario $usuario no existe"
    else

        TODOS_LOS_MESES #Seteo la array desde una función para ordenar mejor el código
        mesAsegurado=0 #Variable false hasta que se descubre el último mes en el que se logueó
        for mes in ${meses[*]}
        do
            for dia in $logs
            do
                usuarioMes=`echo $dia | cut -d"." -f3` #$usuarioMes = a uno de los meses en los que se ha logueado (el tercer campo de usuarios.txt)
                if [ "$mes" == "$usuarioMes" ] #Si el mes actual y el de el usuario son iguales hemos descubierto el último mes en el que se registró
                then
                    ultimoMes=$mes #El último mes en el que se logueó, es igual a el mes que estaba recorriendo el bucle for de la array de todos_los_meses
                    mesAsegurado=1 #Variable pasa a true para salir de los bucles y acortar el tiempo de la ejecución
                fi
                if [ $mesAsegurado -eq 1 ]
                then
                    break
                fi
            done
            if [ $mesAsegurado -eq 1 ]
            then
                break
            fi
        done
        dias=`cat usuarios.txt | grep -w ^$usuario | grep -w $ultimoMes$ | cut -d$'\t' -f2` #Todos los días en los que el usuario se logueó el último mes
        diaMayor=1 #El último día en el que se registró empieza con el valor 1 puesto que es el más bajo posible
        for dia in $dias
        do
            if [ $dia -gt $diaMayor ] #Si $dia tiene un valor mayor que el valor guardado..
            then
                diaMayor=$dia #$diaMayor pasa a tener ese valor para así mostrar el último día en el que se logueó
            fi
        done
        echo "El usuario $usuario se logueó por última vez el $diaMayor de $ultimoMes"
    fi
}

TODOS_LOS_MESES(){
    meses=( diciembre noviembre octubre septiembre agosto julio junio mayo abril marzo febrero enero )
    #En esta array se guardan los meses del año en orden descendiente, para que después en el bucle for
    #en el que se recorren los logs, cuando uno de los meses del año en los que ese usuario se ha 
    #logueado sea igual a este mes, ya sabremos cual es el último mes en el que se logueó porque los 
    #va probando del último mes al primero.
}

#MENU#

exit=0
while [ $exit -eq 0 ]   #Saldrá del script después de realizar una operación
do
    clear
    echo "Escoge una operación escribiendo su número:"
    echo "1. Mostrar los usuarios que se loguearon un día en concreto."
    echo "2. Mostrar el número de veces que se ha logueado un usuario."
    echo "3. Mostrar la fecha de la última vez que se ha logueado un usuario."
    echo -n "Operación: "
    read operacion
    case $operacion in
        1)
            OPERACION1
            exit=1
        ;;
        2)
            OPERACION2
            exit=1
        ;;
        3)
            OPERACION3
            exit=1
        ;;
        *)
            echo "Has introducido un valor incorrecto, pulsa intro y vuelvelo a intentar..."
            read
        ;;
    esac
done