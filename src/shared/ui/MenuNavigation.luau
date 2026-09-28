--!strict

local MenuNavigation = {}

MenuNavigation.Tabs = table.freeze({
	{ Id = "Jobs", Label = "Jobs" },
	{ Id = "Co-op", Label = "Co-op" },
	{ Id = "Tools", Label = "Tools" },
	{ Id = "Skills", Label = "Skill Tree" },
	{ Id = "Vehicles", Label = "Vehicles" },
	{ Id = "Workshop", Label = "Workshop" },
	{ Id = "Employees", Label = "Employees" },
	{ Id = "Daily", Label = "Daily Jobs" },
	{ Id = "Achievements", Label = "Achievements" },
	{ Id = "Prestige", Label = "Prestige" },
	{ Id = "Shop", Label = "Shop" },
})

function MenuNavigation.IndexOf(id: string): number?
	for index, tab in MenuNavigation.Tabs do
		if tab.Id == id then
			return index
		end
	end
	return nil
end

function MenuNavigation.Move(id: string, delta: number): string
	local index = MenuNavigation.IndexOf(id) or 1
	local count = #MenuNavigation.Tabs
	local nextIndex = ((index - 1 + delta) % count) + 1
	return MenuNavigation.Tabs[nextIndex].Id
end

function MenuNavigation.GetIds(): { string }
	local ids = {}
	for _, tab in MenuNavigation.Tabs do
		table.insert(ids, tab.Id)
	end
	return ids
end

return table.freeze(MenuNavigation)
