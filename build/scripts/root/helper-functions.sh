# -- replaceConfigFileParam ----------------------------------------------------
# Replaces var=value in a file with var=new_value
# usage: configFileReplaceParam FILENAME VAR NEW_VALUE
#   FILENAME - path to configuration file
#   VAR - var to replace
#   VALUE - new value
# source: https://stackoverflow.com/questions/5955548/how-do-i-use-sed-to-change-my-configuration-files-with-flexible-keys-and-values
# ------------------------------------------------------------------------------

replaceConfigFileParam () {
   awk -v var="$2" -v new_val="$3" 'BEGIN{FS=OFS="="}match($1, "^\\s*" var "\\s*") {$2= new_val}1' "$1" > "$1.tmp"
   mv "$1.tmp" "$1"
}