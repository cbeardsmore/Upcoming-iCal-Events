# Author: Connor Beardsmore <connor.beardsmore@gmail.com>
# Last Modified: 22/03/18

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
    background-color rgba(black, 0.3)
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
"""

# Update when refresh occurs
update: (output, domEl) ->
    lines = output.split('\n')
    bullet = lines[0][0]
    dom = $(domEl)

    dom.empty()
    dom.append("""<div id="head"> Upcoming Events </div>""")

    # Show which calendar you pulled from before event name
    SHOW_CALENDER = false
    # Ignore specific calendars
    IGNORE_CALENDER = ['Holidays in Hong Kong']
    # Show full date including time
    SHOW_DATE_TIME = true
    # Characters after this value will be replaced with ...
    MAX_CHARACTERS = 50

    # Filter out all lines that aren't event headers or dates
    lines = lines.filter (x) -> ( ( x.startsWith(bullet) ) ||
                         ( x.search('(today|tomorrow)') != -1  ) )

    # console.log(lines)

    #Add No Events tag if nothing upcoming
    if ( lines.length == 0 )
        # Don't add tag twice
        if (! dom.text().includes("No Events"))
            dom.append(""" <div id="subhead"> No Events </div> """)
        return

    # Go over all events and append data into the DOM
    for i in [0...lines.length-1]
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

            calendar = 'calendar'

            # console.log(nameAndCalendar[1] == undefined)

            if nameAndCalendar[1] != undefined
                calendar = nameAndCalendar[1].replace(')','')

            if IGNORE_CALENDER.includes(calendar)
                continue

            if ( name.length > MAX_CHARACTERS )
                name = name.substr(0, MAX_CHARACTERS) + "..."

            date = ((lines[i+1].split("at"))[1])
            if ( date == undefined )
                date = "ALLDAY"
            else
                date = date.substr(0,9)

            # Combine all fields
            final = name
            if (SHOW_DATE_TIME)
                final = date + " - " + final
            if (SHOW_CALENDER)
                final = calendar + " - " + final


            # Add this HTML to previous
            dom.append("""<div>#{final}</div>""")
