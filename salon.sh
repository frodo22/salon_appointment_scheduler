#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_APPOINTMENT() {
    
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME| sed 's/ //g')

  while true 
  do 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    if [[ ! -z $CUSTOMER_PHONE ]]; then
      break
    fi
  done
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ ! -z $CUSTOMER_NAME ]]
  then
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME| sed 's/^ //')
    echo -e "\n$CUSTOMER_NAME_FORMATTED, I have your phone in my records."
  else
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME| sed 's/^ //')
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    if [[ $ADD_CUSTOMER == "INSERT 0 1" ]]; then
      echo -e "\nCustomer $CUSTOMER_NAME_FORMATTED with phone $CUSTOMER_PHONE is now in our records."
    fi
  fi
  
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
    
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") 

  SAVED_TO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $SAVED_TO_APPOINTMENTS == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi

}

MAIN_MENU() {

  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id limit 6")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nEnter the number of the service you want:"
  read SERVICE_ID_SELECTED

  if  [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?\n"
  else
    SERVICE_ID_OK=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_OK ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?\n"
    else
      GET_APPOINTMENT 
    fi
  fi
}

MAIN_MENU
