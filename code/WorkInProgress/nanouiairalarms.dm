/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.total_moles

	var/powerdraw
	if(regulating_temperature)
		powerdraw = active_power_usage
	else
		powerdraw = idle_power_usage

	var/rounded_pressure = TLV["pressure"]
	for (var/n in rounded_pressure)
		n = formatNumber(n, 2)

	// this is the data which will be sent to the ui, it must be a list
	var/data[0]

	data["IsSynthetic"] = istype(user, /mob/living/silicon)

	data["Pressure"] = formatNumber(environment.return_pressure(), 2)
	data["O2"] = round(environment.gas["oxygen"] / total * 100, 2)
	data["CO2"] = round(environment.gas["carbon_dioxide"] / total * 100, 2)
	data["Phoron"] = round(environment.gas["phoron"] / total * 100, 2)
	data["Temperature"] = formatNumber(environment.temperature, 2)
	data["TemperatureCelsius"] = formatNumber(environment.temperature - T0C, 2)
	data["LocalStatus"] = (max(pressure_dangerlevel,oxygen_dangerlevel,co2_dangerlevel,phoron_dangerlevel,other_dangerlevel,temperature_dangerlevel))
	data["AreaStatus"] = (max(alarm_area.atmosalm,alarm_area.fire))
	data["Thermostat"] = formatNumber(target_temperature, 2)
	data["ThermostatCelsius"] = formatNumber(target_temperature - T0C, 2)
	data["powerSetting"] = temperature_regulator_level
	data["powerDraw"] = powerdraw
	data["enviromentMode"] = mode
	data["rconSetting"] = rcon_setting

	data["oxygenSensors"] = TLV["oxygen"]
	data["carbonDioxideSensors"] = TLV["carbon dioxide"]
	data["phoronSensors"] = TLV["phoron"]
	data["pressureSensors"] = rounded_pressure
	data["temperatureSensors"] = TLV["temperature"]

	data["isSensorsOn"] = report_danger_level

	data["ventInfo"] = alarm_area.air_vent_names
	data["scrubberInfo"] = alarm_area.air_scrub_names
	/*

	// breathable air according to human/Life()
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["phoron"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-26, T0C, T0C+40, T0C+66) // K
	*/

	data["locked"] = locked

	data["Mode"] = interface_mode
	// update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "airalarm.tmpl", "[name]", 520, 610)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		ui.set_auto_update(1)

