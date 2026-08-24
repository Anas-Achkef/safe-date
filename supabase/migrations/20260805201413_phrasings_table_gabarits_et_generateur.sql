-- ============================================================
-- Generation des phrases naturelles du module 3.
-- Deux modes :
--   'sub' — une phrase porteuse, {} recoit le libelle de l'option
--           (initiale mise en minuscule). Insensible au nombre d'options.
--   'idx' — une phrase explicite par option, separees par ||.
--           Utilise quand une phrase porteuse unique produirait du
--           francais bancal (Oui/Non, echelles, genres accordes).
-- ============================================================

create table private.phrase_patterns (
  criterion_key text primary key references criteria(key) on delete cascade,
  mode          text not null check (mode in ('sub','idx')),
  pattern       text not null,
  locale        text not null default 'fr'
);

comment on table private.phrase_patterns is
  'Gabarits de reformulation, un par critere. Source de generation de criterion_option_phrasings : on edite ici, jamais les 918 phrases une par une.';

create or replace function private.generate_phrasings(p_locale text default 'fr')
returns integer language plpgsql as
$fn$
declare n integer;
begin
  insert into criterion_option_phrasings (criterion_key, idx, locale, phrase)
  select o.criterion_key, o.idx, p_locale,
         case t.mode
           when 'sub' then replace(t.pattern, '{}',
                            lower(left(o.label, 1)) || substr(o.label, 2))
           when 'idx' then (string_to_array(t.pattern, '||'))[o.idx + 1]
         end
  from criterion_options o
  join private.phrase_patterns t
    on t.criterion_key = o.criterion_key and t.locale = p_locale
  where case t.mode
          when 'idx' then (string_to_array(t.pattern, '||'))[o.idx + 1] is not null
          else true
        end
  on conflict (criterion_key, idx, locale) do update set phrase = excluded.phrase;
  get diagnostics n = row_count;
  return n;
end $fn$;

-- Controle : gabarit 'idx' dont le nombre de segments ne correspond pas
-- au nombre reel d'options. C'est le seul risque de desalignement.
create or replace view private.v_gabarits_incoherents as
  select t.criterion_key, t.mode,
         array_length(string_to_array(t.pattern, '||'), 1) as segments,
         count(o.idx)                                      as options
  from private.phrase_patterns t
  join criterion_options o on o.criterion_key = t.criterion_key
  where t.mode = 'idx'
  group by t.criterion_key, t.mode, t.pattern
  having array_length(string_to_array(t.pattern, '||'), 1) <> count(o.idx);;
