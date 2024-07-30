extends LoadingZone

func ready_to_show_event():
  var event = "start"
  if not event in Globals.already_seen_events:
    Globals.already_seen_events.append(event)
    return event
  # rest of event logic
  if not event in Globals.already_seen_events:
    Globals.already_seen_events.append(event)
    return event

