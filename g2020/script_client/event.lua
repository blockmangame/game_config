local Events = {
	"EVENT_SHOW_HOME_GUIDE"
}

for _, name in pairs(Events) do
    Event.register(name)
end
