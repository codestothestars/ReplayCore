-- Initial delay for spell for creature.
SELECT ROUND((spell_cast_start.unixtimems - creature_guid_values_update.unixtimems) / 1000)
FROM spell_cast_start
  JOIN creature ON spell_cast_start.caster_guid = creature.guid
  JOIN creature_guid_values_update ON creature.guid = creature_guid_values_update.guid
WHERE
  creature.id = 12557
  AND creature_guid_values_update.unixtimems <= spell_cast_start.unixtimems
  AND creature_guid_values_update.field_name = 'Target'
  AND spell_cast_start.spell_id = 13747
ORDER BY spell_cast_start.unixtimems, creature_guid_values_update.unixtimems
LIMIT 1;

-- Repeat delay for spell for creature.
SELECT ROUND(AVG(current_cast.unixtimems - previous_cast.unixtimems) / 1000)
FROM spell_cast_start current_cast
  JOIN spell_cast_start previous_cast
    ON current_cast.caster_guid = previous_cast.caster_guid AND current_cast.spell_id = previous_cast.spell_id
  JOIN creature
    ON current_cast.caster_guid = creature.guid
  LEFT JOIN spell_cast_start between_cast
    ON current_cast.caster_guid = between_cast.caster_guid
    AND current_cast.spell_id = between_cast.spell_id
    AND current_cast.unixtimems > between_cast.unixtimems
    AND previous_cast.unixtimems < between_cast.unixtimems 
WHERE
  between_cast.unixtimems IS NULL
  AND creature.id = 12557
  AND current_cast.spell_id = 22274
  AND current_cast.unixtimems > previous_cast.unixtimems;

-- Distinct spells cast by creature.
SELECT spell_id FROM (
  SELECT spell_id, caster_id FROM spell_cast_failed
  UNION
  SELECT spell_id, caster_id FROM spell_cast_go
  UNION
  SELECT spell_id, caster_id FROM spell_cast_start
  UNION
  SELECT spell_id, caster_id FROM spell_channel_start
  UNION
  SELECT spell_id, caster_id FROM spell_unique_caster
) spell
WHERE caster_id = 12557
ORDER BY spell_id;

-- Delay of creature's each movement from the previous.
SELECT current.unixtimems, current.point, current.orientation, ROUND((current.unixtimems - previous.unixtimems) / 1000) delay
FROM creature_movement_server current
  JOIN creature_movement_server previous ON current.guid = previous.guid AND current.point - 1 = previous.point
  JOIN creature ON current.guid = creature.guid
WHERE creature.id = 12435
ORDER BY current.unixtimems, current.point;

-- Min and max delay of creature's movement from the previous.
SELECT
  MIN(ROUND((current.unixtimems - previous.unixtimems) / 1000)) min_delay,
  MAX(ROUND((current.unixtimems - previous.unixtimems) / 1000)) max_delay
FROM creature_movement_server current
  JOIN creature_movement_server previous ON current.guid = previous.guid AND current.point - 1 = previous.point
  JOIN creature ON current.guid = creature.guid
WHERE creature.id = 12435 AND (current.unixtimems - previous.unixtimems) > 3000
ORDER BY current.unixtimems, current.point;
