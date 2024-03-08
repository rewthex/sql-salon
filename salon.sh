#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to the salon, how can I help you?\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  VALID_SERVICE_SELECTION=$($PSQL "SELECT name FROM services WHERE service_id = "$SERVICE_ID_SELECTED"")
  if [[ -z $VALID_SERVICE_SELECTION ]]
  then
    MAIN_MENU
  else
    SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED $VALID_SERVICE_SELECTION
  fi
}

SCHEDULE_APPOINTMENT() {
  echo -e "\nPlease enter a phone number."
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nPlease enter your name."
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null
  else
    echo -e "\nHello,$CUSTOMER_NAME.."
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like like to come in?"
  read SERVICE_TIME
  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$1', '$SERVICE_TIME')" > /dev/null
  echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU