-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM data_tags
WHERE logic_tag IN (125, 126, 127);

-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM data_reference
WHERE serial_id IN (125, 126, 127);

-- Assuming you want to delete rows from data_tags where logic_tag is in [125, 126, 127]
DELETE FROM uncertainty
WHERE serial_id IN (125, 126, 127);

