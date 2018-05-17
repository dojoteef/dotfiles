#!/usr/bin/osascript
set keychainPassword to do shell script "security find-generic-password -wa " & (system attribute "USER")

tell application "System Events"
	repeat while exists (processes where name is "SecurityAgent")
		tell process "SecurityAgent"
			try
				set value of text field 1 of window 1 to keychainPassword
				click button "OK" of window 1
			on error
				-- do nothing and skip
			end try
		end tell
		delay 0.2
	end repeat
end tell
