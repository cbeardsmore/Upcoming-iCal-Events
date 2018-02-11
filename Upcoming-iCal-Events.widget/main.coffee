# Author: Connor Beardsmore <connor.beardsmore@gmail.com>
# Last Modified: 23/06/16

# Bash command to pull events from icalBuddy
# Set +2 to how many days you want to show
# icalBuddy has more functionality that can be used here
command: "/usr/local/bin/icalBuddy -n eventsToday+2"

# Update is called once per hour
refreshFrequency: "1h"

# CSS styling
style: """
    top: 10px
    top: 1.3%
    right: 1%
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

# Initial render for heading
render: (output) -> """
    <div id="head"> Upcoming Events </div>
"""

# Update when refresh occurs
update: (output, domEl) ->
    lines = output.split('\n')
    bullet = lines[0][0]
    dom = $(domEl)

    # Show which calendar you pulled from before event name
    SHOW_CALENDER =  true
    # Show full date including time
    SHOW_DATE_TIME = false
    # Characters after this value will be replaced with ...
    MAX_CHARACTERS = 20

    # Filter out all lines that aren't event headers or dates
    lines = lines.filter (x) -> ( ( x.startsWith(bullet) ) ||
                         ( x.search('(today|tomorrow) at') != -1  ) )

    #Add No Events tag if nothing upcoming
    if ( lines.length == 0 )
        # Don't add tag twice
        if (! dom.text().includes("No Events"))
            dom.append(""" <div id="subhead"> No Events </div> """)
        return

    # Print subheadings and data for events
    for i in [0...lines.length-2]
        # Print today subheading
        header = ""
        if (lines[i+1].startsWith("    today"))
            if (! dom.text().includes('Today'))
                header = 'Today'
        # Print tomorrow subheading
        else if ( lines[i+1].startsWith("    tomorrow") )
            if (! dom.text().includes('Tomorrow'))
                header = 'Tomorrow'
        # Print later subheading
        else if ( lines[i+1].startsWith("    day after"))
            if (!dom.text().includes('Day After Tomorrow'))
                header = 'Day After Tomorrow'

        # If required add in the header
        if (header != "")
            dom.append("""<div id="subhead">#{header}</div> """)

        # Events start with bullet point
        if (lines[i][0] == bullet)
            nameAndCalendar = lines[i].split('(')
            name = nameAndCalendar[0].replace(bullet, '')
            calendar = nameAndCalendar[1].replace(')','')

            if ( name.length > MAX_CHARACTERS )
                name = name.substr(0, MAX_CHARACTERS) + "..."

            date = ((lines[i+1].split("at"))[1])
            date = "at" + date.substr(0,9)

            # Combine all fields
            final = name
            if (SHOW_CALENDER)
                final = calendar + " - " + final
            if (SHOW_DATE_TIME)
                final += date

            # Add this HTML to previous, only if it doesn't already exist
            if (!dom.text().includes(final))
                dom.append("""<div>#{final}</div>""")