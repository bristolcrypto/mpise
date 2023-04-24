
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# =============================================================================

COMPONENTS = gcc pk spike-full spike-reduced 

all: clone apply build 

define rule_clone
$(strip ${1})-clone:
	@$${REPO_HOME}/src/sw-toolchain/$(strip ${1})-clone.sh
endef

define rule_apply
$(strip ${1})-apply:
	@$${REPO_HOME}/src/sw-toolchain/$(strip ${1})-apply.sh
endef

define rule_build
$(strip ${1})-build:
	@$${REPO_HOME}/src/sw-toolchain/$(strip ${1})-build.sh
endef

$(foreach COMPONENT,${COMPONENTS},$(eval $(call rule_clone, ${COMPONENT})))
$(foreach COMPONENT,${COMPONENTS},$(eval $(call rule_apply, ${COMPONENT})))
$(foreach COMPONENT,${COMPONENTS},$(eval $(call rule_build, ${COMPONENT})))

clone: $(foreach COMPONENT, ${COMPONENTS}, ${COMPONENT}-clone )
apply: $(foreach COMPONENT, ${COMPONENTS}, ${COMPONENT}-apply )
build: $(foreach COMPONENT, ${COMPONENTS}, ${COMPONENT}-build )

clean:
	@rm --force --recursive ${REPO_HOME}/build/sw-toolchain

# =============================================================================
