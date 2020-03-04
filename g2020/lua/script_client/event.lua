local Events = {
    "EVENT_SHOW_SINGLE_TEAM",
    "EVENT_SHOW_TEAM",
}

for _, name in pairs(Events) do
    Event.register(name)
end
