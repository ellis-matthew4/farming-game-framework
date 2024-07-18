extends LoadingZone

var already_seen_events = []

func ready_to_show_event():
  var event
  event = 'sample_event'
  if not event in already_seen_events:
    already_seen_events.append(event)
    return event
