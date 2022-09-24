select roles,
	substr(roles, 1, instr(roles, ':')- 1),
    substring_index(roles, ':', 2),
    substring_index(substring_index(roles, ':', -2), ':', 1)
from dota.hero_data
limit 100;