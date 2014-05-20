
--- Callback function for configuring LOVE.
function love.conf(t)
	t.window.width	= 1200
	t.window.height	= 680
	t.window.resizable = true
	t.window.minwidth = 320
	t.window.minheight = 240

	t.console		= false

	io.stdout:setvbuf("no")
end
