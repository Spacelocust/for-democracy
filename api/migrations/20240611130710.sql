-- Create "notify_event_change" function
CREATE OR REPLACE FUNCTION notify_event_change()
RETURNS TRIGGER AS $$
DECLARE
    notify BOOLEAN;
BEGIN
    -- Check if the notification has already been sent in this transaction
    IF NOT FOUND THEN
        notify := TRUE;
    ELSE
        notify := FALSE;
    END IF;

    IF notify THEN
        PERFORM pg_notify('event_changes', 'Event changes detected');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create "event_changes" trigger
CREATE TRIGGER liberation_change_trigger
AFTER INSERT OR UPDATE OR DELETE ON liberations
FOR EACH STATEMENT EXECUTE FUNCTION notify_event_change();

-- Create "event_changes" trigger
CREATE TRIGGER defence_change_trigger
AFTER INSERT OR UPDATE OR DELETE ON defences
FOR EACH STATEMENT EXECUTE FUNCTION notify_event_change();
