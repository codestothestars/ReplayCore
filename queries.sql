-- Closest enemy to creature on spell cast.
CREATE TABLE spell_cast_go_unixtimems(
  unixtimems BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY
);
CREATE TABLE unit_type(
  unit_type_id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  description VARCHAR(8) NOT NULL
);
CREATE TABLE encounter_spell_cast_go(
  unixtimems BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY REFERENCES spell_cast_go_unixtimems(unixtimems)
);
CREATE TABLE unit(
  unit_type TINYINT UNSIGNED NOT NULL REFERENCES unit_type(unit_type_id),
  guid INT(10) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid)
);
CREATE TABLE unit_alive_update(
  unit_type TINYINT UNSIGNED NOT NULL REFERENCES unit_type(unit_type_id),
  guid INT(10) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid)
);
CREATE TABLE unit_faction_update(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE unit_movement(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  move_time INT(10) UNSIGNED NOT NULL,
  movement_type TINYINT UNSIGNED NOT NULL,
  spline_count SMALLINT(5) UNSIGNED NOT NULL,
  position_x FLOAT NOT NULL,
  position_y FLOAT NOT NULL,
  position_z FLOAT NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE unit_point(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  parent_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  spline_point SMALLINT(5) UNSIGNED NOT NULL,
  position_x FLOAT NOT NULL,
  position_y FLOAT NOT NULL,
  position_z FLOAT NOT NULL,
  PRIMARY KEY(unit_type, guid, parent_unixtimems, unixtimems),
  FOREIGN KEY(unit_type, guid, parent_unixtimems) REFERENCES unit_movement(unit_type, guid, unixtimems)
);
CREATE TABLE unit_health_update(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  current_health INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE spell_cast_go_unit_health_time(
  spell_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES spell_cast_go_unixtimems(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  update_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(spell_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid, update_unixtimems) REFERENCES unit_health_update(unit_type, guid, unixtimems)
);
CREATE TABLE spell_cast_go_unit_previous_movement(
  spell_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES spell_cast_go_unixtimems(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  movement_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(spell_unixtimems, unit_type, guid, movement_unixtimems),
  FOREIGN KEY(unit_type, guid, movement_unixtimems) REFERENCES unit_movement(unit_type, guid, unixtimems)
);
CREATE TABLE spell_cast_go_unit_last_movement(
  spell_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  movement_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(spell_unixtimems, unit_type, guid),
  FOREIGN KEY(spell_unixtimems, unit_type, guid, movement_unixtimems)
    REFERENCES spell_cast_go_unit_previous_movement(spell_unixtimems, unit_type, guid, movement_unixtimems)
);
CREATE TABLE spell_cast_go_unit_last_point(
  spell_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  parent_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  point_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(spell_unixtimems, unit_type, guid, parent_unixtimems),
  FOREIGN KEY(spell_unixtimems, unit_type, guid, parent_unixtimems)
    REFERENCES spell_cast_go_unit_last_movement(spell_unixtimems, unit_type, guid, movement_unixtimems),
  FOREIGN KEY(unit_type, guid, parent_unixtimems, point_unixtimems)
    REFERENCES unit_point(unit_type, guid, parent_unixtimems, unixtimems)
);
SET @encounter_creature_id = 12435;
SET @target_spell_id = 22271;
INSERT spell_cast_go_unixtimems SELECT DISTINCT unixtimems FROM spell_cast_go;
INSERT unit_type VALUES(1, 'Creature'), (2, 'Player');
INSERT encounter_spell_cast_go
SELECT DISTINCT spell_cast_go.unixtimems
FROM spell_cast_go
  JOIN creature
  JOIN (
    SELECT guid, MIN(unixtimems) unixtimems FROM creature_guid_values_update GROUP BY guid
  ) creature_first_guid_value_update ON creature.guid = creature_first_guid_value_update.guid
  JOIN (
    SELECT guid, MAX(unixtimems) unixtimems FROM creature_values_update GROUP BY guid
  ) creature_last_value_update ON creature.guid = creature_last_value_update.guid
  WHERE
    creature.id = @encounter_creature_id
    AND spell_cast_go.spell_id = @target_spell_id
    AND spell_cast_go.unixtimems
      BETWEEN creature_first_guid_value_update.unixtimems AND creature_last_value_update.unixtimems;
INSERT unit SELECT * FROM (
  SELECT 1 unit_type, guid, faction FROM creature
  UNION ALL
  SELECT 2 unit_type, guid, faction FROM player
) unit;
INSERT unit_faction_update SELECT * FROM (
  SELECT 1 unit_type, guid, unixtimems, faction FROM creature_values_update
  UNION ALL
  SELECT 2 unit_type, guid, unixtimems, faction FROM player_values_update
) unit_faction_update WHERE faction IS NOT NULL;
INSERT unit_health_update
WITH unit_health_update AS (
  -- Starting health
  SELECT
    1 unit_type,
    creature.guid,
    creature_create1_time.unixtimems,
    creature.current_health,
    1 source
  FROM creature JOIN creature_create1_time ON creature.guid = creature_create1_time.guid
  UNION ALL
  SELECT
    1 unit_type,
    guid,
    unixtimems,
    AVG(current_health) current_health, -- AVG in case of ambiguous simultaneous updates
    2 source
  FROM creature_values_update
  GROUP BY unit_type, guid, unixtimems, source
  UNION ALL
  SELECT
    2 unit_type,
    guid,
    unixtimems,
    AVG(current_health) current_health,
    2 source
  FROM player_values_update
  GROUP BY unit_type, guid, unixtimems, source
)
SELECT
  unit_health_update.unit_type,
  unit_health_update.guid,
  unit_health_update.unixtimems,
  unit_health_update.current_health
FROM unit_health_update
JOIN (
  SELECT unit_type, guid, unixtimems, MAX(source) source
  FROM unit_health_update
  GROUP BY unit_type, guid, unixtimems
) unit_health_update_best_source
  ON unit_health_update.unit_type = unit_health_update_best_source.unit_type
  AND unit_health_update.guid = unit_health_update_best_source.guid
  AND unit_health_update.unixtimems = unit_health_update_best_source.unixtimems
  AND unit_health_update.source = unit_health_update_best_source.source
WHERE unit_health_update.current_health IS NOT NULL;
INSERT unit_movement
WITH unit_movement AS (
  -- Charmed creature
  SELECT
    1 unit_type,
    guid,
    unixtimems,
    0 move_time,
    1 movement_type,
    0 `point`,
    0 spline_count,
    AVG(position_x) position_x,
    AVG(position_y) position_y,
    AVG(position_z) position_z
  FROM creature_movement_client
  GROUP BY guid, unixtimems
  UNION ALL
  SELECT
    1 unit_type,
    guid,
    unixtimems,
    move_time,
    2 movement_type,
    `point`,
    spline_count,
    start_position_x,
    start_position_y,
    start_position_z
  FROM creature_movement_server
  UNION ALL
  -- Creature in combat
  SELECT
    1 unit_type,
    guid,
    unixtimems,
    move_time,
    3 movement_type,
    `point`,
    spline_count,
    start_position_x,
    start_position_y,
    start_position_z
  FROM creature_movement_server_combat
  UNION ALL
  -- Player client
  SELECT
    2 unit_type,
    guid,
    unixtimems,
    0 move_time,
    1 movement_type,
    0 `point`,
    0 spline_count,
    AVG(position_x) position_x,
    AVG(position_y) position_y,
    AVG(position_z) position_z
  FROM player_movement_client
  GROUP BY guid, unixtimems
  UNION ALL
  -- Player server
  SELECT
    2 unit_type,
    guid,
    unixtimems,
    move_time,
    2 movement_type,
    `point`,
    spline_count,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM player_movement_server
)
SELECT
  unit_movement.unit_type,
  unit_movement.guid,
  unit_movement.unixtimems,
  COALESCE(unit_faction_update.faction, unit.faction) unit_movement_faction,
  unit_movement.move_time,
  unit_movement.movement_type,
  unit_movement.spline_count,
  unit_movement.position_x,
  unit_movement.position_y,
  unit_movement.position_z
FROM unit_movement
JOIN (
  SELECT unit_type, guid, unixtimems, MAX(movement_type) movement_type
  FROM unit_movement
  GROUP BY unit_type, guid, unixtimems
) unit_movement_type
  ON unit_movement.unit_type = unit_movement_type.unit_type
  AND unit_movement.guid = unit_movement_type.guid
  AND unit_movement.unixtimems = unit_movement_type.unixtimems
  AND unit_movement.movement_type = unit_movement_type.movement_type
JOIN (
  SELECT unit_type, guid, unixtimems, movement_type, MAX(`point`) `point`
  FROM unit_movement
  GROUP BY unit_type, guid, unixtimems, movement_type
) unit_movement_point
  ON unit_movement.unit_type = unit_movement_point.unit_type
  AND unit_movement.guid = unit_movement_point.guid
  AND unit_movement.unixtimems = unit_movement_point.unixtimems
  AND unit_movement.movement_type = unit_movement_point.movement_type
  AND unit_movement.`point` = unit_movement_point.`point`
JOIN unit ON unit_movement.unit_type = unit.unit_type AND unit_movement.guid = unit.guid
LEFT JOIN (
  SELECT
    unit_movement.unit_type,
    unit_movement.guid,
    unit_movement.movement_type,
    unit_movement.unixtimems movement_unixtimems,
    MAX(unit_faction_update.unixtimems) update_unixtimems
  FROM unit_movement
  JOIN unit_faction_update
    ON unit_movement.unit_type = unit_faction_update.unit_type
    AND unit_movement.guid = unit_faction_update.guid
  WHERE unit_faction_update.unixtimems < unit_movement.unixtimems
  GROUP BY unit_movement.unit_type, unit_movement.guid, unit_movement.movement_type, unit_movement.unixtimems
) unit_movement_last_faction_update
  ON unit_movement.unit_type = unit_movement_last_faction_update.unit_type
  AND unit_movement.guid = unit_movement_last_faction_update.guid
  AND unit_movement.movement_type = unit_movement_last_faction_update.movement_type
  AND unit_movement.unixtimems = unit_movement_last_faction_update.movement_unixtimems
LEFT JOIN unit_faction_update
  ON unit_movement.unit_type = unit_faction_update.unit_type
  AND unit_movement.guid = unit_faction_update.guid
  AND unit_movement_last_faction_update.update_unixtimems = unit_faction_update.unixtimems;
INSERT unit_point
WITH unit_point AS (
  -- Creature start point out of combat
  SELECT
    1 unit_type,
    guid,
    unixtimems parent_unixtimems,
    0 spline_point,
    2 movement_type,
    `point`,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM creature_movement_server
  UNION ALL
  -- Creature start point in combat
  SELECT
    1 unit_type,
    guid,
    unixtimems parent_unixtimems,
    0 spline_point,
    3 movement_type,
    `point`,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM creature_movement_server_combat
  UNION ALL
  -- Creature single-point spline end point out of combat
  SELECT
    1 unit_type,
    guid,
    unixtimems parent_unixtimems,
    1 spline_point,
    2 movement_type,
    `point`,
    end_position_x position_x,
    end_position_y position_y,
    end_position_z position_z
  FROM creature_movement_server
  WHERE spline_count = 1
  UNION ALL
  -- Creature single-point spline end point in combat
  SELECT
    1 unit_type,
    guid,
    unixtimems parent_unixtimems,
    1 spline_point,
    3 movement_type,
    `point`,
    end_position_x position_x,
    end_position_y position_y,
    end_position_z position_z
  FROM creature_movement_server_combat
  WHERE spline_count = 1
  UNION ALL
  -- Creature multi-point spline point out of combat
  SELECT
    1 unit_type,
    creature_movement_server.guid,
    creature_movement_server.unixtimems parent_unixtimems,
    spline_point,
    2 movement_type,
    `point`,
    position_x,
    position_y,
    position_z
  FROM creature_movement_server_spline
  JOIN creature_movement_server
    ON creature_movement_server_spline.guid = creature_movement_server.guid
    AND creature_movement_server_spline.parent_point = creature_movement_server.`point`
  UNION ALL
  -- Creature multi-point spline point in combat
  SELECT
    1 unit_type,
    creature_movement_server_combat.guid,
    creature_movement_server_combat.unixtimems parent_unixtimems,
    spline_point,
    3 movement_type,
    `point`,
    position_x,
    position_y,
    position_z
  FROM creature_movement_server_combat_spline
  JOIN creature_movement_server_combat
    ON creature_movement_server_combat_spline.guid = creature_movement_server_combat.guid
    AND creature_movement_server_combat_spline.parent_point = creature_movement_server_combat.`point`
  UNION ALL
  -- Charmed creature
  SELECT
    1 unit_type,
    guid,
    unixtimems parent_unixtimems,
    0 spline_point,
    1 movement_type,
    0 `point`,
    position_x,
    position_y,
    position_z
  FROM creature_movement_client
  UNION ALL
  -- Player client
  SELECT
    2 unit_type,
    guid,
    unixtimems parent_unixtimems,
    0 spline_point,
    1 movement_type,
    0 `point`,
    position_x,
    position_y,
    position_z
  FROM player_movement_client
  UNION ALL
  -- Player start point (only point for non-spline)
  SELECT
    2 unit_type,
    guid,
    unixtimems parent_unixtimems,
    0 spline_point,
    2 movement_type,
    `point`,
    start_position_x position_x,
    start_position_y position_y,
    start_position_z position_z
  FROM player_movement_server
  UNION ALL
  -- Player end point of single-point spline
  SELECT
    2 unit_type,
    guid,
    unixtimems parent_unixtimems,
    1 spline_point,
    2 movement_type,
    `point`,
    end_position_x position_x,
    end_position_y position_y,
    end_position_z position_z
  FROM player_movement_server
  WHERE spline_count = 1
  UNION ALL
  -- Player multi-point spline point
  SELECT
    2 unit_type,
    player_movement_server.guid,
    player_movement_server.unixtimems parent_unixtimems,
    spline_point,
    2 movement_type,
    `point`,
    position_x,
    position_y,
    position_z
  FROM player_movement_server_spline
  JOIN player_movement_server
    ON player_movement_server_spline.guid = player_movement_server.guid
    AND player_movement_server_spline.parent_point = player_movement_server.`point`
)
SELECT
  unit_movement.unit_type,
  unit_movement.guid,
  unit_movement.unixtimems parent_unixtimems,
  unit_movement.unixtimems + CASE unit_movement.spline_count
    WHEN 0 THEN 0
    ELSE unit_movement.move_time * (unit_point.spline_point / unit_movement.spline_count)
  END unixtimems,
  unit_point.spline_point,
  unit_point.position_x,
  unit_point.position_y,
  unit_point.position_z
FROM unit_movement
JOIN unit_point
  ON unit_movement.unit_type = unit_point.unit_type
  AND unit_movement.guid = unit_point.guid
  AND unit_movement.movement_type = unit_point.movement_type
  AND unit_movement.unixtimems = unit_point.parent_unixtimems
JOIN (
  SELECT unit_type, guid, parent_unixtimems, movement_type, MAX(`point`) `point`
  FROM unit_point
  GROUP BY unit_type, guid, parent_unixtimems, movement_type
) unit_point_point
  ON unit_point.unit_type = unit_point_point.unit_type
  AND unit_point.guid = unit_point_point.guid
  AND unit_point.parent_unixtimems = unit_point_point.parent_unixtimems
  AND unit_point.movement_type = unit_point_point.movement_type
  AND unit_point.`point` = unit_point_point.`point`
GROUP BY unit_movement.unit_type, unit_movement.guid, unit_movement.unixtimems, unit_point.spline_point;
ALTER TABLE spell_cast_go ADD CONSTRAINT fk_spell_cast_go_unixtimems FOREIGN KEY(unixtimems) REFERENCES spell_cast_go_unixtimems(unixtimems);
INSERT spell_cast_go_unit_health_time
SELECT
  encounter_spell_cast_go.unixtimems spell_unixtimems,
  unit_health_update.unit_type,
  unit_health_update.guid,
  MAX(unit_health_update.unixtimems) update_unixtimems
FROM encounter_spell_cast_go
JOIN unit_health_update
WHERE unit_health_update.unixtimems < encounter_spell_cast_go.unixtimems
GROUP BY
  encounter_spell_cast_go.unixtimems,
  unit_health_update.unit_type,
  unit_health_update.guid;
INSERT spell_cast_go_unit_previous_movement
SELECT
  encounter_spell_cast_go.unixtimems,
  unit_movement.unit_type,
  unit_movement.guid,
  unit_movement.unixtimems
FROM encounter_spell_cast_go
JOIN unit_movement
WHERE
  unit_movement.unixtimems BETWEEN (encounter_spell_cast_go.unixtimems - 90000) AND encounter_spell_cast_go.unixtimems;
INSERT spell_cast_go_unit_last_movement
SELECT
  spell_unixtimems,
  unit_type,
  guid,
  MAX(movement_unixtimems) movement_unixtimems
FROM spell_cast_go_unit_previous_movement
GROUP BY spell_unixtimems, unit_type, guid;
INSERT spell_cast_go_unit_last_point
SELECT
  spell_cast_go_unit_last_movement.spell_unixtimems,
  spell_cast_go_unit_last_movement.unit_type,
  spell_cast_go_unit_last_movement.guid,
  spell_cast_go_unit_last_movement.movement_unixtimems,
  MAX(unit_point.unixtimems) point_unixtimems
FROM spell_cast_go_unit_last_movement
JOIN unit_point
  ON spell_cast_go_unit_last_movement.unit_type = unit_point.unit_type
  AND spell_cast_go_unit_last_movement.guid = unit_point.guid
  AND spell_cast_go_unit_last_movement.movement_unixtimems = unit_point.parent_unixtimems
WHERE unit_point.unixtimems <= spell_cast_go_unit_last_movement.spell_unixtimems
GROUP BY
  spell_cast_go_unit_last_movement.spell_unixtimems,
  spell_cast_go_unit_last_movement.unit_type,
  spell_cast_go_unit_last_movement.guid,
  spell_cast_go_unit_last_movement.movement_unixtimems;
SELECT
  spell_cast_go.unixtimems,
  caster.guid,
  MIN(SQRT(
    POW(
      spell_cast_go_position.position_x - (
        unit_last_point.position_x
        + CASE WHEN unit_next_point.unixtimems IS NULL THEN 0 ELSE
          (unit_next_point.position_x - unit_last_point.position_x)
          * (
            (spell_cast_go.unixtimems - unit_last_point.unixtimems)
            / (unit_next_point.unixtimems - unit_last_point.unixtimems)
          )
        END
      ),
      2
    )
    + POW(
      spell_cast_go_position.position_y - (
        unit_last_point.position_y
        + CASE WHEN unit_next_point.unixtimems IS NULL THEN 0 ELSE
          (unit_next_point.position_y - unit_last_point.position_y)
          * (
            (spell_cast_go.unixtimems - unit_last_point.unixtimems)
            / (unit_next_point.unixtimems - unit_last_point.unixtimems)
          )
        END
      ),
      2
    )
    + POW(
      spell_cast_go_position.position_z - (
        unit_last_point.position_z
        + CASE WHEN unit_next_point.unixtimems IS NULL THEN 0 ELSE
          (unit_next_point.position_z - unit_last_point.position_z)
          * (
            (spell_cast_go.unixtimems - unit_last_point.unixtimems)
            / (unit_next_point.unixtimems - unit_last_point.unixtimems)
          )
        END
      ),
      2
    )
  )) closest_unit_distance
FROM creature caster
JOIN spell_cast_go ON caster.guid = spell_cast_go.caster_unit_guid
JOIN spell_cast_go_position ON spell_cast_go.src_position_id = spell_cast_go_position.id
JOIN spell_cast_go_unit_last_movement unit_last_movement_time
  ON spell_cast_go.unixtimems = unit_last_movement_time.spell_unixtimems
JOIN unit_movement unit_last_movement
  ON unit_last_movement_time.unit_type = unit_last_movement.unit_type
  AND unit_last_movement_time.guid = unit_last_movement.guid
  AND unit_last_movement_time.movement_unixtimems = unit_last_movement.unixtimems
JOIN spell_cast_go_unit_health_time unit_health_time
  ON spell_cast_go.unixtimems = unit_health_time.spell_unixtimems
  AND unit_last_movement_time.unit_type = unit_health_time.unit_type
  AND unit_last_movement_time.guid = unit_health_time.guid
JOIN unit_health_update unit_health
  ON unit_last_movement_time.unit_type = unit_health.unit_type
  AND unit_last_movement_time.guid = unit_health.guid
  AND unit_health_time.update_unixtimems = unit_health.unixtimems
JOIN spell_cast_go_unit_last_point unit_last_point_time
  ON spell_cast_go.unixtimems = unit_last_point_time.spell_unixtimems
  AND unit_last_movement_time.unit_type = unit_last_point_time.unit_type
  AND unit_last_movement_time.guid = unit_last_point_time.guid
  AND unit_last_movement_time.movement_unixtimems = unit_last_point_time.parent_unixtimems
JOIN unit_point unit_last_point
  ON unit_last_movement_time.unit_type = unit_last_point.unit_type
  AND unit_last_movement_time.guid = unit_last_point.guid
  AND unit_last_movement_time.movement_unixtimems = unit_last_point.parent_unixtimems
  AND unit_last_point_time.point_unixtimems = unit_last_point.unixtimems
LEFT JOIN unit_point unit_next_point
  ON unit_last_movement_time.unit_type = unit_next_point.unit_type
  AND unit_last_movement_time.guid = unit_next_point.guid
  AND unit_last_movement_time.movement_unixtimems = unit_next_point.parent_unixtimems
  AND (unit_last_point.spline_point + 1) = unit_next_point.spline_point
LEFT JOIN (
  SELECT
    spell_cast_go.caster_id,
    spell_cast_go.caster_unit_guid,
    spell_cast_go.unixtimems spell_unixtimems,
    MAX(unit_faction_update.unixtimems) faction_update_unixtimems
  FROM spell_cast_go
  JOIN unit_faction_update ON spell_cast_go.caster_unit_guid = unit_faction_update.guid
  WHERE
    spell_cast_go.caster_id IS NOT NULL
    AND unit_faction_update.unit_type = 1
    AND unit_faction_update.unixtimems < spell_cast_go.unixtimems
  GROUP BY spell_cast_go.caster_id, spell_cast_go.caster_unit_guid, spell_cast_go.unixtimems
) caster_faction_update_time
  ON caster.id = caster_faction_update_time.caster_id
  AND caster.guid = caster_faction_update_time.caster_unit_guid
  AND spell_cast_go.unixtimems = caster_faction_update_time.spell_unixtimems
LEFT JOIN unit_faction_update caster_faction_update
  ON caster.guid = caster_faction_update.guid
  AND caster_faction_update_time.faction_update_unixtimems = caster_faction_update.unixtimems
  AND caster_faction_update.unit_type = 1
JOIN faction_template caster_faction
  ON COALESCE(caster_faction_update.faction, caster.faction) = caster_faction.id
JOIN faction_template unit_faction
  ON unit_last_movement.faction = unit_faction.id
WHERE
  caster_faction.hostile_mask & 0x1 -- caster was hostile to players on cast
  AND spell_cast_go.caster_id = 12420
  AND spell_cast_go.spell_id = 22271
  AND (
    unit_faction.faction_id IN (
      caster_faction.enemy_faction1,
      caster_faction.enemy_faction2,
      caster_faction.enemy_faction3,
      caster_faction.enemy_faction4
    )
    OR unit_faction.our_mask & caster_faction.hostile_mask
  )
  AND unit_health.current_health > 1
GROUP BY spell_cast_go.unixtimems, caster.guid
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
