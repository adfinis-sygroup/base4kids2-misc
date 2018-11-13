#!/bin/awk -f

# The script expectes semi-colon separated values

BEGIN {
    FS = ";"
}
 
{
    # Skip the header line
    if ($1 == "Klasse_Bezeichnung") { next; }

    # Skip lines with empty class fields
    if ($1 == "") { next; }

    # Concatenate the initial group name
    # <KLASSE-BEZEICHNUNG>_<KLASSE-UNTERGRUPPE>_<KLASSE-SCHULJAHR>_<SCHULANALGE>
    # Example: "MK KG_1_2018/2019_KGä1+2"

    # Replace dash in year with underscores
    gsub(/\//, "-", $3);

    gruppenName=$1 "_" $2 "_" $3 "_" $10
    #print "initial gruppenName: " gruppenName

    # Replace spaces, slashs and plus signs with underscores
    gsub(/( |\/|\+)/, "_", gruppenName);

    # Replace Umlauts
    gsub(/ä/, "ae", gruppenName);
    gsub(/ö/, "oe", gruppenName);
    gsub(/ü/, "ue", gruppenName);

    # Remove multiple underscores
    gsub(/_{2,}/, "_", gruppenName);

    # Remove underscores at the beginning or end of the name
    gsub(/^_|_$/, "", gruppenName)

    # Remove sequences which are consequences of empty elements
    gsub(/_-_/, "_", gruppenName)

    # lower-case everything
    gruppenName=tolower(gruppenName);

    # Check length
    if (length(gruppenName) > 64) { print "ERROR too long: " gruppenName}
    else { print gruppenName };
}
