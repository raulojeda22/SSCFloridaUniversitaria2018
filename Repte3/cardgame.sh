##FUNCIONES##
INICIO(){
    clear
    BANNER
    read -p "Introduce el nombre de usuario: " user
    while [ $checkNumber -eq 0 ] #Sirve para que puedas volver a introducir el saldo si no has introducido un número
    do
        read -p "Introduce el saldo con el que desea empezar: " saldo
        ES_UN_NUMERO $saldo #Función que comprueba si la introducción es un número
    done
}
MESA(){
    clear 
    BANNER
    if [ $fase -lt 3 ] #Cartas ocultas antes de la fase 3
    then 
        cartasCrupier='OCULTAS'
    elif [ $fase -lt 5 ] #Se muestran las 2 primeras cartas del crupier
    then
        cartasCrupier="${cartas0[@]:0:2}"
    else #Se muestran las 3 cartas del crupier
        cartasCrupier="${cartas0[@]}"
    fi
    echo "/ . . \ Crupier: $cartasCrupier"
    echo "(  v   )"
    echo "\__u__/"
    echo "(  __)  (__  )"
    echo "| (        ) |"
    echo "| |        | |"
    echo "Apuesta: $apuesta  "
    echo "| |        | |"
    echo "| (__    __) |"
    echo "(____)  (____)"
    echo "/  _ \ $user: ${cartas1[@]}"
    echo "(     )"
    echo "\____/"
    echo "Saldo: $saldo"
}
PARTIDA(){ #La partida consta de 5 fases, que se corresponden a los puntos del enunciado.
    FASE1 #1-2
    FASE2 #3-4
    if [ $retirada -eq 0 ]; then #Si se ha retirado el jugador no es necesario realizar estas fases
        FASE3 #5-6
    fi
    if [ $retirada -eq 0 ]; then
        FASE4 #7-8
    fi
    FASE5 #9
}
FASE1(){ #1-2
    fase=1 #Para detectar en que fase se encuentra el usuario
    VALOR_APUESTA 1 #Se apuesta 1 unidad siempre
    REPARTIR_CARTAS #Se reparten las cartas
    MESA #Se muestra la mesa
}
FASE2(){ #3-4
    fase=2
    INCREMENTAR_APUESTA #Se pide al usuario si quiere incrementar la apuesta
}
FASE3(){ #5-6
    fase=3
    MESA #Se muestra la mesa
    echo "Se doblará su apuesta." 
    INCREMENTAR_APUESTA #Se incrementará la apuesta al doble de la apuesta actual
}
FASE4(){ #7-8
    fase=4
    MESA #Se muestra la mesa
    CALCULAR_VALOR #Se calcula el valor de 2 cartas del crupier y 3 del usuario
    COMPORTAMIENTO_ARTIFICIAL #La máquina calcula que es más beneficioso para ella
}
FASE5(){ #9
    fase=5
    CALCULAR_VALOR #Se calcula el valor de 3 cartas del crupier y 3 del usuario
    COMPROBAR_VICTORIA #Se comprueba el vencedor
}
INCREMENTAR_APUESTA(){
    next=0 #Por si se hace una introducción errónea que no salga del bucle
    checkNumber=0 #Resetea a 0 la comprobación de si es un número o una string
    while [ $next -eq 0 ]
    do
        read -p "¿Desea continuar?[S/n]: " continuar #Se pregunta si desea continuar
        case $continuar in
            [sS])
                while [ $checkNumber -eq 0 ]
                do
                    if [ $fase -eq 2 ]
                    then
                        read -p "Cantidad de augmento de apuesta: " masApuesta
                    elif [ $fase -eq 3 ]
                    then
                        masApuesta=$apuesta
                    fi
                    ES_UN_NUMERO $masApuesta #Funcion que comprueba si lo introducido es un número
                done
                VALOR_APUESTA $masApuesta #Funcion que suma el primer parámetro a la apuesta y lo resta al saldo
                next=1
            ;;
            [nN])
                retirada=1 #El usuario decide retirarse
                next=1
            ;;
            *)
                echo "Introducción errónea, vuelvalo a intentar."
            ;;
        esac
    done
}
CALCULAR_VALOR(){
    if [ $fase -eq 4 ] #Si está en la fase 4 solo muestra 2 cartas del crupier
    then
        limit=2
    elif [ $fase -eq 5 ] #Si está en la fase 5 las muestra todas
    then
        limit=3
    fi
    for contador in {0..1} #Para calcular el valor en el crupier(0) y en el usuario(1)
    do
        eval cartas='$'{cartas$contador[@]:0:$limit}
        total=0 #Suma del valor
        for carta in $cartas
        do
            valor=${carta::-1} #Quita el palo de la string
            total=$total+$valor #Lo almacena $total
        done
        if [ $contador -eq 1 ] && [ $limit -eq 2 ] #Si es el usuario y solo mira dos cartas le añade una más
        then
            total=$total+${cartas1[2]::-1} #Quita el palo de la string
        fi
        eval total$contador=$(($total)) #Realiza la suma
    done
    let resultado=$total1-$total0 #La diferencia entre $total1(valor cartas usuario) y $total0(crupier) servirá más adelante
}
REPARTIR_CARTAS(){
    contador=0
    limite=2
    while [ $contador -lt $limite ] #2 jugadores, el crupier y el usuario
    do
        contadorCartas=0
        limiteCartas=3
        while [ $contadorCartas -lt $limiteCartas ] #Se reparten 3 cartas
        do
            numero=$(($RANDOM%12+1)) #Se escoje un número aleatorio entre 1 y 12 para el valor de la carta
            valorPalo=$((RANDOM%4+1)) #Se escoje un número aleatorio entre 1 y 4 para el palo
            case $valorPalo in
                1)  palo=$pica      ;; #Le añade un palo diferente dependiendo del número resultante
                2)  palo=$corazon   ;;
                3)  palo=$diamante  ;;
                4)  palo=$trebol    ;;
            esac
            carta=$numero$palo
            inarray=$(echo ${totalCartas[@]} | grep -o "$carta" | wc -w) #Busca que el valor nuevo no se encuentre en la "array" con todas las cartas añadidas
            if [ $inarray -eq 0 ] #Si no está en la "array"              #para que no  hayan cartas repetidas
            then
                eval cartas$contador[$contadorCartas]=$carta #Añade la carta a la array que depende de que usuario es en $contador y de el número de la carta en $contadorCartas
                eval totalCartas+=$carta #Añade la carta a la "array con todas las cartas"
                let contadorCartas=$contadorCartas+1 #Augmenta el valor del contador de cartas
            fi
        done
        let contador=$contador+1 #Augmenta el valor del contador de usuarios
    done
}
COMPORTAMIENTO_ARTIFICIAL(){
    if [ $resultado -lt 1 ]
    then
        resultado=1 #Si el resultado es menor de 1 lo convierte a 1 para poder realizar la operación
    fi
    let operacion=$resultado*100/12 #Calcula que porcentaje tiene de salir perdiendo la máquina
    maquina=$(($RANDOM%$operacion)) #Calcula un número aleatorio entre 0 y el porcentaje de posibilidades de perder
    if [ $maquina -ge 60 ] #Si el número aleatorio es mayor que 60 es porque tenia bastantes posibilidades de perder y se retira
    then
        read -p "El crupier se retira. Pulse intro." 
        ganador=1
    else #Si sale un número menor que 60 hay más posibilidades de que pueda ganar y lo intenta
        read -p "El crupier continua. Pulse intro."
        ganador=0
    fi
    #Que la máquina piense con un poco de aleatoriedad es para que no responda siempre de la misma manera ante los mismos valores,
    #añadirle algo de diversión al factor de realizar esta decisión y que sea un poco "tonta" y pueda realizar decisiones que puede que no le convengan del todo.
}
COMPROBAR_VICTORIA(){
    if [ $retirada -eq 1 ] #Si el usuario ha decidido retirarse ha perdido esta partida
    then
        echo -n "Ha perdido. "
        let ganadasCrupier=$ganadasCrupier+1
    elif [ $ganador -eq 0 ]
    then
        MESA
        if [ $resultado -gt 0 ] #Si la diferencia entre el valor de las cartas del usuario y del crupier es mayor que 0 el usuario ha ganado
        then
            echo -n "Ha ganado. "
            let saldo=$saldo+$apuesta*2 #Se multiplica por 2 su apuesta y se le suma al saldo actual
            let ganadasUser=$ganadasUser+1 #Se suma una partida ganada
        elif [ $resultado -eq 0 ] #Si la diferencia es igual hay empate
        then
            echo -n "Ha empatado, le devolvemos su apuesta. "
            let saldo=$saldo+$apuesta #Se suma su apuesta al saldo actual para que no tenga efecto
            let empatadas=$empatadas+1 #Se suma una partida empatada
        else #Si la diferencia es menor que 0 ha perdido el usuario
            echo -n "Ha perdido. "
            let ganadasCrupier=$ganadasCrupier+1  #Se suma una partida perdida y no se le suma la apuesta
        fi
    else #Si la máquina ha decidido rendirse
        echo -n "Has ganado. " 
        let saldo=$saldo+$apuesta*2 #Se multiplica por 2 su apuesta y se le suma al saldo actual
        let ganadasUser=$ganadasUser+1 #Se suma una partida ganada
    fi
    let jugadas=$jugadas+1 #Siempre se suma una partida jugada
    read -p "Pulse intro."
}
VALOR_APUESTA(){
    nuevaApuesta=$1
    if [ $nuevaApuesta -gt $saldo ] #Para comprobar que la apuesta no es mayor a su saldo
    then
        echo "La cantidad apostada es mayor que su saldo, apuestas todo lo que te queda."
        read -p "Pulse intro."
        nuevaApuesta=$saldo #La apuesta pasa a ser el saldo actual porque es el máximo
    fi
    let saldo=$saldo-$nuevaApuesta #Le resta la cantidad al saldo
    let apuesta=$apuesta+$nuevaApuesta #Suma la cantidad a la apuesta
}
ES_UN_NUMERO(){
    if [ "$1" -ge "1" ] 2>/dev/null #Si es un numero mayor o igual a 1
    then
        checkNumber=1 #Pasa a ser 1 para que continue el script
    else
        echo "$1 no es un número mayor o igual a 1, vuelvelo a intentar..."
        checkNumber=0 #Si es 0 tendrá que volver a introducir un valor
    fi
}
BANNER(){ 
    echo '.------..------..------..------..------..------..------..------.
|C.--. ||A.--. ||R.--. ||D.--. ||G.--. ||A.--. ||M.--. ||E.--. |
| :/\: || (\/) || :(): || :/\: || :/\: || (\/) || (\/) || (\/) |
| :\/: || :\/: || ()() || (__) || :\/: || :\/: || :\/: || :\/: |
| .--.C|| .--.A|| .--.R|| .--.D|| .--.G|| .--.A|| .--.M|| .--.E|
`------.`------.`------.`------.`------.`------.`------.`------.'
}
##VARIABLES##
retirada=0 #Bool para comprobar si el jugador se retira
checkNumber=0 #Comprobar si la introducción es un número
apuesta=0 #Apuesta inicial
pica="♠" #Palos
corazon="♥"
diamante="♦"
trebol="♣"
total0=0 #Puntuacion crupier
total1=0 #Puntuacion usuario
ganador=0 #Detectar si el crupier se retira
ganadasCrupier=0 #Partidas ganadas por el crupier
ganadasUser=0 #Partidas ganadas por el usuario
empatadas=0 
jugadas=0 
##MENU##
INICIO #Función para introducir el nombre y el saldo
while [ $saldo -gt 0 ]
do
    clear
    BANNER
    echo "Usuario: $user Saldo: $saldo"
    echo "Balance: Partidas: $jugadas Ganadas: $ganadasUser Perdidas: $ganadasCrupier Empatadas: $empatadas"
    echo "1.Jugar"
    echo "2.Salir"
    read -p "¿Qué desea hacer? Escriba el número de su elección: " eleccion
    case $eleccion in
        1)  PARTIDA ;;
        2)  exit    ;;
        *)  read -p "Introducción errónea, vuelvalo a intentar"    ;;
    esac
    apuesta=0 #Se resetean los valores esenciales de la partida a 0 para que no se guarde el valor que han adquirido en la partida anterior
    retirada=0
    total0=0
    total1=0
    ganador=0
done
echo "$user se ha quedado sin saldo tras 
Partidas: $jugadas Ganadas: $ganadasUser Perdidas: $ganadasCrupier Empatadas: $empatadas"