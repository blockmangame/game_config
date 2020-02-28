local Events = {
	"EVENT_SHOW_SINGLE_FAMILY",
}

for _, name in pairs(Events) do
    Event.register(name)
end
