#!/bin/bash
##FUNCIONES##
ROMANO_A_DECIMAL(){
    valorAnterior=1001 #El valor más alto posible es 1000 así que con 1001 bastará
    for letra in $(grep -o . <<< $entrada) 
    do
        eval valor='$'{numeros[$letra]} #Necesario para hacer despúes el comando let
        if [ $valor -gt $valorAnterior ] #Si el valor de la array (declarada antes de entrar a esta función)
        then                             #es mayor que la del valor anterior
            let total=$total-2*$valorAnterior #Se le debe restar 2 veces el valor del valor anterior (porque ya se ha sumado 1 vez)
        fi
        let total=$total+$valor #Siempre se suma el nuevo valor
        valorAnterior=$valor #Se establece el valor anterior
    done
    if [ $total -gt 1999 ] #Para comprobar si el número resultante es mayor de 1999
    then
        echo "El número $entrada es romano pero su valor ($total) es mayor de 1999"
    else
        echo "El número $entrada es romano y su conversión a decimal es: $total"
    fi
}

DECIMAL_A_ROMANO(){
    #Arrays asociadas pos los números romanos y su valor en decimal
    numeros=( 1000 900 500 400 100 90 50 40 10 9 5 4 1 ) 
    romanos=( M CM D CD C XC L XL X IX V IV I ) 
    salida=$entrada 
    for clave in "${!numeros[@]}"  #Se itera la array de números por la clave para saber la posición del valor en la otra array
    do
        while [ $salida -ge ${numeros[$clave]} ] #Si es mayor o igual
        do 
            let salida=$salida-${numeros[$clave]} #Se resta el valor al valor de salida
            total="$total${romanos[$clave]}" #Se añade a la string de números romanos
        done 
    done 
    echo "El número $entrada es decimal y su conversión a romano es: $total"
}

##MENU##
entrada=$1
if [ $entrada -le 1999 ] 2>/dev/null #Si es un número menor de 1999 hace la conversión
then
    correcto="decimal" # $correcto pasa a ser "decimal" para que se ejecute la conversión de decimal a romano
elif [ $entrada -gt 2000 ] 2>/dev/null #Si es mayor de 1999 no hace la conversión
then
    correcto="mayor" # $correcto pasa a ser "mayor" para que se muestre el mensaje de que es un número mayor de 1999
elif [ "$entrada" == "" ]
then
    correcto="error" # El valor de esta cadena no importa puesto que entrará en el * del case
else
    declare -A numeros=( [I]=1 [V]=5 [X]=10 [L]=50 [C]=100 [D]=500 [M]=1000 )   #Iniciamos la array asociativa ahora para poder iterar sus claves
    valido=0 #Si el carácter romano que se está comprobando ahora mismo pertenece a las claves de la array numeros vale cambiará a 1
    fallido=0 #Si hay algún inconveniente fallido pasará a ser 1 y no se ejecutará la conversión

    #Iteramos por cada carácter de la introducción para comprobar si existe ese número romano
    for letraRomana in $(grep -o . <<< $entrada) 
    do                                          
        for romano in ${!numeros[@]} #Para iterar por las claves de la array (son números romanos)
        do
            if [ "$letraRomana" == "$romano" ]
            then
                valido=1 #Si el carácter de la introducción es igual a una de las claves de la array, es valido y se sigue con el bucle
            fi
        done
        if [ $valido -eq 0 ] #Si algún carácter no existe en la array es porque la introducción es errónea
        then
            fallido=1 #Fallido vale 1 así que no se hará la conversión
            break
        fi
        valido=0
    done 
    if echo "$entrada" | grep -q '\(.\)\1\{4,\}' #Si algún carácter se repite más de 4 veces, se dará como fallido
    then                                         #para que por ejemplo IIIII no se de como un número romano válido
        fallido=1 
    fi
    if [ $fallido -eq 0 ]
    then
        correcto="romano" #$correcto pasa a ser "romano" para que se ejecute la conversión de romano a decimal
    fi
fi
case $correcto in
    romano) ROMANO_A_DECIMAL ;; #Se ejecuta la función ROMANO_A_DECIMAL
    decimal) DECIMAL_A_ROMANO ;; #Se ejecuta la función DECIMAL_A_ROMANO
    mayor) echo "El número $entrada es mayor que 1999." ;;
    *) echo $entrada no es ni un numero romano ni decimal. ;;
esac