# See LICENSE for licensing information.

PROJECT = jop

# Options.

CT_OPTS += -pa test 
CI_OTP = OTP-18.0.2

# Dependencies.

TEST_DEPS = ct_helper
dep_ct_helper = git https://github.com/ninenines/ct_helper master

# Standard targets.

include erlang.mk

# Also dialyze the tests.

DIALYZER_OPTS += --src -r test
