local Events = {
    "EVENT_SHOW_SINGLE_TEAM",
    "EVENT_SHOW_TEAM",
    "EVENT_SET_OBJ_PROGRESS_ARGS",
    "EVENT_SHOW_PROGRESS_FOLLOW_OBJ",
    "EVENT_SHOW_DETAILS",
    "EVENT_OPEN_BAG_BY_GIVEAWAY",
    "EVENT_WORKS_WALLS_OPERATION",
    "EVENT_OPEN_DANCE",
    "EVENT_OPEN_DRESS_ARCHIVE",
    "EVENT_SHOW_DRESS_STORE",
    "EVENT_SHOW_WORK_DETAILS",
    "EVENT_SHOW_DIALOG_TIP",
    "EVENT_SYNC_DATA",
    "EVENT_SYNC_STATES_DATA",
    "EVENT_SET_DETAILS",
    "EVENT_SET_UI_VISIBLE",
    "EVENT_TRADE_CHANGE_ITEM",
    "EVENT_TRADE_SUCCEED",
    "SHOW_TRADE_HINT",
    "EVENT_SHOW_REWARD_DIALOG",
    "EVENT_SHOW_INVITE_TIP_BY_SCRIPT",
    "EVENT_STATE_RELEASING_ANIMATION"
}

for _, name in pairs(Events) do
    Event.register(name)
end
