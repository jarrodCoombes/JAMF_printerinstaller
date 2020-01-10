JAMF Printer Install Script
===========================

A quick script to create policies that install printers via the self service portal.

Requirements
------------

Not much needed here other than a JAMF Pro server.

Usage
-----

Install this script in the scripts section of your jamf server. Set the Options section set your parameter labels as:

Parameter 4 - Printer Name
Parameter 5 - Printer IP
Parameter 6 - Location
Parameter 7 - Model (HL-3170CDW, HL-5450DN, HL-L5100DN, M452, CP5520, MX-C312, MX-M754, MX-905, MX-5070, MX-6070)

Then create a policy and add the script as the payload with the various parameters filled out.


