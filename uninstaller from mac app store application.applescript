property needSetup : true
property yourAppName : "uninstaller_from_mac_app_store_application"

on run
	set a to choose file
	set aa to {a}
	open (aa) of me
end run

on open these_items
	if needSetup then
		try
			deletePassword(yourAppName)
		end try
		
		makePassword(yourAppName)
		
		notification("Stored password to €"Keychain Access€"")
		set needSetup to false
	end if
	if needSetup is false then
		repeat with i from 1 to the count of these_items
			set this_item to item i of these_items
			
			try
				set sudoPass to pullPassword(yourAppName)
				
				tell application "System Events"
					set urlPath to URL of this_item
				end tell
				
				set shellText to "sudo uninstall " & urlPath
				set shellResult to do shell script shellText password sudoPass with administrator privileges
				set shellResult to last paragraph of shellResult
				notification(shellResult)
			on error -- ƒpƒXƒ[ƒh‚ªˆø‚«o‚¹‚È‚©‚Á‚½‚çÝ’è‚ðƒŠƒZƒbƒg
				deletePassword(yourAppName)
				set needSetup to true
				notification("Password reset")
			end try
			
		end repeat
	end if
end open

on notification(theText)
	try
		display notification theText
	on error
		tell application "System Events"
			display dialog theText giving up after 2 buttons {"OK"} default button 1
		end tell
	end try
end notification

on dda(theText, defaultAnswer)
	tell application "System Events"
		display dialog theText default answer defaultAnswer buttons {"OK"} default button 1
	end tell
	return text returned of result
end dda

on ddb(theText, buttonList)
	tell application "System Events"
		display dialog theText as text buttons buttonList default button length of buttonList
	end tell
	return button returned of result
end ddb

on makePassword(appName)
	set usrAccount to (do shell script "whoami")
	set usrPassword to dda("Input Your Password(Store to €"Keychain Access€")", "")
	set shellTxt to "security add-generic-password -s " & appName & " -a " & usrAccount & " -p " & usrPassword
	do shell script shellTxt
end makePassword

on pullPassword(appName)
	set shellTxt to "security 2>&1 >/dev/null find-generic-password -gs " & appName & " | ruby -e 'print $1 if STDIN.gets =~ /^password: €"(.*)€"$/'"
	do shell script shellTxt
end pullPassword

on deletePassword(appName)
	set shellTxt to "security delete-generic-password -s " & appName
	do shell script shellTxt
end deletePassword