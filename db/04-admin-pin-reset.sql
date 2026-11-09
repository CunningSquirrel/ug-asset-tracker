-- Optional one-time Master Admin PIN reset. Does nothing unless RESET_ADMIN_PIN is set in the app YAML.
--
-- Normal redeploys NEVER change anyone's PIN. PINs changed in Master Control always survive.
-- This only runs when someone deliberately adds RESET_ADMIN_PIN (4 digits) to the migrate
-- container, and it applies each value only ONCE: later redeploys with the same value are ignored.
-- So if Russell changes his PIN afterwards, it is not undone. Remove the setting when done.
--
-- Run by migrate.sh with:  psql -v reset_pin=<RESET_ADMIN_PIN or empty> -v reset_name=<name>

CREATE TABLE IF NOT EXISTS public.ug_admin_pin_resets (
  id         SERIAL PRIMARY KEY,
  staff_name TEXT NOT NULL,
  value_hash TEXT NOT NULL,          -- bcrypt of the reset value, used to apply each value only once
  applied_at TIMESTAMPTZ DEFAULT NOW()
);
REVOKE ALL ON public.ug_admin_pin_resets FROM PUBLIC;
DO $$ BEGIN
  IF to_regclass('public.ug_admin_pin_resets_id_seq') IS NOT NULL THEN
    REVOKE ALL ON SEQUENCE public.ug_admin_pin_resets_id_seq FROM PUBLIC;
  END IF;
END $$;

\o /dev/null
SELECT set_config('ug.reset_pin',  :'reset_pin',  false);
SELECT set_config('ug.reset_name', :'reset_name', false);
\o

DO $$
DECLARE
  v_pin  TEXT := current_setting('ug.reset_pin');
  v_name TEXT := current_setting('ug.reset_name');
BEGIN
  IF v_pin = '' THEN RETURN; END IF;
  IF v_pin !~ '^\d{4}$' THEN RAISE EXCEPTION 'RESET_ADMIN_PIN must be exactly 4 digits'; END IF;
  IF EXISTS (SELECT 1 FROM public.ug_admin_pin_resets r
              WHERE r.staff_name = v_name AND r.value_hash = extensions.crypt(v_pin, r.value_hash)) THEN
    RAISE NOTICE 'PIN reset for % with this value was already applied earlier; skipping', v_name;
    RETURN;
  END IF;
  UPDATE public.staff_accounts
     SET pin_hash = extensions.crypt(v_pin, extensions.gen_salt('bf')),
         failed_attempts = 0, locked_until = NULL,
         pin_changed_at = NOW(), pin_changed_by = 'RESET_ADMIN_PIN (server setting)'
   WHERE name = v_name;
  IF NOT FOUND THEN RAISE EXCEPTION 'RESET_ADMIN_PIN: no staff member named %', v_name; END IF;
  INSERT INTO public.ug_admin_pin_resets (staff_name, value_hash)
  VALUES (v_name, extensions.crypt(v_pin, extensions.gen_salt('bf')));
  RAISE NOTICE 'PIN for % was reset (one time)', v_name;
END $$;
