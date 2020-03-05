local Events = {
    "EVENT_SHOW_SINGLE_TEAM",
    "EVENT_SHOW_TEAM",
    "EVENT_SET_OBJ_PROGRESS_ARGS",
    "EVENT_SHOW_PROGRESS_FOLLOW_OBJ",
    "EVENT_SHOW_DETAILS",
    "EVENT_UPDATE_DETAILS",
    "EVENT_OPEN_BAG_BY_GIVEAWAY",
    "EVENT_WORKS_WALLS_OPERATION"
}

for _, name in pairs(Events) do
    Event.register(name)
end
