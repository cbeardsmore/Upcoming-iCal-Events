# Author: Connor Beardsmore <connor DOT beardsmore AT gmail DOT com>
# Last Modified: 21/06/16

# Bash command to pull events from icalBuddy
# Set +2 to how many days you want to show
# icalBuddy has more functionality that can be used here
command: "/usr/local/bin/icalBuddy eventsToday+2"

# Update is called once per hour
refreshFrequency: "1h"

# CSS styling
style: """
    top: 10px
    top: 1.3%
    right: 17%
    color: black
    font-family: Helvetica
    background-color rgba(black, 0.5)
    padding 15px
    border-radius 5px

    div
        display: block
        color white
        font-size: 14px
        font-weight: 450
        text-align left

    #head
        font-weight: bold
        font-size 20px

    #subhead
        font-weight: bold
        font-size 16px
        border-bottom solid 1px clear
        padding-top 6px
        padding-bottom 3px
"""

# Initial render
render: (output) -> """
    <div id="head"> Upcoming Events </div>
"""

# Update when refresh occurs
update: (output, domEl) ->
    lines = output.split('\n')
    bullet = lines[0][0]
    newarray = []

    # Copy lines to new array, ignoring all location lines
    # This allows for easier tokenizing as array format is consistent
    for line in lines
        if ( line.indexOf("location") == -1 )
            newarray.push(line)

    # Check that events actually exist or not
    if ( lines.length < 2 )
            $(domEl).append(""" <div id="subhead"> No Events </div> """)
            return

    # If events exist, print subheadings and data
    for i in [0...newarray.length-2]

        # Print today subheading
        if ( newarray[i+1].indexOf("today") != -1 )
            if ($(domEl).text().indexOf('Today') == -1)
                $(domEl).append("""<div id="subhead"> Today </div> """)
        # Print tomorrow subheading
        else if ( newarray[i+1].indexOf("    tomorrow") != -1 )
            if ($(domEl).text().indexOf('Tomorrow') == -1)
                $(domEl).append(""" <div id="subhead"> Tomorrow </div> """)
        # Print later subheading
        else if ( newarray[i+1].indexOf("after") != -1 )
            if ($(domEl).text().indexOf('Day After Tomorrow') == -1)
                $(domEl).append(""" <div id="subhead"> Day After Tomorrow </div> """)

        # Only print event newarray, starting with a bullet point
        if (newarray[i][0] == bullet)
            # Tokenize icalBuddy output string
            name_and_calendar = newarray[i].split('(')
            name = name_and_calendar[0].substr(1)
            if ( name.length > 25 )
                name = name.substr(0,25) + "..."
            date = ((newarray[i+1].split("at"))[1])
            date = date.substr(0,8)
            calendar = name_and_calendar[1].replace(')','')
            # Combine all fields
            final = calendar + " - " + name + " at " + date

            # Add this HTML to previous
            $(domEl).append("""
            <div>
                #{final}
            </div>
            """)
