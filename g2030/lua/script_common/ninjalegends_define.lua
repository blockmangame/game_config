---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/3/23 10:30
---

Define.Team = {
    Neutrality = 1,
    Black = 2,
    White = 3
}

Define.petType = {
    pet = 1,        --宠物
    plusPet = 2     --式神
}

Define.TabType = {
    Equip = 1,
    Belt = 2,
    Advance = 3,
}

Define.BuyStatus = {
    Lock = 1, --未解锁
    Unlock = 2, --解锁
    Buy = 3, --购买
    Used = 4, --使用
}

Define.ProcessState = {
    Init = 0,
    Waiting = 1,
    Prepare = 2,
    ProcessStart = 3,
    ProcessOver = 4,
    WaitClose = 5
}

Define.ProcessType = {
    ProcessBase = require "script_server.process.process_base",
    ProcessTeam = require "script_server.process.process_team"
}