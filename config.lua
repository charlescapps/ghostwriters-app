application =
{

	content =
	{
		width = 750,
		height = 1334, 
		scale = "letterBox",
		fps = 30,
		
		imageSuffix =
		{
            ["@2x"] = 1.5
		}
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
