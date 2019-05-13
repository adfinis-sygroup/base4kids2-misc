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

    # Concatenate the initial channel name
    # <KLASSENBEZEICHNUNG>-<KLASSEN-UNTERGRUPPE>[-<KLASSENZUSATZ>]-<KLASSE-SCHULJAHR>-<SCHULANLAGE>
    # Example: "MK KG-1-1-3-2018/2019-KG Bethlehemacker

    # Use an empty Klassenzusatz by default
    classSupplement["dash"]=""
    classSupplement["space"]=""

    # Check if we have a Mehrjahrgangsklasse
    # those need the Klassenzusatz value to be unique
    if ($13 ~ /^MK .*/) {
        classSupplement["dash"]="-" $15
        classSupplement["space"]=" " $15
    }

    displayPrefix=$13 " " $14 classSupplement["space"]
    displaySuffix=$18 " (" $10 ")"

    channelNamePrefix=$13 "-" $14 classSupplement["dash"] "-" $18 "-" $10
    #print "initial displayPrefix: " displayPrefix
    #print "initial channelNamePrefix:        " channelNamePrefix

    # Replace spaces, slashs, underscores and plus signs with dashes as they
    # are not supported within Mattermost channel names
    gsub(/( |_|\/|\+)/, "-", channelNamePrefix); 

    # Replace Umlauts, as they are not supported within Mattermost channel names
    gsub(/ä/, "ae", channelNamePrefix);
    gsub(/ö/, "oe", channelNamePrefix);
    gsub(/ü/, "ue", channelNamePrefix);

    # Remove multiple dashes
    gsub(/-{2,}/, "-", channelNamePrefix);

    # Remove dashes at the beginning or end of the name, as Mattermost doesn't
    # allow that.
    gsub(/^-|-$/, "", channelNamePrefix)

    # lower-case everything, as Mattermost is unable to handle uppercase letters
    channelNamePrefix=tolower(channelNamePrefix);


    channelNames["sus-lp"]=channelNamePrefix "-sus-lp"
    channelNames["lp"]=channelNamePrefix "-lp"
    channelNames["eb-lp"]=channelNamePrefix "-eb-lp"

    channelDisplay["sus-lp"]=displayPrefix " SUS & LP " displaySuffix
    channelDisplay["lp"]=displayPrefix " LP " displaySuffix
    channelDisplay["eb-lp"]=displayPrefix " EB & LP " displaySuffix

    for (i in channelDisplay) {
        if (length(channelDisplay[i]) > 64) {
            print "ERROR display name too long: " channelDisplay[i]
        } else {
            printf channelDisplay[i] ";"
        }

        if (length(channelNames[i]) > 64) {
            print "ERROR channel name too long: " channelNames[i]
        } else {
            printf channelNames[i] "\n"
        }
    }
}
