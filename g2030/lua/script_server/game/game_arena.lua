---
---竞技场管理 20200414 zhuyayi
---
---state:
---CLOSE 尚未开启
---OPEN
local ArenaMgr = {}
function ArenaMgr:init()
    self.state = "CLOSE"
end

ArenaMgr:init()

return ArenaMgr