extends LoadingZone

func ready_to_show_event():
  var event
  event = 'sample_event'
  if not event in Globals.already_seen_events:
    Globals.already_seen_events.append(event)
    return event
