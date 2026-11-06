-- First-run staff roster (only inserted while the staff table is empty).
-- Run by the "migrate" container with:  psql -v admin_pin=<INITIAL_ADMIN_PIN> -f 03-seed.sql
-- Russell Ralph (Master Admin) gets INITIAL_ADMIN_PIN. Everyone else starts on 1234:
-- the Master Admin must set real PINs in Master Control before the app goes live.

INSERT INTO public.staff_accounts (name, role, active, permissions, pin_hash)
SELECT v.name, v.role, TRUE, '{}'::jsonb,
       extensions.crypt(CASE WHEN v.role = 'Master Admin' THEN :'admin_pin' ELSE '1234' END, extensions.gen_salt('bf'))
  FROM (VALUES
    ('Arthur Sibisi', 'Technician'),
    ('Ashley Bhyrodeyal', 'Technician'),
    ('Ben', 'Storeman'),
    ('Bongi Lukhele (Mbongiseni Lukhele)', 'Technician'),
    ('Bradley Churchyard', 'Manager'),
    ('Cameron Magennis', 'Technician'),
    ('Cameron Rensleigh', 'Technician'),
    ('Catherine', 'Storeman'),
    ('Cedric Gcaba', 'Technician'),
    ('Darren Dry', 'Manager'),
    ('Darryn Cox', 'Technician'),
    ('Delyn Van Der Vent', 'Technician'),
    ('Denver Chetty', 'Manager'),
    ('Edward Thusi', 'Technician'),
    ('Erick Mgenge', 'Technician'),
    ('Fortune Zuma', 'Technician'),
    ('Jimmy Memmo', 'Technician'),
    ('Karen Ngcobo', 'Technician'),
    ('Kenny Mvuyana', 'Technician'),
    ('Kyle Gradwell', 'Technician'),
    ('Luke Jordaan', 'Technician'),
    ('Mthogo', 'Technician'),
    ('Mthutu Nyembezi', 'Technician'),
    ('Preston Govind', 'Technician'),
    ('Quintin Dry', 'Manager'),
    ('Riaan Allen', 'Manager'),
    ('Russell Ralph', 'Master Admin'),
    ('Sandile Sibiya', 'Technician'),
    ('Siphiwe Luthuli', 'Technician'),
    ('Siya Mngomezulu', 'Technician'),
    ('Siyabonga Jiba', 'Technician'),
    ('Timothee Mudiandambu', 'Technician'),
    ('Timothy Aldridge', 'Technician'),
    ('Tonton Bongo', 'Technician'),
    ('Wesley Lawrence', 'Technician'),
    ('Zizipho Danca', 'Technician')
  ) AS v(name, role)
 WHERE NOT EXISTS (SELECT 1 FROM public.staff_accounts);

-- Self-hosted: the roster is seeded above, so the browser never needs the first-run bootstrap.
REVOKE EXECUTE ON FUNCTION public.ug_bootstrap_staff(JSONB) FROM anon, authenticated;
