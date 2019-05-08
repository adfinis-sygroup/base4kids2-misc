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

    # Concatenate the initial team name
    # <KLASSE-BEZEICHNUNG>-<KLASSE-UNTERGRUPPE>[-<KLASSENZUSATZ>]-<SCHULGEBAEUDE-KURZBEZEICHNUNG>
    # Example: "MK KG-1-KGä1+2"

    # Use an empty Klassenzusatz by default
    classSupplement=""

    # Check if we have a Mehrjahrgangsklasse
    # those need the Klassenzusatz value to be unique
    if ($13 ~ /^MK .*/) {
        classSupplement="-" $15
    }

    teamName=$13 "-" $14 classSupplement "-" $4
    #print "initial teamName: " teamName

    # Remove the "MK " (Mehrjahrgangsklassen) or "HPS " prefixes
    gsub(/^(MK|HPS) ?/, "", teamName); 

    # Replace spaces, slashs, underscores and plus signs with dashes as they
    # are not supported by mattermost team names
    gsub(/( |_|\/|\+)/, "-", teamName); 

    # Replace Umlauts, as mattermost can't handle them - only use "a" instead
    # of "ae" to save characters (15 is the maximum in mattermost)
    gsub(/ä/, "a", teamName);
    gsub(/ö/, "o", teamName);
    gsub(/ü/, "u", teamName);

    # Remove multiple dashes
    gsub(/-{2,}/, "-", teamName);

    # Remove dashes at the beginning or end of the name, as mattermost doesn't
    # allow that.
    gsub(/^-|-$/, "", teamName)

    # lower-case everything, as mattermost is unable to handle uppercase letters
    teamName=tolower(teamName);

    # Check length
    if (length(teamName) > 15) { print "ERROR too long: " teamName}
    else { print teamName };
}
