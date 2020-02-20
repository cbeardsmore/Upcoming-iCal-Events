# Author: Connor Beardsmore <connor.beardsmore@gmail.com>
# Last Modified: 22/03/18

# Customisations
# Refresh Frequency
REFRESH_FREQUENCY = "1h"
# Number of days shown from today.
NO_DAYS_TO_SHOW = 2
# Show which calendar you pulled from before event name.
SHOW_CALENDER = false
# Ignore specific calendars.
IGNORE_CALENDERS = [
    'name/UUID of thecalendar to ignore',
    'other calendar etc'
]
# Show full date including time.
SHOW_DATE_TIME = true
# Characters after this value will be replaced with ...
MAX_CHARACTERS = 50
# Use date for day after tomorrow.
USE_LATER_DATE = false

# Construct bash command using options.
# icalBuddy has more functionality that can be used here.
# Refer to https://hasseg.org/icalBuddy/man.html
executablePath = "/usr/local/bin/icalBuddy "
baseCommand = ' eventsToday' + '+' + NO_DAYS_TO_SHOW
options = "-n -eed -tf '%I:%M %p' "
if IGNORE_CALENDERS
    options = options + '-ec ' + IGNORE_CALENDERS.join(',')

# Bash command to pull events from icalBuddy
command: executablePath + options + baseCommand

# Update is called once per hour
refreshFrequency: REFRESH_FREQUENCY

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
"""

# Update when refresh occurs
update: (output, domEl) ->
    dateRegex = '\\d{2}-[a-zA-Z]{3}-\\d{4}'
    lines = output.split('\n')
    bullet = lines[0][0]
    dom = $(domEl)
    dom.empty()
    dom.append("""<div id="head"> Upcoming Events </div>""")

    # Filter out all lines that aren't event headers or dates
    lines = lines.filter (x) -> (
      ( x.startsWith(bullet) ) ||
      ( x.search('(today|tomorrow)') != -1  ) ||
      ( x.search(dateRegex) != -1  )
    )

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
        day = ''
        if (lines[i+1].startsWith("    today"))
            if (! dom.text().includes('Today'))
                header = 'Today'
        # Print tomorrow subheading
        else if ( lines[i+1].startsWith("    tomorrow") )
            if (! dom.text().includes('Tomorrow'))
                header = 'Tomorrow'
        # Print day after tomorrow subheading
        else if ( lines[i+1].startsWith("    day after"))
            if (!dom.text().includes('Day After Tomorrow'))
                header = 'Day After Tomorrow'
        # Print later subheading
        else if ( lines[i+1].search(dateRegex) != -1 )
            day = lines[i+1].trim().substr(0,11)
            dayHeader = if USE_LATER_DATE then lines[i+1].trim().substr(0,11) else 'Later'
            if (!dom.text().includes(dayHeader))
                header = dayHeader

        # If required add in the header
        if (header != "")
            dom.append("""<div id="subhead">#{header}</div> """)

        # Events start with bullet point
        if (lines[i][0] == bullet)
            nameAndCalendar = lines[i].split('(')

            if nameAndCalendar.length < 2
                continue

            name = nameAndCalendar[0].replace(bullet, '')
            calendar = 'No Calendar'

            if nameAndCalendar[1] != undefined
                calendar = nameAndCalendar[1].replace(')','')

            if ( name.length > MAX_CHARACTERS )
                name = name.substr(0, MAX_CHARACTERS) + "..."

            datePrefix = if (day && not USE_LATER_DATE) then day + ' ' else ''

            date = ((lines[i+1].split("at"))[1]) or 'All day'

            # Combine all fields
            final = name
            if SHOW_DATE_TIME
                final = datePrefix + date + " - " + final
            if SHOW_CALENDER
                final = calendar + " - " + final

            # Add this HTML to previous
            dom.append("""<div>#{final}</div>""")
