EXTENSION = cbor
DATA = cbor--1.0.sql
REGRESS = ok

EXTRA_CLEAN = cbor--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: readme cbor--1.0.sql

SQL_SRC = \
  complain_header.sql \
	TYPES/next_state.sql \
	FUNCTIONS/raise.sql \
	FUNCTIONS/bytea_to_numeric.sql \
	FUNCTIONS/next_item.sql \
	FUNCTIONS/next_array.sql \
	FUNCTIONS/next_map.sql \
  FUNCTIONS/to_jsonb.sql \
	COMMENTS/next_state.sql

cbor--1.0.sql: $(SQL_SRC)
	cat $^ > $@

readme:
	sh README.sh
