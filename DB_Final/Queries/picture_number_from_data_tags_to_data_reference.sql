UPDATE data_reference
SET picture_number = data_tags.picture_number
FROM data_tags
WHERE data_reference.serial_id = data_tags.logic_tag;
