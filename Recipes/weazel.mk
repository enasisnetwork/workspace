# Operation recipes for managing the projects and execution environment.
#
# This file is part of Enasis Network software eco-system. Distribution
# is permitted, for more information consult the project license file.



WKSP_PROJKEY += weazel weazelstatic weazelconf
WKSP_MEXTEND += weazel

WKSP_weazel_BASE = Projects
WKSP_weazel_PATH = weazel
WKSP_weazel_GITR = git@github.com:rawberth/weazel.git

WKSP_weazelstatic_BASE = Projects
WKSP_weazelstatic_PATH = weazel-static
WKSP_weazelstatic_GITR = git@github.com:rawberth/weazel.git
WKSP_weazelstatic_GITB = static

WKSP_weazelconf_BASE = Configure
WKSP_weazelconf_PATH = weazel-conf
WKSP_weazelconf_GITR = git@github.com:rawberth/weazel-conf.git
