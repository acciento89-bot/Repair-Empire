--!strict

local RepairSceneCatalog = {}

local entries = {
	leaking_faucet = { Category = "plumbing", Variant = "sink" },
	running_toilet = { Category = "plumbing", Variant = "toilet" },
	blocked_sink = { Category = "plumbing", Variant = "sink" },
	loose_trap = { Category = "plumbing", Variant = "sink" },
	faulty_shutoff_valve = { Category = "plumbing", Variant = "sink" },
	burst_pipe_section = { Category = "plumbing", Variant = "pipe" },
	shower_mixer_fault = { Category = "plumbing", Variant = "shower" },
	low_water_pressure = { Category = "plumbing", Variant = "pipe" },
	sanitary_fixture_replacement = { Category = "plumbing", Variant = "toilet" },

	cold_radiator = { Category = "heating", Variant = "radiator" },
	stuck_radiator_valve = { Category = "heating", Variant = "radiator" },
	boiler_service = { Category = "heating", Variant = "boiler" },
	circulation_fault = { Category = "heating", Variant = "pump" },
	heating_zone_fault = { Category = "heating", Variant = "radiator" },
	system_pressure_restore = { Category = "heating", Variant = "boiler" },
	large_boiler_breakdown = { Category = "heating", Variant = "boiler" },

	dirty_ac_filter = { Category = "climate", Variant = "indoor" },
	indoor_unit_service = { Category = "climate", Variant = "indoor" },
	outdoor_unit_check = { Category = "climate", Variant = "outdoor" },
	airflow_fault = { Category = "climate", Variant = "indoor" },
	temperature_sensor_fault = { Category = "climate", Variant = "indoor" },
	commercial_cooling_service = { Category = "climate", Variant = "commercial" },
	multi_unit_climate_contract = { Category = "climate", Variant = "commercial" },

	heat_pump_check = { Category = "energy", Variant = "heat_pump" },
	heat_pump_flow_issue = { Category = "energy", Variant = "heat_pump" },
	energy_controller_fault = { Category = "energy", Variant = "controller" },
	solar_thermal_check = { Category = "energy", Variant = "solar" },
	hybrid_system_service = { Category = "energy", Variant = "hybrid" },
	large_heat_pump_commissioning = { Category = "energy", Variant = "heat_pump" },
	industrial_energy_contract = { Category = "energy", Variant = "hybrid" },
}

function RepairSceneCatalog.Get(jobId: string, category: string?)
	local entry = entries[jobId]
	if entry then
		return entry
	end
	return {
		Category = category or "plumbing",
		Variant = if category == "heating"
			then "radiator"
			elseif category == "climate"
			then "outdoor"
			elseif category == "energy" then "heat_pump"
			else "sink",
	}
end

RepairSceneCatalog.Entries = table.freeze(entries)

return table.freeze(RepairSceneCatalog)
