EXTENSION = cbor
DATA = cbor--1.0.sql
REGRESS = rfc7049_appendix_a \
	webauthn \
	multiple_root_level_items \
	major_type_0 \
	major_type_1 \
	major_type_2

EXTRA_CLEAN = cbor--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: cbor--1.0.sql

SQL_SRC = \
  complain_header.sql \
	TYPES/next_state.sql \
	FUNCTIONS/raise.sql \
	FUNCTIONS/bytea_to_numeric.sql \
	FUNCTIONS/numeric_to_bytea.sql \
	FUNCTIONS/next_float_half.sql \
	FUNCTIONS/next_float_single.sql \
	FUNCTIONS/next_float_double.sql \
	FUNCTIONS/next_item.sql \
	FUNCTIONS/next_array.sql \
	FUNCTIONS/next_map.sql \
	FUNCTIONS/next_indefinite_array.sql \
	FUNCTIONS/next_indefinite_map.sql \
	FUNCTIONS/next_indefinite_byte_string.sql \
	FUNCTIONS/next_indefinite_text_string.sql \
  FUNCTIONS/to_jsonb.sql \
  FUNCTIONS/to_jsonb_array.sql \
	COMMENTS/next_state.sql

cbor--1.0.sql: $(SQL_SRC)
	cat $^ > $@
