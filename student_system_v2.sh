#!/usr/bin/env bash
#
# student_system.sh - Students management system
#
# Site:       https://github.com/edvaldo-lima
# Author:      Edvaldo Lima
# Maintenance: Edvaldo Lima
#
# ------------------------------------------------------------------------ #
#  This program wil do basic student management such as:
#  insert, delete and order the list of students.
#
#  Exemplos:
#      $ source student_system.sh
#      $ listUsers
# ------------------------------------------------------------------------ #
# History:
#
#   v1.0 11/19/2020, Edvaldo:
#       - DB file error treatment, removing blank lines and "#".
#       - Added function to list students.
#   v1.1 11/19/2020, Edvaldo:
#       - Added function to verify if student exists on Database.
#       - Added function Add a new student to Database.
#       - Added function Remove a student from Database.
#       - Added function to order the list of student alphabetically.
#   v1.2 11/24/2020, Edvaldo:
#       - Added graphical interface using dialog.
# ------------------------------------------------------------------------ #
# Tested on:
#   bash 5.0.17
# ------------------------------------------------------------------------ #

# ------------------------------- VARIÁVEIS ----------------------------------------- #
DB_FILE="studentdb.txt"
SEP=:
TEMP=temp.$$
# ------------------------------------------------------------------------ #

# ------------------------------- TESTES ----------------------------------------- #
[ ! -e "$DB_FILE" ] && echo "Error. Database file does not exist!"     && exit 1
[ ! -r "$DB_FILE" ] && echo "Error. No Read access to Database file!"  && exit 1
[ ! -w "$DB_FILE" ] && echo "Error. No Write access to Database file!" && exit 1
[ ! -x "$(which dialog)" ] && sudo apt install dialog 1> /dev/null 2>&1  # dialog installed ?
# -------------------------------------------------------------------------------- #

# ------------------------------- FUNÇÕES ----------------------------------------- #
ListStudents () {
  egrep -v "^#|^$" $DB_FILE | tr : ' ' > $TEMP
  dialog --title "List of students" --textbox "$TEMP" 20 55
  rm -f "$TEMP"
}


ValidateStudentExist () {
  grep -i -q "$1" "$DB_FILE"
}

Orderlist () {
  sort "$DB_FILE" > "$TEMP"
  mv "$TEMP" "$DB_FILE"
}
# ------------------------------- EXECUÇÃO ----------------------------------------- #
while :
do
  choice=$(dialog --title "Students management 2.0" \
                  --stdout \
                  --menu "Select one of the options below:" \
                  0 0 0 \
                  List   "List students of the system" \
                  Add    "Add a new student to the system" \
                  Remove "Remove a student of the system")
  [ $? -ne 0 ] && exit

  case $choice in
    List) ListStudents    ;;
    Add)
      lastUserId=$(egrep -v "^#|^$" "$DB_FILE" | tail -n 1 | cut -d $SEP -f 1)
      nextUserId=$((lastUserId+1))

      name=$(dialog --title "User Registration" --stdout --inputbox "Enter your name" 0 0)
      [ ! "$name" ] && exit 1

      ValidateStudentExist "$name" && {
        dialog --title "Registration Error!" --msgbox "User already exists in the system!" 10 40
        [ $? -ne 0 ] && continue
        #exit 1
      }

      course=$(dialog --title "User Registration" --stdout --inputbox "Name of the course" 0 0)
      [ $? -ne 0 ] && continue

      email=$(dialog --title "User Registration" --stdout --inputbox "Enter your E-mail" 0 0)
      [ $? -ne 0 ] && continue

      echo "$nextUserId$SEP$name$SEP$course$SEP$email" >> "$DB_FILE"
      dialog --title "SUCCESS!" --msgbox "Student successfully registered!" 10 40

      ListStudents
    ;;
    Remove)
      users=$(egrep -v "^#|^$" "$DB_FILE" | sort -h | cut -d $SEP -f 1,2 | sed 's/:/ "/;s/$/"/')
      user_id=$(eval dialog --stdout --menu \"Select a user to delete:\" 0 0 0 $users)
      [ $? -ne 0 ] && continue

      grep -i -v "^$user_id$SEP" "$DB_FILE" > "$TEMP"
      mv "$TEMP" "$DB_FILE"

      dialog --msgbox "User successfully removed!" 6 40
      ListStudents
    ;;
  esac
done
# ------------------------------------------------------------------------ #
