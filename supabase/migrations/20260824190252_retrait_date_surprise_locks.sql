-- Doublon de surprise_cooldowns, qui porte deja la regle anti-insistance
-- via trg_surprise_cooldown, peut_reproposer, repondre_surprise et purger_cooldowns.
-- Table vide, aucune fonction ne la reference.

drop table if exists public.date_surprise_locks;
drop function if exists private.insistence_deadline(insistence_window);
drop type if exists insistence_window;
