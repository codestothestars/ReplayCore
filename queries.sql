-- Units
CREATE TABLE unit_type(
  unit_type_id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  description VARCHAR(8) NOT NULL
);
CREATE TABLE unit(
  unit_type TINYINT UNSIGNED NOT NULL REFERENCES unit_type(unit_type_id),
  guid INT(10) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid)
);
CREATE TABLE unit_activity_time(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE unit_create_time(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE unit_death(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
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
CREATE TABLE unit_position(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  position_x FLOAT NOT NULL,
  position_y FLOAT NOT NULL,
  position_z FLOAT NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems)
);
CREATE TABLE unit_health_update(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  current_health INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (unit_type, guid, unixtimems),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
INSERT unit_type VALUES(1, 'Creature'), (2, 'Player');
INSERT unit SELECT * FROM (
  SELECT 1 unit_type, guid, faction FROM creature
  UNION ALL
  SELECT 2 unit_type, guid, faction FROM player
) unit;
INSERT unit_activity_time
SELECT * FROM (
  -- Spawn
  SELECT unit_type, guid, unixtimems FROM unit_create_time
  UNION
  -- Creature spell cast
  SELECT 1, spell_cast_go.caster_unit_guid, spell_cast_go.unixtimems
  FROM spell_cast_go
  JOIN creature ON spell_cast_go.caster_unit_id = creature.id AND spell_cast_go.caster_unit_guid = creature.guid
  UNION
  -- Player spell cast
  SELECT 2, spell_cast_go.caster_unit_guid, spell_cast_go.unixtimems
  FROM spell_cast_go
  JOIN player ON spell_cast_go.caster_unit_guid = player.guid
  WHERE spell_cast_go.caster_unit_id = 0
) unit_activity_time;

INSERT unit_create_time
WITH
creature_create_time AS (
  SELECT guid, unixtimems FROM creature_create1_time UNION ALL SELECT guid, unixtimems FROM creature_create2_time
),
player_create_time AS (
  SELECT guid, unixtimems FROM player_create1_time UNION ALL SELECT guid, unixtimems FROM player_create2_time
)
SELECT * FROM (
  SELECT 1 unit_type, creature_create_time.guid, creature_create_time.unixtimems
  FROM creature_create_time
  JOIN (SELECT guid, MIN(unixtimems) unixtimems FROM creature_create_time GROUP BY guid) min_time
    ON creature_create_time.guid = min_time.guid AND creature_create_time.unixtimems = min_time.unixtimems
  UNION ALL
  SELECT 2 unit_type, player_create_time.guid, player_create_time.unixtimems
  FROM player_create_time
  JOIN (SELECT guid, MIN(unixtimems) unixtimems FROM player_create_time GROUP BY guid) min_time
    ON player_create_time.guid = min_time.guid AND player_create_time.unixtimems = min_time.unixtimems
) unit_create_time;
INSERT unit_death SELECT 1 unit_type, guid, unixtimems FROM creature_values_update WHERE current_health = 0;
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
-- store only the movements within an encounter and the latest one within 90 seconds before an encounter
WHERE
  unit_movement.unixtimems IN (
    SELECT unixtimems
    FROM unit_movement JOIN encounter
    WHERE unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
  )
  OR unit_movement.unixtimems IN (
    SELECT MAX(movement.unixtimems)
    FROM unit_movement movement JOIN encounter
    WHERE movement.unixtimems > (encounter.start_unixtimems - 90000)
      AND movement.unixtimems < encounter.start_unixtimems
    GROUP BY movement.unit_type, movement.guid, encounter.start_unixtimems
  );
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
),
unit_point_distance_from_previous AS (
  SELECT
    unit_point.unit_type,
    unit_point.guid,
    unit_point.parent_unixtimems,
    unit_point.spline_point,
    unit_point.movement_type,
    CASE WHEN previous_point.unit_type IS NULL THEN 0 ELSE SQRT(
      POW(unit_point.position_x - previous_point.position_x, 2)
      + POW(unit_point.position_y - previous_point.position_y, 2)
      + POW(unit_point.position_z - previous_point.position_z, 2)
    ) END distance
  FROM unit_point
  LEFT JOIN unit_point previous_point
    ON unit_point.unit_type = previous_point.unit_type
    AND unit_point.guid = previous_point.guid
    AND unit_point.parent_unixtimems = previous_point.parent_unixtimems
    AND (unit_point.spline_point - 1) = previous_point.spline_point
    AND unit_point.movement_type = previous_point.movement_type
),
unit_movement_speed AS (
  SELECT
    unit_movement.unit_type,
    unit_movement.guid,
    unit_movement.unixtimems,
    unit_movement.movement_type,
    SUM(unit_point_distance_from_previous.distance) / unit_movement.move_time speed
  FROM unit_movement
  JOIN unit_point_distance_from_previous
    ON unit_movement.unit_type = unit_point_distance_from_previous.unit_type
    AND unit_movement.guid = unit_point_distance_from_previous.guid
    AND unit_movement.unixtimems = unit_point_distance_from_previous.parent_unixtimems
    AND unit_movement.movement_type = unit_point_distance_from_previous.movement_type
  WHERE unit_movement.move_time > 0 
  GROUP BY
    unit_movement.unit_type,
    unit_movement.guid,
    unit_movement.unixtimems,
    unit_movement.movement_type,
    unit_movement.move_time
),
unit_point_distance_from_movement AS (
  SELECT
    unit_point.unit_type,
    unit_point.guid,
    unit_point.parent_unixtimems,
    unit_point.spline_point,
    unit_point.movement_type,
    SUM(unit_point_distance_from_previous.distance) distance
  FROM unit_point
  JOIN unit_point_distance_from_previous
    ON unit_point.unit_type = unit_point_distance_from_previous.unit_type
    AND unit_point.guid = unit_point_distance_from_previous.guid
    AND unit_point.parent_unixtimems = unit_point_distance_from_previous.parent_unixtimems
    AND unit_point.movement_type = unit_point_distance_from_previous.movement_type
  WHERE unit_point.spline_point >= unit_point_distance_from_previous.spline_point
  GROUP BY
    unit_point.unit_type,
    unit_point.guid,
    unit_point.parent_unixtimems,
    unit_point.spline_point,
    unit_point.movement_type
)
SELECT
  unit_movement.unit_type,
  unit_movement.guid,
  unit_movement.unixtimems parent_unixtimems,
  unit_movement.unixtimems
    + CASE WHEN unit_movement_speed.unit_type IS NULL THEN 0 ELSE
      ROUND(unit_point_distance_from_movement.distance / unit_movement_speed.speed)
    END
    + ROW_NUMBER() OVER( -- offset consecutive points rounding to same time
      PARTITION BY
        unit_movement.unit_type,
        unit_movement.guid,
        unit_movement.unixtimems,
        CASE WHEN unit_movement_speed.unit_type IS NULL THEN 0 ELSE
          ROUND(unit_point_distance_from_movement.distance / unit_movement_speed.speed)
        END
      ORDER BY unit_point.spline_point
    ) - 1 point_unixtimems,
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
) unit_point_max_point
  ON unit_movement.unit_type = unit_point_max_point.unit_type
  AND unit_movement.guid = unit_point_max_point.guid
  AND unit_movement.unixtimems = unit_point_max_point.parent_unixtimems
  AND unit_movement.movement_type = unit_point_max_point.movement_type
  AND unit_point.`point` = unit_point_max_point.`point`
LEFT JOIN unit_movement_speed
  ON unit_movement.unit_type = unit_movement_speed.unit_type
  AND unit_movement.guid = unit_movement_speed.guid
  AND unit_movement.unixtimems = unit_movement_speed.unixtimems
  AND unit_movement.movement_type = unit_movement_speed.movement_type
LEFT JOIN unit_point_distance_from_movement
  ON unit_movement.unit_type = unit_point_distance_from_movement.unit_type
  AND unit_movement.guid = unit_point_distance_from_movement.guid
  AND unit_movement.unixtimems = unit_point_distance_from_movement.parent_unixtimems
  AND unit_point.spline_point = unit_point_distance_from_movement.spline_point
  AND unit_movement.movement_type = unit_point_distance_from_movement.movement_type;

-- Event time tracking
CREATE TABLE encounter(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  start_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  end_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(unit_type, guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE event(
  unixtimems BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY
);
CREATE TABLE event_unit_closest_enemy_distance(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  distance FLOAT UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE event_unit_enemy_distance(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  enemy_unit_type TINYINT UNSIGNED NOT NULL,
  enemy_guid INT(10) UNSIGNED NOT NULL,
  distance FLOAT UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid, enemy_unit_type, enemy_guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid),
  FOREIGN KEY(enemy_unit_type, enemy_guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE event_unit_faction_time(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  update_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid, update_unixtimems) REFERENCES unit_faction_update(unit_type, guid, unixtimems)
);
CREATE TABLE event_unit_faction(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  faction INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE event_unit_health_time(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  update_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid, update_unixtimems) REFERENCES unit_health_update(unit_type, guid, unixtimems)
);
CREATE TABLE event_unit_position(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  source VARCHAR(8) NOT NULL,
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  position_x FLOAT NOT NULL,
  position_y FLOAT NOT NULL,
  position_z FLOAT NOT NULL,
  PRIMARY KEY(event_unixtimems, source, unit_type, guid),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE event_unit_last_point(
  event_unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  movement_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  point_unixtimems BIGINT(20) UNSIGNED NOT NULL,
  PRIMARY KEY(event_unixtimems, unit_type, guid),
  FOREIGN KEY(unit_type, guid, movement_unixtimems, point_unixtimems)
    REFERENCES unit_point(unit_type, guid, parent_unixtimems, unixtimems)
);
CREATE VIEW incapacitate_spell AS
SELECT entry
FROM spell_template
WHERE (
  spell_template.effect1 = 6 AND (spell_template.effectMechanic1 IN (1, 2, 3, 5, 9, 10, 12, 13, 14, 17, 18, 24, 26) OR spell_template.mechanic = 12) OR
  spell_template.effect2 = 6 AND spell_template.effectMechanic2 IN (1, 2, 3, 5, 9, 10, 12, 13, 14, 17, 18, 24, 26) OR
  spell_template.effect3 = 6 AND spell_template.effectMechanic3 IN (1, 2, 3, 5, 9, 10, 12, 13, 14, 17, 18, 24, 26)
);
SET @encounter_creature_id = 12420;
INSERT encounter
SELECT
  1 unit_type,
  creature.guid,
  first_guid_value_update.unixtimems start_unixtimems,
  last_value_update.unixtimems end_unixtimems
FROM creature
  JOIN (SELECT guid, MIN(unixtimems) unixtimems FROM creature_guid_values_update GROUP BY guid) first_guid_value_update
    ON creature.guid = first_guid_value_update.guid
  JOIN (SELECT guid, MAX(unixtimems) unixtimems FROM creature_values_update GROUP BY guid) last_value_update
    ON creature.guid = last_value_update.guid
WHERE creature.id = @encounter_creature_id;
INSERT event_unit_faction_time
SELECT
  event.unixtimems event_unixtimems,
  unit_faction_update.unit_type,
  unit_faction_update.guid,
  MAX(unit_faction_update.unixtimems) update_unixtimems
FROM event
JOIN unit_faction_update
WHERE unit_faction_update.unixtimems < event.unixtimems
GROUP BY event.unixtimems, unit_faction_update.unit_type, unit_faction_update.guid;
INSERT event_unit_faction
SELECT DISTINCT
  event.unixtimems event_unixtimems,
  unit.unit_type,
  unit.guid,
  COALESCE(unit_faction_update.faction, unit.faction) faction
FROM event
JOIN unit
JOIN unit_activity_time ON unit.unit_type = unit_activity_time.unit_type AND unit.guid = unit_activity_time.guid
LEFT JOIN event_unit_faction_time
  ON event.unixtimems = event_unit_faction_time.event_unixtimems
  AND unit.unit_type = event_unit_faction_time.unit_type
  AND unit.guid = event_unit_faction_time.guid
LEFT JOIN unit_faction_update
  ON unit.unit_type = unit_faction_update.unit_type
  AND unit.guid = unit_faction_update.guid
  AND event_unit_faction_time.update_unixtimems = unit_faction_update.unixtimems
WHERE unit_activity_time.unixtimems BETWEEN (event.unixtimems - 300000) AND event.unixtimems;
INSERT event_unit_health_time
SELECT
  event.unixtimems event_unixtimems,
  unit_health_update.unit_type,
  unit_health_update.guid,
  MAX(unit_health_update.unixtimems) update_unixtimems
FROM event
JOIN unit_health_update
WHERE unit_health_update.unixtimems < event.unixtimems
GROUP BY
  event.unixtimems,
  unit_health_update.unit_type,
  unit_health_update.guid;
INSERT event_unit_last_point
SELECT
  event.unixtimems event_unixtimems,
  event_unit_last_movement.unit_type,
  event_unit_last_movement.guid,
  event_unit_last_movement.movement_unixtimems,
  MAX(unit_point.unixtimems) point_unixtimems
FROM event
JOIN (
  SELECT
    event.unixtimems event_unixtimems,
    unit_movement.unit_type,
    unit_movement.guid,
    MAX(unit_movement.unixtimems) movement_unixtimems
  FROM event JOIN unit_movement
  WHERE event.unixtimems >= unit_movement.unixtimems
  GROUP BY event.unixtimems, unit_movement.unit_type, unit_movement.guid
) event_unit_last_movement ON event.unixtimems = event_unit_last_movement.event_unixtimems
JOIN unit_point
  ON event_unit_last_movement.unit_type = unit_point.unit_type
  AND event_unit_last_movement.guid = unit_point.guid
  AND event_unit_last_movement.movement_unixtimems = unit_point.parent_unixtimems
WHERE unit_point.unixtimems <= event.unixtimems
GROUP BY
  event.unixtimems,
  event_unit_last_movement.unit_type,
  event_unit_last_movement.guid,
  event_unit_last_movement.movement_unixtimems;
INSERT event_unit_enemy_distance
SELECT
  event_unit_position.event_unixtimems,
  event_unit_position.unit_type,
  event_unit_position.guid,
  enemy_last_point_time.unit_type enemy_unit_type,
  enemy_last_point_time.guid enemy_guid,
  SQRT(
    POW(event_unit_position.position_x - (
      enemy_last_point.position_x + CASE WHEN enemy_next_point.unixtimems IS NULL THEN 0 ELSE
        (enemy_next_point.position_x - enemy_last_point.position_x) * (
          (event_unit_position.event_unixtimems - enemy_last_point.unixtimems)
          / (enemy_next_point.unixtimems - enemy_last_point.unixtimems)
        )
      END
    ), 2)
    + POW(event_unit_position.position_y - (
      enemy_last_point.position_y + CASE WHEN enemy_next_point.unixtimems IS NULL THEN 0 ELSE
        (enemy_next_point.position_y - enemy_last_point.position_y) * (
          (event_unit_position.event_unixtimems - enemy_last_point.unixtimems)
          / (enemy_next_point.unixtimems - enemy_last_point.unixtimems)
        )
      END
    ), 2)
  ) distance
FROM event_unit_position
JOIN event_unit_faction
  ON event_unit_position.unit_type = event_unit_faction.unit_type
  AND event_unit_position.guid = event_unit_faction.guid
  AND event_unit_position.event_unixtimems = event_unit_faction.event_unixtimems
JOIN faction_template unit_faction
  ON event_unit_faction.faction = unit_faction.id
JOIN event_unit_last_point enemy_last_point_time
  ON event_unit_position.event_unixtimems = enemy_last_point_time.event_unixtimems
JOIN unit_point enemy_last_point
  ON enemy_last_point_time.unit_type = enemy_last_point.unit_type
  AND enemy_last_point_time.guid = enemy_last_point.guid
  AND enemy_last_point_time.movement_unixtimems = enemy_last_point.parent_unixtimems
  AND enemy_last_point_time.point_unixtimems = enemy_last_point.unixtimems
JOIN event_unit_faction enemy_faction_update
  ON event_unit_position.event_unixtimems = enemy_faction_update.event_unixtimems
  AND enemy_last_point_time.unit_type = enemy_faction_update.unit_type
  AND enemy_last_point_time.guid = enemy_faction_update.guid
JOIN event_unit_health_time enemy_health_time
  ON event_unit_position.event_unixtimems = enemy_health_time.event_unixtimems
  AND enemy_last_point_time.unit_type = enemy_health_time.unit_type
  AND enemy_last_point_time.guid = enemy_health_time.guid
JOIN unit_health_update enemy_health
  ON enemy_last_point_time.unit_type = enemy_health.unit_type
  AND enemy_last_point_time.guid = enemy_health.guid
  AND enemy_health_time.update_unixtimems = enemy_health.unixtimems
LEFT JOIN unit_point enemy_next_point
  ON enemy_last_point_time.unit_type = enemy_next_point.unit_type
  AND enemy_last_point_time.guid = enemy_next_point.guid
  AND enemy_last_point.parent_unixtimems = enemy_next_point.parent_unixtimems
  AND (enemy_last_point.spline_point + 1) = enemy_next_point.spline_point
JOIN faction_template enemy_faction
  ON enemy_faction_update.faction = enemy_faction.id
WHERE
  unit_faction.hostile_mask & 0x1 -- target unit was hostile to players on event
  AND (
    enemy_faction.faction_id IN (
      unit_faction.enemy_faction1,
      unit_faction.enemy_faction2,
      unit_faction.enemy_faction3,
      unit_faction.enemy_faction4
    )
    OR enemy_faction.our_mask & unit_faction.hostile_mask
  )
  AND enemy_health.current_health > 1;
INSERT event_unit_closest_enemy_distance
SELECT event_unixtimems, unit_type, guid, MIN(distance) closest_unit_distance
FROM event_unit_enemy_distance
GROUP BY event_unixtimems, unit_type, guid
ORDER BY event_unixtimems, unit_type, guid;

-- Closest enemy to creature on spell cast.
SET @encounter_creature_id = 12420;
SET @target_spell_id = 22271;
INSERT event
SELECT DISTINCT spell_cast_go.unixtimems
FROM spell_cast_go JOIN encounter
WHERE
  spell_cast_go.spell_id = @target_spell_id
  AND spell_cast_go.unixtimems
    BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems;
ALTER TABLE spell_cast_go ADD CONSTRAINT fk_spell_cast_go_unixtimems FOREIGN KEY(unixtimems) REFERENCES event(unixtimems);
INSERT event_unit_position
  spell_cast_go.unixtimems event_unixtimems,
  'spell' source,
  1 unit_type,
  caster.guid,
  spell_cast_go_position.position_x,
  spell_cast_go_position.position_y,
  spell_cast_go_position.position_z
FROM creature caster
JOIN spell_cast_go ON caster.guid = spell_cast_go.caster_unit_guid
JOIN spell_cast_go_position ON spell_cast_go.src_position_id = spell_cast_go_position.id
WHERE spell_cast_go.caster_id = @encounter_creature_id AND spell_cast_go.spell_id = @target_spell_id;
SELECT * FROM event_unit_closest_enemy_distance;

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

-- Creature's initial time in proximity to enemies without casting spell
SET @radius = 10;
CREATE TABLE generated_unixtimems(
  unixtimems BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY
);
CREATE TABLE proximity_interval_end_event(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL,
  full BIT NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems, full),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
CREATE TABLE proximity_interval_start_event(
  unit_type TINYINT UNSIGNED NOT NULL,
  guid INT(10) UNSIGNED NOT NULL,
  unixtimems BIGINT(20) UNSIGNED NOT NULL REFERENCES event(unixtimems),
  full BIT NOT NULL,
  PRIMARY KEY(unit_type, guid, unixtimems, full),
  FOREIGN KEY(unit_type, guid) REFERENCES unit(unit_type, guid)
);
SELECT @encounter_intervals := GROUP_CONCAT(
  CONCAT(
    'SELECT seq FROM seq_',
    -- Modulus ensures that overlapping portions of intervals are redundant
    start_unixtimems - start_unixtimems % 250,
    '_to_',
    end_unixtimems - end_unixtimems % 250,
    '_step_250'
  )
  SEPARATOR ' UNION '
) FROM encounter;
CREATE OR REPLACE PROCEDURE p() EXECUTE IMMEDIATE CONCAT('INSERT generated_unixtimems ', @encounter_intervals); CALL p; DROP PROCEDURE p;
INSERT event SELECT * FROM (
  -- Creature combat start
  SELECT start_unixtimems unixtimems FROM encounter
  UNION
  -- Movement time polling
  SELECT unixtimems FROM generated_unixtimems
  UNION
  -- Spell cast
  SELECT spell_cast_go.unixtimems
  FROM spell_cast_go JOIN creature ON spell_cast_go.caster_unit_guid = creature.guid
  WHERE creature.id = @encounter_creature_id AND spell_cast_go.spell_id = @target_spell_id
  UNION
  -- Unit faction change
  SELECT unit_faction_update.unixtimems
  FROM unit_faction_update JOIN encounter
  WHERE unit_faction_update.unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
  UNION
  -- Unit death
  SELECT unit_death.unixtimems
  FROM unit_death JOIN encounter
  WHERE unit_death.unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
) event;

INSERT event_unit_position
SELECT
  event_unit_last_point.event_unixtimems,
  'whatever' source,
  1 unit_type,
  creature.guid,
  last_point.position_x + CASE WHEN next_point.unixtimems IS NULL THEN 0 ELSE
    (next_point.position_x - last_point.position_x) * (
      (event_unit_last_point.event_unixtimems - last_point.unixtimems)
      / (next_point.unixtimems - last_point.unixtimems)
    )
  END position_x,
  last_point.position_y + CASE WHEN next_point.unixtimems IS NULL THEN 0 ELSE
    (next_point.position_y - last_point.position_y) * (
      (event_unit_last_point.event_unixtimems - last_point.unixtimems)
      / (next_point.unixtimems - last_point.unixtimems)
    )
  END position_y,
  last_point.position_z + CASE WHEN next_point.unixtimems IS NULL THEN 0 ELSE
    (next_point.position_z - last_point.position_z) * (
      (event_unit_last_point.event_unixtimems - last_point.unixtimems)
      / (next_point.unixtimems - last_point.unixtimems)
    )
  END position_z
FROM creature
JOIN event_unit_last_point ON creature.guid = event_unit_last_point.guid
JOIN unit_point last_point
  ON event_unit_last_point.unit_type = last_point.unit_type
  AND event_unit_last_point.guid = last_point.guid
  AND event_unit_last_point.movement_unixtimems = last_point.parent_unixtimems
  AND event_unit_last_point.point_unixtimems = last_point.unixtimems
LEFT JOIN unit_point next_point
  ON event_unit_last_point.unit_type = next_point.unit_type
  AND event_unit_last_point.guid = next_point.guid
  AND last_point.parent_unixtimems = next_point.parent_unixtimems
  AND (last_point.spline_point + 1) = next_point.spline_point
WHERE creature.id = @encounter_creature_id AND event_unit_last_point.unit_type = 1;
INSERT proximity_interval_end_event SELECT * FROM (
  -- Creature casts the spell.
  SELECT 1 unit_type, creature.guid, spell_cast_go.unixtimems, 1 full
  FROM spell_cast_go JOIN creature ON spell_cast_go.caster_unit_guid = creature.guid
  WHERE creature.id = @encounter_creature_id AND spell_cast_go.spell_id = @target_spell_id
  UNION
  -- Creature dies
  SELECT 1 unit_type, unit_death.guid, unit_death.unixtimems, 0 full
  FROM unit_death JOIN creature ON unit_death.guid = creature.guid
  WHERE creature.id = @encounter_creature_id AND unit_death.unit_type = 1
  UNION
  -- Creature incapacitated
  SELECT 1 unit_type, creature_auras_update.guid, creature_auras_update.unixtimems, 0 full
  FROM creature_auras_update
    JOIN incapacitate_spell ON creature_auras_update.spell_id = incapacitate_spell.entry
    JOIN creature ON creature_auras_update.guid = creature.guid
  WHERE creature.id = @encounter_creature_id
  UNION
  -- No enemy in range
  SELECT 1 unit_type, encounter.guid, event.unixtimems, 0 full
  FROM (
    -- Death
    SELECT unixtimems FROM unit_death
    UNION
    -- Faction change
    SELECT unixtimems FROM unit_faction_update
    UNION
    -- Movement time polling
    SELECT unixtimems FROM generated_unixtimems
  ) event
  JOIN encounter ON event.unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
  WHERE NOT EXISTS(
    SELECT 1 FROM event_unit_enemy_distance
    WHERE event.unixtimems = event_unit_enemy_distance.event_unixtimems
      AND encounter.unit_type = event_unit_enemy_distance.unit_type
      AND encounter.guid = event_unit_enemy_distance.guid
      AND event_unit_enemy_distance.distance <= @radius
  )
) proximity_interval_end_event;
INSERT proximity_interval_start_event SELECT * FROM (
  -- Started combat within range
  SELECT DISTINCT
    event_unit_enemy_distance.unit_type,
    event_unit_enemy_distance.guid,
    event_unit_enemy_distance.event_unixtimems,
    1 full
  FROM event_unit_enemy_distance
  JOIN encounter ON event_unit_enemy_distance.event_unixtimems = encounter.start_unixtimems
  WHERE event_unit_enemy_distance.distance <= @radius
) proximity_interval_start_event;
SELECT
  start_event_time.unit_type,
  start_event_time.guid,
  start_event_time.unixtimems start_unixtimems,
  end_event_time.end_unixtimems,
  end_event_time.end_unixtimems - start_event_time.unixtimems duration,
  start_event.full AND end_event.full full
FROM (
  SELECT
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    MIN(proximity_interval_start_event.unixtimems) unixtimems
  FROM proximity_interval_start_event
  GROUP BY proximity_interval_start_event.unit_type, proximity_interval_start_event.guid
) start_event_time
JOIN proximity_interval_start_event start_event
  ON start_event_time.unit_type = start_event.unit_type
  AND start_event_time.guid = start_event.guid
  AND start_event_time.unixtimems = start_event.unixtimems
JOIN (
  SELECT
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems start_unixtimems,
    MIN(proximity_interval_end_event.unixtimems) end_unixtimems
  FROM proximity_interval_start_event
  JOIN proximity_interval_end_event
    ON proximity_interval_start_event.unit_type = proximity_interval_end_event.unit_type
    AND proximity_interval_start_event.guid = proximity_interval_end_event.guid
  WHERE proximity_interval_start_event.unixtimems < proximity_interval_end_event.unixtimems
  GROUP BY
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems
) end_event_time
  ON start_event.unit_type = end_event_time.unit_type
  AND start_event.guid = end_event_time.guid
  AND start_event.unixtimems = end_event_time.start_unixtimems
JOIN proximity_interval_end_event end_event
  ON start_event.unit_type = end_event.unit_type
  AND start_event.guid = end_event.guid
  AND end_event_time.end_unixtimems = end_event.unixtimems
LEFT JOIN proximity_interval_end_event previous_end_event
  ON start_event.unit_type = previous_end_event.unit_type
  AND start_event.guid = previous_end_event.guid
  AND start_event.unixtimems > previous_end_event.unixtimems
LEFT JOIN proximity_interval_start_event previous_start_event
  ON start_event.unit_type = previous_start_event.unit_type
  AND start_event.guid = previous_start_event.guid
  AND start_event.unixtimems > previous_start_event.unixtimems
WHERE previous_end_event.unit_type IS NULL AND previous_start_event.unit_type IS NULL
ORDER BY duration, start_unixtimems, start_event_time.guid;

-- Creature's repeat time in proximity to enemies without casting spell
SET @radius = 10;
INSERT event SELECT * FROM (
  -- Movement time polling
  SELECT unixtimems FROM generated_unixtimems
  UNION
  -- Spell cast
  SELECT spell_cast_go.unixtimems
  FROM spell_cast_go JOIN creature ON spell_cast_go.caster_unit_guid = creature.guid
  WHERE creature.id = @encounter_creature_id AND spell_cast_go.spell_id = @target_spell_id
  UNION
  -- Unit death
  SELECT unit_death.unixtimems
  FROM unit_death JOIN encounter
  WHERE unit_death.unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
  UNION
  -- Unit incapacitate aura remove
  SELECT creature_auras_update.unixtimems
  FROM creature_auras_update JOIN creature ON creature_auras_update.guid = creature.guid
  WHERE creature.id = @encounter_creature_id AND creature_auras_update.spell_id = 0
  UNION
  -- Unit faction change
  SELECT unit_faction_update.unixtimems
  FROM unit_faction_update JOIN encounter
  WHERE unit_faction_update.unixtimems BETWEEN encounter.start_unixtimems AND encounter.end_unixtimems
) event;
INSERT proximity_interval_start_event
SELECT
  proximity_interval_start_event.unit_type,
  proximity_interval_start_event.guid,
  proximity_interval_start_event.unixtimems,
  proximity_interval_start_event.full
FROM (
  -- Creature casts the spell.
  SELECT 1 unit_type, caster_unit_guid guid, unixtimems, 1 full
  FROM spell_cast_go
  WHERE caster_unit_id = @encounter_creature_id AND spell_id = @target_spell_id
  UNION ALL
  -- Enemy in range
  SELECT DISTINCT
    event_unit_enemy_distance.unit_type,
    event_unit_enemy_distance.guid,
    event_unit_enemy_distance.event_unixtimems,
    0 full
  FROM event_unit_enemy_distance
  JOIN (
    -- Faction change
    SELECT unixtimems FROM unit_faction_update
    UNION
    -- Incapacitate aura removed
    SELECT aura_removal.unixtimems
    FROM creature_auras_update aura_removal
    JOIN creature ON aura_removal.guid = creature.guid
    JOIN (
      SELECT
        aura_removal.guid,
        aura_removal.unixtimems removal_unixtimems,
        aura_removal.slot,
        MAX(aura_application.unixtimems) application_unixtimems
      FROM creature_auras_update aura_removal
      JOIN creature_auras_update aura_application
        ON aura_removal.guid = aura_application.guid AND aura_removal.slot = aura_application.slot
      WHERE aura_application.unixtimems < aura_removal.unixtimems
      GROUP BY aura_removal.guid, aura_removal.unixtimems, aura_removal.slot
    ) aura_application_time
      ON aura_removal.guid = aura_application_time.guid
      AND aura_removal.unixtimems = aura_application_time.removal_unixtimems
      AND aura_removal.slot = aura_application_time.slot
    JOIN creature_auras_update aura_application
      ON aura_removal.guid = aura_application.guid
      AND aura_removal.slot = aura_application.slot
      AND aura_application_time.application_unixtimems = aura_application.unixtimems
    JOIN incapacitate_spell ON aura_application.spell_id = incapacitate_spell.entry
    LEFT JOIN (
      SELECT
        aura_removal.guid,
        aura_removal.unixtimems removal_unixtimems,
        aura_removal.slot removal_slot,
        remaining_slot_update.slot remaining_slot,
        MAX(remaining_slot_update.unixtimems) remaining_unixtimems
      FROM creature_auras_update aura_removal
      JOIN creature_auras_update remaining_slot_update
        ON aura_removal.guid = remaining_slot_update.guid AND aura_removal.slot = remaining_slot_update.slot
      WHERE remaining_slot_update.slot <> aura_removal.slot
        AND remaining_slot_update.unixtimems < aura_removal.unixtimems
      GROUP BY aura_removal.guid, aura_removal.unixtimems, aura_removal.slot, remaining_slot_update.slot
    ) remaining_slot_update
      ON aura_removal.guid = remaining_slot_update.guid
      AND aura_removal.unixtimems = remaining_slot_update.removal_unixtimems
      AND aura_removal.slot = remaining_slot_update.removal_slot
    LEFT JOIN creature_auras_update remaining_aura
      ON aura_removal.guid = remaining_aura.guid
      AND remaining_slot_update.remaining_slot = remaining_aura.slot
      AND remaining_slot_update.remaining_unixtimems = remaining_aura.unixtimems
      AND remaining_aura.spell_id <> 0
    LEFT JOIN incapacitate_spell remaining_incapacitate_spell
      ON remaining_aura.spell_id = remaining_incapacitate_spell.entry
    WHERE aura_removal.spell_id = 0
      AND creature.id = @encounter_creature_id
      AND remaining_incapacitate_spell.entry IS NULL
    UNION
    -- Movement time polling
    SELECT unixtimems FROM generated_unixtimems
  ) movement ON event_unit_enemy_distance.event_unixtimems = movement.unixtimems
  WHERE event_unit_enemy_distance.distance <= @radius
) proximity_interval_start_event
JOIN (
  SELECT caster_unit_guid, caster_unit_id, spell_id, MIN(unixtimems) unixtimems
  FROM spell_cast_go
  GROUP BY caster_unit_guid, caster_unit_id, spell_id
) first_cast ON proximity_interval_start_event.guid = first_cast.caster_unit_guid
WHERE first_cast.caster_unit_id IS NOT NULL
  AND first_cast.spell_id = @target_spell_id
  AND proximity_interval_start_event.unixtimems >= first_cast.unixtimems;
SELECT
  start_event.unit_type,
  start_event.guid,
  start_event.unixtimems start_unixtimems,
  end_event_time.end_unixtimems,
  end_event_time.end_unixtimems - start_event.unixtimems duration,
  start_event.full AND end_event.full full
FROM proximity_interval_start_event start_event
JOIN (
  SELECT
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems start_unixtimems,
    MIN(proximity_interval_end_event.unixtimems) end_unixtimems
  FROM proximity_interval_start_event
  JOIN proximity_interval_end_event
    ON proximity_interval_start_event.unit_type = proximity_interval_end_event.unit_type
    AND proximity_interval_start_event.guid = proximity_interval_end_event.guid
  WHERE proximity_interval_start_event.unixtimems < proximity_interval_end_event.unixtimems
  GROUP BY
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems
) end_event_time
  ON start_event.unit_type = end_event_time.unit_type
  AND start_event.guid = end_event_time.guid
  AND start_event.unixtimems = end_event_time.start_unixtimems
JOIN proximity_interval_end_event end_event
  ON start_event.unit_type = end_event.unit_type
  AND start_event.guid = end_event.guid
  AND end_event_time.end_unixtimems = end_event.unixtimems
LEFT JOIN (
  SELECT
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems start_unixtimems,
    MAX(proximity_interval_end_event.unixtimems) end_unixtimems
  FROM proximity_interval_start_event
  JOIN proximity_interval_end_event
    ON proximity_interval_start_event.unit_type = proximity_interval_end_event.unit_type
    AND proximity_interval_start_event.guid = proximity_interval_end_event.guid
  WHERE proximity_interval_end_event.unixtimems < proximity_interval_start_event.unixtimems
  GROUP BY
    proximity_interval_start_event.unit_type,
    proximity_interval_start_event.guid,
    proximity_interval_start_event.unixtimems
) previous_end_event
  ON start_event.unit_type = previous_end_event.unit_type
  AND start_event.guid = previous_end_event.guid
  AND start_event.unixtimems = previous_end_event.start_unixtimems
LEFT JOIN proximity_interval_start_event previous_start_event
  ON start_event.unit_type = previous_start_event.unit_type
  AND start_event.guid = previous_start_event.guid
  AND start_event.unixtimems > previous_start_event.unixtimems
  AND (previous_end_event.unit_type IS NULL OR previous_start_event.unixtimems >= previous_end_event.end_unixtimems)
WHERE previous_start_event.unit_type IS NULL
ORDER BY duration, start_unixtimems, start_event.guid;
