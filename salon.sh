#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n ------- Service salon -------- \n Available services: \n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo -e "\nWhich one you want to choose?\n"

  read SERVICE_ID_SELECTED;
  SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      if [[ $SERVICE_ID_INPUT = 0 ]]
      then 
        echo "Thank you. Goodbye"
      else
        SERVICE_MENU "No service exists with given ID"
      fi
    else
      # ask for user's number
      # echo $SERVICE_ID_INPUT
      echo -e "\nPlease enter your phone:\n"
      read CUSTOMER_PHONE
      #if phone correct
        #search for customer_id
        CUSTOMER_SEARCH_RESULT=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")
        #if not found customer name
        if [[ -z $CUSTOMER_SEARCH_RESULT ]]
        then
          #create customer
          echo -e "\nPlease enter your name:\n"
          read CUSTOMER_NAME
          CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        fi

        CUSTOMER_SEARCH_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
        if [[ -z $CUSTOMER_SEARCH_RESULT ]]
        then
          echo -e "\nError finding customer\n"
        else
          echo -e "\nEnter desired servicing time:\n"
          read SERVICE_TIME 
          INSERTION_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_SEARCH_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ -z $INSERTION_RESULT ]]
          then
            echo -e "\n Error inserting appointment"
          else 
            SERVICE_NAME_RAW=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
            SERVICE_NAME=$(echo $SERVICE_NAME_RAW | sed 's/ |/"/')
            CUSTOMER_NAME_RAW=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
            CUSTOMER_NAME=$(echo $CUSTOMER_NAME_RAW | sed 's/ |/"/')
            echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        fi
    fi
}


SERVICE_MENU

