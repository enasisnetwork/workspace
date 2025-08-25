# Operation recipes for managing the projects and execution environment.
#
# This file is part of Enasis Network software eco-system. Distribution
# is permitted, for more information consult the project license file.



WKSP_PROJKEY += \
	ansbutility \
	ansbprojects \
	ansbcertauth \
	ansbprovision \
	ansbdomain \
	ansbappstack \
	ansbinternal
WKSP_MEXTEND += \
	ansbutility \
	ansbprojects \
	ansbcertauth \
	ansbprovision \
	ansbdomain \
	ansbappstack \
	ansbinternal

WKSP_ansbutility_BASE = Projects
WKSP_ansbutility_PATH = ansible-utility
WKSP_ansbutility_GITR = git@github.com:enasisnetwork/ansible-utility.git

WKSP_ansbprojects_BASE = Projects
WKSP_ansbprojects_PATH = ansible-projects
WKSP_ansbprojects_GITR = git@github.com:enasisnetwork/ansible-projects.git

WKSP_ansbcertauth_BASE = Projects
WKSP_ansbcertauth_PATH = ansible-certauth
WKSP_ansbcertauth_GITR = git@github.com:enasisnetwork/ansible-certauth.git

WKSP_ansbprovision_BASE = Projects
WKSP_ansbprovision_PATH = ansible-provision
WKSP_ansbprovision_GITR = git@github.com:enasisnetwork/ansible-provision.git

WKSP_ansbdomain_BASE = Projects
WKSP_ansbdomain_PATH = ansible-domain
WKSP_ansbdomain_GITR = git@github.com:enasisnetwork/ansible-domain.git

WKSP_ansbappstack_BASE = Projects
WKSP_ansbappstack_PATH = ansible-appstack
WKSP_ansbappstack_GITR = git@github.com:enasisnetwork/ansible-appstack.git

WKSP_ansbinternal_BASE = Projects
WKSP_ansbinternal_PATH = ansible-internal
WKSP_ansbinternal_GITR = git@github.com:enasisnetwork/ansible-internal.git
