local widget = require( "widget" )

buttonSinglePlayer = nil
buttonPlayOthers = nil
buttonFacebook = nil

local function create_title_button(text, id, y)
	button = widget.newButton( {
		id = id,
		x = display.contentWidth / 2,
		y = y,
		emboss = true,
		label = text,
		fontSize = 44,
		labelColor = { default = {1, 0.9, 0.9}, over = { 0, 0, 0 } },
		width = 500,
		height = 125,
		shape = "roundedRect",
		cornerRadius = 15,
		fillColor = { default={ 0.93, 0.48, 0.01, 0.7 }, over={ 0.76, 0, 0.13, 1 } },
		strokeColor = { 1, 0.2, 0.2 },
		strokeRadius = 10
		} )
	return button
end

function setup_title_screen()
	display.newText( "Words with Rivals", display.contentWidth / 2, 150, "Arial", 64 )
	buttonSinglePlayer = create_title_button("Single Player", "single_player_button", 400)
	buttonPlayOthers = create_title_button("Play with rivals", "multi_player_button", 700)
	buttonFacebook = create_title_button("Find rivals on Facebook", "facebook_button", 1000)
end

