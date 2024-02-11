-- Closest enemy to creature on spell cast.
WITH
creature_point AS (
  -- Start point (only point for non-spline)
  SELECT
    guid,
    `point` parent_point,
    0 spline_point,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM creature_movement_server_combat
  UNION ALL
  -- End point of single-point spline
  SELECT
    guid,
    `point` parent_point,
    1 spline_point,
    end_position_x position_x,
    end_position_y position_y,
    end_position_z position_z
  FROM creature_movement_server_combat
  WHERE spline_count = 1
  UNION ALL
  -- Multi-point spline point
  SELECT
    guid,
    parent_point,
    spline_point,
    position_x,
    position_y,
    position_z
  FROM creature_movement_server_combat_spline
),
pet AS (
  SELECT guid FROM creature WHERE is_pet = 1 AND faction IN (1, 2, 3, 4, 5, 6, 115, 116)
),
player_movement AS (
  -- Charmed creature
  SELECT
    unixtimems,
    guid,
    unixtimems `point`,
    0 move_time,
    0 spline_count,
    position_x,
    position_y,
    position_z
  FROM creature_movement_client
  UNION ALL
  -- Player client
  SELECT
    unixtimems,
    guid,
    unixtimems `point`,
    0 move_time,
    0 spline_count,
    position_x,
    position_y,
    position_z
  FROM player_movement_client
  UNION ALL
  -- Player server
  SELECT
    unixtimems,
    guid,
    `point`,
    move_time,
    spline_count,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM player_movement_server
  UNION ALL
  -- Pet
  SELECT
    creature_movement_server_combat.unixtimems,
    creature_movement_server_combat.guid,
    creature_movement_server_combat.`point`,
    creature_movement_server_combat.move_time,
    creature_movement_server_combat.spline_count,
    creature_movement_server_combat.start_position_x,
    creature_movement_server_combat.start_position_y,
    creature_movement_server_combat.start_position_z
  FROM creature_movement_server_combat JOIN pet ON creature_movement_server_combat.guid = pet.guid
),
player_point AS (
  -- Charmed creature
  SELECT
    guid,
    unixtimems parent_point,
    0 spline_point,
    position_x,
    position_y,
    position_z
  FROM creature_movement_client
  UNION ALL
  -- Player client
  SELECT
    guid,
    unixtimems parent_point,
    0 spline_point,
    position_x,
    position_y,
    position_z
  FROM player_movement_client
  UNION ALL
  -- Player start point (only point for non-spline)
  SELECT
    guid,
    `point` parent_point,
    0 spline_point,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM player_movement_server
  UNION ALL
  -- Player end point of single-point spline
  SELECT
    guid,
    `point` parent_point,
    1 spline_point,
    end_position_x position_x,
    end_position_y position_y,
    end_position_z position_z
  FROM player_movement_server
  WHERE spline_count = 1
  UNION ALL
  -- Player multi-point spline point
  SELECT
    guid,
    parent_point,
    spline_point,
    position_x,
    position_y,
    position_z
  FROM player_movement_server_spline
  UNION ALL
  -- Pet start point (only point for non-spline)
  SELECT
    creature_movement_server.guid,
    creature_movement_server.`point` parent_point,
    0 spline_point,
    creature_movement_server.start_position_x position_x,
    creature_movement_server.start_position_y position_y,
    creature_movement_server.start_position_z position_z
  FROM creature_movement_server JOIN pet ON creature_movement_server.guid = pet.guid
  UNION ALL
  -- Pet end point of single-point spline
  SELECT
    creature_movement_server.guid,
    creature_movement_server.`point` parent_point,
    1 spline_point,
    creature_movement_server.end_position_x position_x,
    creature_movement_server.end_position_y position_y,
    creature_movement_server.end_position_z position_z
  FROM creature_movement_server JOIN pet ON creature_movement_server.guid = pet.guid
  WHERE spline_count = 1
  UNION ALL
  -- Pet multi-point spline point
  SELECT
    creature_movement_server_spline.guid,
    creature_movement_server_spline.parent_point,
    creature_movement_server_spline.spline_point,
    creature_movement_server_spline.position_x,
    creature_movement_server_spline.position_y,
    creature_movement_server_spline.position_z
  FROM creature_movement_server_spline JOIN pet ON creature_movement_server_spline.guid = pet.guid
)
SELECT spell_cast_start.unixtimems, caster.guid, MIN(SQRT(
  POW(COALESCE(caster_current_movement_point.position_x, caster.position_x) - player_current_movement_point.position_x, 2)
  + POW(COALESCE(caster_current_movement_point.position_y, caster.position_y) - player_current_movement_point.position_y, 2)
)) closest_player_distance
FROM spell_cast_start
JOIN creature caster ON spell_cast_start.caster_guid = caster.guid
JOIN (
  SELECT
    spell_cast_start.unixtimems spell_cast_start_unixtimems,
    player_movement.guid player_guid,
    MAX(player_movement.unixtimems) player_last_movement_unixtimems
  FROM spell_cast_start JOIN player_movement
  WHERE player_movement.unixtimems < spell_cast_start.unixtimems
  GROUP BY spell_cast_start.unixtimems, player_movement.guid
) player_last_movement
  ON spell_cast_start.unixtimems = player_last_movement.spell_cast_start_unixtimems
JOIN player_movement player_current_position
  ON player_last_movement.player_guid = player_current_position.guid
  AND player_last_movement.player_last_movement_unixtimems = player_current_position.unixtimems
JOIN (
  SELECT
    spell_cast_start.unixtimems spell_cast_start_unixtimems,
    player_movement.guid,
    player_movement.unixtimems player_movement_unixtimems,
    player_movement.`point`,
    MIN(CASE player_movement.spline_count WHEN 0 THEN 1 ELSE ABS(
      (spell_cast_start.unixtimems - player_movement.unixtimems) / player_movement.move_time
      - player_point.spline_point / player_movement.spline_count
    ) END) spline_progress
  FROM spell_cast_start
  JOIN player_movement
  JOIN player_point
    ON player_movement.guid = player_point.guid
    AND player_movement.`point` = player_point.parent_point
  WHERE player_movement.unixtimems < spell_cast_start.unixtimems
  GROUP BY spell_cast_start.unixtimems, player_movement.guid, player_movement.unixtimems, player_movement.`point`
) player_last_movement_point
  ON player_last_movement.player_guid = player_last_movement_point.guid
  AND spell_cast_start.unixtimems = player_last_movement_point.spell_cast_start_unixtimems
  AND player_last_movement.player_last_movement_unixtimems = player_last_movement_point.player_movement_unixtimems
  AND player_current_position.`point` = player_last_movement_point.`point`
JOIN player_point player_current_movement_point
  ON player_last_movement.player_guid = player_current_movement_point.guid
  AND player_current_position.`point` = player_current_movement_point.parent_point
  AND (player_current_position.spline_count = 0 OR player_last_movement_point.spline_progress = ABS(
    (spell_cast_start.unixtimems - player_last_movement.player_last_movement_unixtimems) / player_current_position.move_time
    - player_current_movement_point.spline_point / player_current_position.spline_count
  ))
LEFT JOIN (
  SELECT
    spell_cast_start.unixtimems spell_cast_start_unixtimems,
    caster_movement.guid,
    MAX(caster_movement.unixtimems) caster_last_movement_unixtimems
  FROM spell_cast_start
  JOIN creature_movement_server_combat caster_movement ON spell_cast_start.caster_guid = caster_movement.guid
  WHERE caster_movement.unixtimems < spell_cast_start.unixtimems
  GROUP BY spell_cast_start.unixtimems, caster_movement.guid
) caster_last_movement
  ON spell_cast_start.caster_guid = caster_last_movement.guid
  AND spell_cast_start.unixtimems = caster_last_movement.spell_cast_start_unixtimems
LEFT JOIN creature_movement_server_combat caster_current_position
  ON spell_cast_start.caster_guid = caster_current_position.guid
  AND caster_last_movement.caster_last_movement_unixtimems = caster_current_position.unixtimems
LEFT JOIN (
  SELECT
    spell_cast_start.unixtimems spell_cast_start_unixtimems,
    caster_movement.guid,
    caster_movement.unixtimems caster_movement_unixtimems,
    caster_movement.`point`,
    MIN(CASE caster_movement.spline_count WHEN 0 THEN 1 ELSE ABS(
      (spell_cast_start.unixtimems - caster_movement.unixtimems) / caster_movement.move_time
      - caster_movement_point.spline_point / caster_movement.spline_count
    ) END) spline_progress
  FROM spell_cast_start
  JOIN creature_movement_server_combat caster_movement ON spell_cast_start.caster_guid = caster_movement.guid
  JOIN creature_point caster_movement_point
    ON spell_cast_start.caster_guid = caster_movement_point.guid
    AND caster_movement.`point` = caster_movement_point.parent_point
  WHERE caster_movement.unixtimems < spell_cast_start.unixtimems
  GROUP BY spell_cast_start.unixtimems, caster_movement.guid, caster_movement.unixtimems, caster_movement.`point`
) caster_last_movement_point
  ON spell_cast_start.caster_guid = caster_last_movement_point.guid
  AND spell_cast_start.unixtimems = caster_last_movement_point.spell_cast_start_unixtimems
  AND caster_last_movement.caster_last_movement_unixtimems = caster_last_movement_point.caster_movement_unixtimems
  AND caster_current_position.`point` = caster_last_movement_point.`point`
LEFT JOIN creature_point caster_current_movement_point
  ON spell_cast_start.caster_guid = caster_current_movement_point.guid
  AND caster_current_position.`point` = caster_current_movement_point.parent_point
  AND (caster_current_position.spline_count = 0 OR caster_last_movement_point.spline_progress = ABS(
    (spell_cast_start.unixtimems - caster_last_movement.caster_last_movement_unixtimems) / caster_current_position.move_time
    - caster_current_movement_point.spline_point / caster_current_position.spline_count
  ))
WHERE
  player_current_position.unixtimems > (spell_cast_start.unixtimems - 60000) -- 1 minute
  AND player_current_position.unixtimems < spell_cast_start.unixtimems
  AND spell_cast_start.caster_id = 12420
  AND spell_cast_start.spell_id = 22271
GROUP BY spell_cast_start.unixtimems, caster.guid
ORDER BY unixtimems, guid;

-- Distinct creatures entering combat before boss death
SELECT DISTINCT creature.id
FROM creature_guid_values_update
JOIN creature creature ON creature_guid_values_update.guid = creature.guid
JOIN creature_values_update boss_death
JOIN creature boss ON boss_death.guid = boss.guid
WHERE boss.id = 12435
  AND boss_death.current_health = 0
  AND creature.`map` = 469
  AND creature_guid_values_update.field_name = 'Target'
  AND creature_guid_values_update.unixtimems < boss_death.unixtimems
ORDER BY id;

-- Initial delay for spell for creature.
-- Includes time alive as a minimum ceiling.
SELECT
  creature.guid,
  ROUND(
    (CAST(spell_initial_cast.unixtimems AS SIGNED) - CAST(creature_combat_start.unixtimems AS SIGNED)) / 1000
  ) spell_initial_cast_delay,
  ROUND((creature_death.unixtimems - creature_combat_start.unixtimems) / 1000) creature_time_alive,
  spell_initial_cast.unixtimems spell_initial_cast,
  creature_combat_start.unixtimems creature_combat_start
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
  creature.id = 12557
ORDER BY creature.guid;

-- Repeat delay for spell for creature.
-- Includes time left alive as a minimum ceiling where the creature never repeated the spell.
SELECT
  creature.guid,
  ROUND((current_cast.unixtimems - previous_cast.unixtimems) / 1000) spell_repeat_cast_delay,
  ROUND((creature_death.unixtimems - current_cast.unixtimems) / 1000) creature_time_left_alive,
  current_cast.unixtimems current_cast,
  previous_cast.unixtimems previous_cast
FROM creature
  JOIN spell_cast_start current_cast
    ON creature.guid = current_cast.caster_guid
  LEFT JOIN spell_cast_start previous_cast
    ON current_cast.caster_guid = previous_cast.caster_guid
    AND current_cast.spell_id = previous_cast.spell_id
    AND current_cast.unixtimems > previous_cast.unixtimems
  LEFT JOIN spell_cast_start between_cast
    ON current_cast.caster_guid = between_cast.caster_guid
    AND current_cast.spell_id = between_cast.spell_id
    AND current_cast.unixtimems > between_cast.unixtimems
    AND previous_cast.unixtimems < between_cast.unixtimems
  LEFT JOIN (
    SELECT MAX(unixtimems) unixtimems, guid FROM creature_values_update WHERE current_health = 0 GROUP BY guid
  ) creature_death ON creature.guid = creature_death.guid 
WHERE
  between_cast.unixtimems IS NULL
  AND creature.id = 12557
  AND current_cast.spell_id = 22274
ORDER BY creature.guid, current_cast.unixtimems;

-- Verify whether spell delays are useful.
SET @guid = 526;
SELECT * FROM creature_attack_log WHERE guid = @guid ORDER BY unixtimems;
SELECT unixtimems, spell_id, slot FROM creature_auras_update WHERE guid = @guid AND spell_id NOT IN (355, 1120, 5209, 6795, 7321, 9898, 10151, 10186, 10187, 10216, 10894, 11275, 11556, 11574, 11581, 11597, 11668, 11672, 11675, 11678, 11708, 11713, 11717, 11722, 12486, 12579, 12721, 12654, 13810, 13555, 14325, 15258, 17392, 17800, 18807, 18871, 18881, 20924, 21151, 22959, 25295, 25306, 25311, 25349) ORDER BY unixtimems;
SELECT * FROM spell_cast_failed WHERE caster_guid = @guid ORDER BY unixtimems;

-- Distinct spells cast by creature.
SELECT spell_id FROM (
  SELECT caster_id, spell_id FROM spell_cast_failed
  UNION
  SELECT caster_id, spell_id FROM spell_cast_go
  UNION
  SELECT caster_id, spell_id FROM spell_cast_start
  UNION
  SELECT caster_id, spell_id FROM spell_channel_start
  UNION
  SELECT caster_id, spell_id FROM spell_unique_caster
) creature_spell
WHERE caster_id = 12557
ORDER BY spell_id;

-- Count of distinct spells cast by creature.
SELECT COUNT(DISTINCT spell_id) FROM (
  SELECT caster_id, spell_id FROM spell_cast_failed
  UNION
  SELECT caster_id, spell_id FROM spell_cast_go
  UNION
  SELECT caster_id, spell_id FROM spell_cast_start
  UNION
  SELECT caster_id, spell_id FROM spell_channel_start
  UNION
  SELECT caster_id, spell_id FROM spell_unique_caster
) creature_spell
WHERE caster_id = 12557;

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
