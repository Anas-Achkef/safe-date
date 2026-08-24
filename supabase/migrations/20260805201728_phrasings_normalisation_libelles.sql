-- Un libelle insere dans une phrase porteuse doit perdre sa majuscule
-- initiale, et ses barres obliques doivent devenir des « ou ». Les
-- acronymes (DIY, CAP) sont preserves.

create or replace function private.label_inline(l text)
returns text language plpgsql immutable as
$fn$
declare part text; sortie text[] := '{}';
begin
  foreach part in array string_to_array(l, '/') loop
    part := btrim(part);
    if part <> upper(part) then
      part := lower(left(part, 1)) || substr(part, 2);
    end if;
    sortie := sortie || part;
  end loop;
  return array_to_string(sortie, ' ou ');
end $fn$;

create or replace function private.generate_phrasings(p_locale text default 'fr')
returns integer language plpgsql as
$fn$
declare n integer;
begin
  insert into criterion_option_phrasings (criterion_key, idx, locale, phrase)
  select o.criterion_key, o.idx, p_locale,
         case t.mode
           when 'sub' then replace(t.pattern, '{}', private.label_inline(o.label))
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

select private.generate_phrasings('fr');;
