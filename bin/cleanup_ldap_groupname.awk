#!/bin/awk -f

# The script expects semi-colon separated values

BEGIN {
    FS = ";"
}
 
{
    # Skip the header line
    if ($1 == "Klasse_Bezeichnung") { next; }

    # Skip lines with empty class fields
    if ($1 == "") { next; }

    # Concatenate the initial group name
    # <KLASSENBEZEICHNUNG>_<KLASSEN-UNTERGRUPPE>[_<KLASSENZUSATZ>]_<KLASSE-SCHULJAHR>_<SCHULANLAGE>
    # Example: "MK KG_1_1-3_2018/2019_KGä1+2"

    # Replace dash in year with underscores
    gsub(/\//, "-", $18);

    # Use an empty Klassenzusatz by default
    classSupplement=""

    # Check if we have a Mehrjahrgangsklasse
    # those need the Klassenzusatz value to be unique
    if ($13 ~ /^MK .*/) {
        classSupplement="_" $15
    }

    groupName=$13 "_" $14 classSupplement "_" $18 "_" $10
    #print "initial groupName: " groupName

    # Replace spaces, slashs and plus signs with underscores
    gsub(/( |\/|\+)/, "_", groupName);

    # Replace Umlauts
    gsub(/ä/, "ae", groupName);
    gsub(/ö/, "oe", groupName);
    gsub(/ü/, "ue", groupName);

    # Remove multiple underscores
    gsub(/_{2,}/, "_", groupName);

    # Remove underscores at the beginning or end of the name
    gsub(/^_|_$/, "", groupName)

    # Remove sequences which are consequences of empty elements
    gsub(/_-_/, "_", groupName)

    # Check length
    if (length(groupName) > 64) { print "ERROR too long: " groupName}
    else { print groupName };
}
