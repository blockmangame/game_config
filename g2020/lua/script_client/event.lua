local Events = {
    "EVENT_SHOW_SINGLE_TEAM",
    "EVENT_SHOW_TEAM",
    "EVENT_SHOW_REQUEST_JOIN_FAMILY",
    "EVENT_SHOW_INVITE_JOIN_FAMILY",
}

for _, name in pairs(Events) do
    Event.register(name)
end
