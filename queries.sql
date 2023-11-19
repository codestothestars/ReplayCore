-- Initial delay for spell for creature.
-- Includes time alive in case the creature died without casting, which may increase the max delay.
SELECT
  ROUND(
    (CAST(spell_initial_cast.unixtimems AS SIGNED) - CAST(creature_combat_start.unixtimems AS SIGNED)) / 1000
  ) spell_initial_cast_delay,
  ROUND((creature_death.unixtimems - creature_combat_start.unixtimems) / 1000) creature_time_alive
FROM creature
  JOIN (
    SELECT MIN(unixtimems) unixtimems, guid FROM creature_guid_values_update WHERE field_name = 'Target' GROUP BY guid
  ) creature_combat_start ON creature.guid = creature_combat_start.guid
  LEFT JOIN (
    SELECT MIN(unixtimems) unixtimems, caster_guid, spell_id FROM spell_cast_start GROUP BY caster_guid, spell_id
  ) spell_initial_cast ON creature.guid = spell_initial_cast.caster_guid AND spell_initial_cast.spell_id = 13747
  LEFT JOIN (
    SELECT MAX(unixtimems) unixtimems, guid FROM creature_values_update WHERE current_health = 0 GROUP BY guid
  ) creature_death ON creature.guid = creature_death.guid
WHERE
  creature.id = 12557;

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

-- Time in combat for creature
