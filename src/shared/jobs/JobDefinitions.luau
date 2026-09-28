--!strict

local function stage(id: string, action: string, seconds: number)
	return { Id = id, Action = action, MinimumSeconds = seconds }
end

local function job(id, category, district, level, reward, xp, toolTier, stages, coop)
	return {
		Id = id,
		Category = category,
		District = district,
		MinimumLevel = level,
		BaseReward = reward,
		XP = xp,
		RequiredToolTier = toolTier,
		Weight = 1,
		Stages = stages,
		Coop = coop == true,
	}
end

local Jobs = {
	job("leaking_faucet", "plumbing", "residential", 1, 120, 100, 1, {
		stage("inspect", "inspect_fixture", 1),
		stage("isolate", "close_valve", 1),
		stage("repair", "replace_seal", 2),
	}),
	job("running_toilet", "plumbing", "residential", 2, 150, 24, 1, {
		stage("inspect", "inspect_cistern", 1),
		stage("repair", "adjust_fill_valve", 2),
	}),
	job("blocked_sink", "plumbing", "residential", 3, 180, 28, 1, {
		stage("inspect", "inspect_drain", 1),
		stage("clear", "clear_blockage", 3),
	}),
	job("loose_trap", "plumbing", "residential", 4, 210, 32, 1, {
		stage("inspect", "inspect_trap", 1),
		stage("tighten", "tighten_trap", 2),
	}),
	job("faulty_shutoff_valve", "plumbing", "residential", 6, 280, 40, 2, {
		stage("diagnose", "inspect_valve", 2),
		stage("replace", "replace_valve", 3),
	}),
	job("burst_pipe_section", "plumbing", "downtown", 18, 720, 90, 2, {
		stage("isolate", "isolate_water", 2),
		stage("remove", "remove_pipe", 3),
		stage("install", "install_pipe", 4),
		stage("test", "pressure_test", 2),
	}),
	job("shower_mixer_fault", "plumbing", "downtown", 22, 840, 105, 2, {
		stage("diagnose", "inspect_mixer", 2),
		stage("repair", "replace_cartridge", 4),
		stage("test", "function_test", 2),
	}),
	job("low_water_pressure", "plumbing", "downtown", 26, 950, 120, 3, {
		stage("measure", "measure_pressure", 2),
		stage("diagnose", "trace_restriction", 3),
		stage("repair", "restore_flow", 4),
	}),
	job("sanitary_fixture_replacement", "plumbing", "industrial", 42, 1_650, 180, 3, {
		stage("remove", "remove_fixture", 4),
		stage("install", "install_fixture", 5),
		stage("test", "leak_test", 3),
	}, true),

	job("cold_radiator", "heating", "residential", 5, 240, 36, 1, {
		stage("inspect", "inspect_radiator", 1),
		stage("vent", "vent_radiator", 2),
	}),
	job("stuck_radiator_valve", "heating", "residential", 7, 320, 44, 1, {
		stage("diagnose", "inspect_valve", 2),
		stage("free", "service_valve", 3),
	}),
	job("boiler_service", "heating", "residential", 10, 420, 55, 2, {
		stage("inspect", "inspect_boiler", 2),
		stage("service", "service_boiler", 4),
		stage("test", "function_test", 2),
	}),
	job("circulation_fault", "heating", "downtown", 16, 650, 80, 2, {
		stage("diagnose", "inspect_pump", 2),
		stage("repair", "restore_circulation", 4),
	}),
	job("heating_zone_fault", "heating", "downtown", 20, 780, 98, 2, {
		stage("diagnose", "trace_zone", 3),
		stage("repair", "repair_zone", 4),
	}),
	job("system_pressure_restore", "heating", "downtown", 24, 900, 112, 2, {
		stage("inspect", "inspect_pressure", 2),
		stage("fill", "restore_pressure", 3),
		stage("test", "leak_test", 2),
	}),
	job("large_boiler_breakdown", "heating", "industrial", 45, 1_900, 210, 4, {
		stage("diagnose", "diagnose_boiler", 4),
		stage("isolate", "isolate_system", 2),
		stage("repair", "replace_component", 6),
		stage("commission", "commission_system", 4),
	}, true),

	job("dirty_ac_filter", "climate", "residential", 8, 300, 42, 1, {
		stage("inspect", "inspect_filter", 1),
		stage("service", "replace_filter", 2),
	}),
	job("indoor_unit_service", "climate", "residential", 12, 480, 60, 2, {
		stage("inspect", "inspect_indoor_unit", 2),
		stage("service", "clean_unit", 4),
	}),
	job("outdoor_unit_check", "climate", "downtown", 17, 660, 82, 2, {
		stage("inspect", "inspect_outdoor_unit", 2),
		stage("test", "run_diagnostics", 3),
	}),
	job("airflow_fault", "climate", "downtown", 21, 790, 100, 2, {
		stage("measure", "measure_airflow", 2),
		stage("repair", "restore_airflow", 4),
	}),
	job("temperature_sensor_fault", "climate", "downtown", 25, 920, 116, 3, {
		stage("diagnose", "test_sensor", 3),
		stage("replace", "replace_sensor", 3),
	}),
	job("commercial_cooling_service", "climate", "industrial", 41, 1_500, 170, 3, {
		stage("inspect", "inspect_commercial_unit", 3),
		stage("service", "service_commercial_unit", 5),
		stage("test", "performance_test", 3),
	}),
	job("multi_unit_climate_contract", "climate", "industrial", 48, 2_200, 240, 4, {
		stage("survey", "survey_units", 4),
		stage("service_a", "service_unit_a", 4),
		stage("service_b", "service_unit_b", 4),
		stage("verify", "verify_systems", 4),
	}, true),

	job("heat_pump_check", "energy", "residential", 13, 520, 66, 2, {
		stage("inspect", "inspect_heat_pump", 2),
		stage("test", "run_diagnostics", 3),
	}),
	job("heat_pump_flow_issue", "energy", "downtown", 19, 730, 92, 2, {
		stage("measure", "measure_flow", 2),
		stage("repair", "restore_flow", 4),
	}),
	job("energy_controller_fault", "energy", "downtown", 23, 860, 108, 3, {
		stage("diagnose", "diagnose_controller", 3),
		stage("repair", "repair_controller", 4),
	}),
	job("solar_thermal_check", "energy", "downtown", 28, 1_020, 125, 3, {
		stage("inspect", "inspect_solar_loop", 3),
		stage("test", "test_solar_loop", 3),
	}),
	job("hybrid_system_service", "energy", "industrial", 40, 1_420, 160, 3, {
		stage("survey", "survey_hybrid_system", 3),
		stage("service", "service_hybrid_system", 5),
	}),
	job("large_heat_pump_commissioning", "energy", "industrial", 46, 2_000, 225, 4, {
		stage("inspect", "precommission_check", 3),
		stage("configure", "configure_system", 5),
		stage("test", "commission_test", 5),
	}, true),
	job("industrial_energy_contract", "energy", "industrial", 55, 2_800, 300, 4, {
		stage("survey", "site_survey", 4),
		stage("diagnose", "system_diagnostics", 5),
		stage("repair", "major_service", 7),
		stage("commission", "final_commission", 5),
	}, true),
}

local byId = {}
for _, definition in Jobs do
	assert(byId[definition.Id] == nil, "Duplicate job ID: " .. definition.Id)
	byId[definition.Id] = definition
end

return table.freeze({
	List = table.freeze(Jobs),
	ById = table.freeze(byId),
})
