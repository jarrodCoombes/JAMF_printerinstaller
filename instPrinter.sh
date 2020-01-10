#!/bin/sh

# Printer install script


function valid_ip()
{
#Checks to see if the IP entered is a valid IP address. This does not verify that it is the correct IP though.
#Source: Mitch Frazier - https://www.linuxjournal.com/content/validating-ip-address-bash-script
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if valid_ip $5; then 
	printerURI="lpd://$5"
else
	echo "Invalid IP. Exiting"
	exit 1
fi


#Setup Script Variables and convert some of them to uppercase
printerName=$(echo "$4" | awk '{print toupper($0)}')
printerLocation="$6"
model=$(echo "$7" | awk '{print toupper($0)}')
hp=FALSE


#Determine the correct PPD to use.
case $model in
	HL-5450DN)
		ppdFile="Brother HL-5450DN series CUPS.gz"
		;;
	HL-L5100DN)
		ppdFile="Brother HL-L5100DN series CUPS.gz"
		;;		
	HL-3170CDW)
		ppdFile="Brother HL-3170CDW series CUPS.gz"
		;;
	M452)
		ppdFile="HP Color LaserJet Pro M452.gz"
		hp=TRUE
		;; 
	CP5520)
		ppdFile="HP Color LaserJet CP5520 Series.gz"
		hp=TRUE
		;;
	MX-C312)
		ppdFile="SHARP MX-C312.PPD.gz"
		;;
	MX-M754)
		ppdFile="SHARP MX-M754N.PPD.gz"
		;;
	MX-905)
		ppdFile="SHARP MX-M905.PPD.gz"
		;;
	MX-5070)
		ppdFile="SHARP MX-M5070.PPD.gz"
		;;
	MX-6070)
		ppdFile="SHARP MX-M6070.PPD.gz"
		;;
	*)
		echo "Unrecognized model. Exiting."
		exit 2
		;;
esac

#Checking to see that the driver is installed, if not we trigger the printer driver install
#policy in Jamf
if [ -f "/Library/Printers/PPDs/Contents/Resources/$ppdFile" ]; then
    echo "The Driver is installed."
    echo ""
	else 
    	echo "Driver is not installed."
    	echo ""
		echo "Installing Brother and Sharp Drivers now..."
    	
    	jamf policy -event printerDriversBS
    
    	if $hp; then
    		echo ""
    		echo "Installing HP Drivers now..."
			osascript -e 'display notification "Installing HP Drivers, this may take some time" with title "Print Driver Installation"'
    		jamf policy -event printDriversHP
		fi    
    	echo "Done"
    	echo ""
fi

echo "Using this lpadming command to install the printer:"
echo ""
echo "lpadmin -p '$printerName' -v '$printerURI' -L '$printerLocation' -P '/Library/Printers/PPDs/Contents/Resources/$ppdFile' -E -o printer-is-shared=false -o PageSize=Letter"
echo ""

echo "Running the Command...."
lpadmin -p "$printerName" -v "$printerURI" -L "$printerLocation" -P "/Library/Printers/PPDs/Contents/Resources/$ppdFile" -E -o printer-is-shared=false -o PageSize=Letter
echo ""

# -o OptionTray=2Cassette -o LargeCapacityTray=Installed -o Finisher=FinKINGB -o Duplex=None -o ColorModel=Gray

echo "Done"

