#!/bin/bash

#USUX_5 Bogdanovic Albert
#Zadanie 4 kalkulator
nawias=0
liczba=0
operator=0
prev=0
licz_nawias=0

my_help() {
 echo "Poprawne wywolanie: $0 arg op (arg op arg) ..."
   exit 1
}

check_brackets() {
if [[ $nawias -gt 1 || $nawias -lt 0 ]]; then
        echo -e "\033[33mbłędne|zagnieżdżone nawiasy\033[0m"
        exit 1    
elif [[ $prev = "(" ]]; then
 	echo -e "\033[33mbład syntaksu\033[0m"
 	exit 1
elif [[ $* = "(" && $operator = 1 ]]; then
	let 'operator=operator-1'
fi
}
check_number() {
 if [[ $prev = ")" || $liczba -gt 1 ]]; then
 	echo -e "\033[33mbład syntaksu\033[0m"
 	exit 1
 fi
 if [[ $operator = 1 ]]; then
 	let 'operator=operator-1'
 fi
}

check_operator() {
 if [[ $operator -gt 1 || $prev = 0 ]]; then
 	echo -e "\033[33mbład syntaksu\033[0m"
 	exit 1
 fi
 let 'liczba=liczba-1'
}

if [ $# -lt 3 ]; then
	my_help
fi

oper="+"
wartosc=0
wynik=0


for symbol in "$@"; do

	#sprawdzanie syntaksu
	if [ "$symbol" = "(" ]; then
		let 'nawias=nawias+1'
		check_brackets $symbol
		licz_nawias=1
	 elif [ "$symbol" = ")" ]; then
		let 'nawias=nawias-1'
		check_brackets $symbol
		licz_nawias=2
	 elif [[ $symbol =~ ^[0-9]*$ ]]; then
	
	 	let 'liczba=liczba+1'
		check_number $symbol
		wartosc=$symbol
	 elif [[ $symbol =~ ^[-+/*]$ ]]; then
	 	let 'operator=operator+1'
		check_operator $symbol
	 else
		echo -e "\033[33m program ma problem z $symbol\033[0m"
		exit 1
	fi
	
	#obliczenia dla pierwszego poziomu nawiasu)
	if [[ $licz_nawias = 1 ]] && [[ $liczba = 1 || $operator = 1 ]]; then
		var="$var$1"
	elif [[ $licz_nawias = 2 ]]; then
		n=`expr $var : '.*'`
		i=0
		wartosc="${var:i:1}"
		while [[ $i -lt $n-1 ]]; do
			if [[ ${var:i+1:1} = "*" ]]; then
			wartosc=`expr $wartosc \* ${var:i+2:1} 2>/dev/null`
			elif [[ ${var:i+1:1} = "/" && ${var:i+2:1} = 0 ]]; then
				echo -e "\033[33mdzielenie przez zero\033[0m"
 				exit 1
			else
			wartosc=`expr $wartosc ${var:i+1:1} ${var:i+2:1} 2>/dev/null`
			fi
			let "i=i+2"	
		done		
		var=""
		licz_nawias=0
	fi
	
	#obliczenia
	if [[ $operator = 1 && $licz_nawias = 0 ]]; then 
		 oper=$1
		 elif [[ $liczba = 1 && $licz_nawias = 0 ]]; then
			 if [[ $oper = "*" ]]; then
			 wynik=`expr $wynik \* $wartosc 2>/dev/null`
			 elif [[ $oper = "/" && $wartosc = 0 ]]; then
				echo -e "\033[33mdzielenie przez zero\033[0m"
 				exit 1
			 else
			 wynik=`expr $wynik $oper $wartosc 2>/dev/null`
			 fi
		fi	
		
shift
prev=$symbol
done

if [[ $nawias -ne 0 || $operator -ne 0 ]]; then
        echo -e "\033[33mBłąd syntaksu\033[0m"
        exit 1
fi


echo "Wynik: $wynik"

