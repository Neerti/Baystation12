/datum/preferences/proc/SetAntagoptions(mob/user)
	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Antagonist Options</b> <hr />"
	HTML += "<br>"
	HTML +="Uplink Type : <b><a href='?src=\ref[user];preference=antagoptions;antagtask=uplinktype;active=1'>[uplinklocation]</a></b>"
	HTML +="<br>"
	HTML +="Exploitable information about you : "
	HTML += "<br>"
	if(jobban_isbanned(user, "Records"))
		HTML += "<b>You are banned from using character records.</b><br>"
	else
		HTML +="<b><a href=\"byond://?src=\ref[user];preference=records;task=exploitable_record\">[TextPreview(exploit_record,40)]</a></b>"
	HTML +="<br>"
	HTML +="<hr />"
	HTML +="<a href='?src=\ref[user];preference=antagoptions;antagtask=done;active=1'>\[Done\]</a>"

	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=antagoptions")
	return

/datum/preferences/proc/SetFlavorText(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=flavor_text;task=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=flavor_text;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=flavor_text;size=430x300")
	return

/datum/preferences/proc/SetFlavourTextRobot(mob/user) //robot_here
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Robot Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href ='byond://?src=\ref[user];preference=flavour_text_robot;task=Default'>Default:</a> "
	HTML += TextPreview(flavour_texts_robot["Default"])
	HTML += "<hr />"
	for(var/module in robot_module_types)
		HTML += "<a href='byond://?src=\ref[user];preference=flavour_text_robot;task=[module]'>[module]:</a> "
		HTML += TextPreview(flavour_texts_robot[module])
		HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=flavour_text_robot;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=flavour_text_robot;size=430x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Character Records</b><br>"

	//HTML += "<a href=\'byond://?src=\ref[user];preference=flavour_text_robot;task=open'><b>Set Robot Flavour Text</b></a><br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"

	//HTML += TextPreview(med_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	HTML += TextPreview(gen_record,40)

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	HTML += TextPreview(sec_record,40)

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return

/datum/preferences/proc/SetMedicalRecord(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Set Medical Records</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=general'>Date of Birth:</a> "
	HTML += "DATE OF BIRTH: [TextPreview(med_records["date_of_birth"])]"
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=head'>Do Not Clone?:</a> "
	HTML += TextPreview(med_records["DNC"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=face'>Face:</a> "
	HTML += TextPreview(med_records["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=eyes'>Eyes:</a> "
	HTML += TextPreview(med_records["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=torso'>Body:</a> "
	HTML += TextPreview(med_records["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=arms'>Arms:</a> "
	HTML += TextPreview(med_records["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=hands'>Hands:</a> "
	HTML += TextPreview(med_records["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=legs'>Legs:</a> "
	HTML += TextPreview(med_records["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[user];preference=med_records;task=feet'>Feet:</a> "
	HTML += TextPreview(med_records["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[user];preference=set_med_record;task=done'>\[Done\]</a>"
	HTML += "<tt>"
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=set_med_record;size=430x300")
	return

//dat += "<a href='byond://?src=\ref[user];preference=flavour_text_robot;task=open'><b>Set Robot Flavour Text</b></a><br>"

