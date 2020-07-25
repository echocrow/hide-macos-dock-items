on run argv
	main(argv)
end run

on main(itemNames)
	set wasMuted to output muted of (get volume settings)

	if not wasMuted then set volume with output muted

	repeat with itemName in itemNames
		try
			removeDockItem(itemName)
		end try
	end repeat

	-- The "Remove from Dock" sound effect is played back asynchronously. Thus a
	-- short delay before unmuting is necessary, otherwise the sound effect will
	-- be audible.
	delay 0.5

	if not wasMuted then set volume without output muted
end main

on removeDockItem(itemName)
	tell application "System Events"
		tell UI element itemName of list 1 of process "Dock"
			perform action "AXShowMenu"
			click menu item "Remove from Dock" of menu 1
		end tell
	end tell
end removeDockItem
