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
    right: 12%
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
    newarray = []
    dom = $(domEl)

    # Show which calendar you pulled from
    showCalendar =  true
    maxCharacters = 25

    # Take out all lines that aren't event headers or dates
    for line in lines
        if ( line.startsWith(bullet))
            newarray.push(line)
        if ( line.search('(today|tomorrow) at') != -1 )
            newarray.push(line)

    #Add No Events tag if nothing upcoming
    if ( newarray.length == 0 )
        # Don't add tag twice
        if (dom.text().includes("No Events") == -1)
            dom.append(""" <div id="subhead"> No Events </div> """)
        return

    # Print subheadings and data for events
    for i in [0...newarray.length-2]
        # Print today subheading
        if (newarray[i+1].startsWith("    today"))
            if (! dom.text().includes('Today'))
                dom.append("""<div id="subhead">Today</div> """)
        # Print tomorrow subheading
        else if ( newarray[i+1].startsWith("    tomorrow") )
            if (! dom.text().includes('Tomorrow'))
                dom.append(""" <div id="subhead">Tomorrow</div> """)
        # Print later subheading
        else if ( newarray[i+1].startsWith("    day after"))
            if (!dom.text().includes('Day After Tomorrow'))
                dom.append(""" <div id="subhead">Day After Tomorrow</div> """)

        # Events start with bullet point
        if (newarray[i][0] == bullet)
            nameAndCalendar = newarray[i].split('(')
            name = nameAndCalendar[0].replace(bullet, '')
            calendar = nameAndCalendar[1].replace(')','')

            if ( name.length > maxCharacters )
                name = name.substr(0,maxCharacters) + "..."

            date = ""
            # Magic regex
            if (/(((0[1-9])|(1[0-2])):([0-5])(0|5)\s(A|P)M)/.test(newarray[i+1]))
                date = ((newarray[i+1].split("at"))[1])
                date = "at" + date.substr(0,9)

            # Combine all fields
            final = name + date
            if (showCalendar)
                final = calendar + " - " + final

            # Add this HTML to previous, only if it doesn't already exist
            if (!dom.text().includes(final))
                dom.append("""<div>#{final}</div>""")
