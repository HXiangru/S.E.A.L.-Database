UPDATE uncertainty
SET picture_number = data_tags.picture_number
FROM data_tags
WHERE uncertainty.serial_id = data_tags.logic_tag;