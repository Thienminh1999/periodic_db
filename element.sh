#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit 0
fi

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]; then
    ELEMENT_RESULT=$($PSQL "select atomic_number, symbol, name from elements where atomic_number = $1 ;")
    if [[ -z $ELEMENT_RESULT ]]
    then
      echo -e "I could not find that element in the database."
      exit 0
    fi
  elif [[ $1 =~ ^[a-zA-Z]+$ ]]; then
    ELEMENT_RESULT=$($PSQL "select atomic_number, symbol, name from elements where symbol = '$1' or name = '$1';")
    if [[ -z $ELEMENT_RESULT ]]
    then
      echo -e "I could not find that element in the database."
      exit 0
    fi
  else
    echo -e "I could not find that element in the database."
  fi

  if [[ -z ELEMENT_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME <<< "$ELEMENT_RESULT" 
    IFS=" "
    PROPERTIES_RESULT=$($PSQL "select type_id, atomic_mass, melting_point_celsius, boiling_point_celsius from properties where atomic_number = $ATOMIC_NUMBER;")
    # echo $ATOMIC_NUMBER
    IFS='|' read -r TYPE_ID MASS MELTING_POINT BOILING_POINT <<< "$PROPERTIES_RESULT"
    IFS=" "

    TYPE_RESULT=$($PSQL "select type from types where type_id = $TYPE_ID")
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_RESULT, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
