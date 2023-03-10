make a list of packages.
curl them into a place
build them
add them to the repo

be able
  to install the repo into pacman.conf
  clean everything out
  download everything.
  make all packages.
  add all to repo.






curl foo > foo

# needed by 2011 17" macbook pro, 8,2.
https://aur.archlinux.org/packages/b43-firmware
https://aur.archlinux.org/packages/b43-fwcutter

https://aur.archlinux.org/packages/yay
b43-firmware
b43-fwcutter
yay

Add to this list... - these were needed by my Archiso

# official packages.
broadcom-wl
git
vi
networkmanager
nm-connection-editor


# The root folder you want to put stuff for
# project path to say where everything is checked out to.
project-base := ~/play/my-arch-repo/

# Places for things.
# We've got projects, docs, libraries and modules so far.
projpath := $(project-base)/projects
docpath := $(project-base)/docs
libpath := $(project-base)/libs
modpath := $(project-base)/mods
pluginpath := $(project-base)/plugins
plugindest := ~/.kicad_plugins

# kicad keeps it's stuff here.
kicad-share := /usr/share/kicad

# How to install a package on your system.
# This is Arch Linux
arch-install-cmd := sudo pacman -S --noconfirm --needed
package-install-cmd := $(arch-install-cmd)

# Purpose:
# Install kicad and then go clone (github,gitlab,)
# a bunch of stuff and install that.
#   - kicad librarys and modules.
#   - doc repos
#   - sample project repos.

# This is basically a kicad intallation with some extra
# libraries and modules, some example projects and some
# docs.  My focus is towards creating keyboards at the moment
# so that's where the focus is. it could certainly grow
# from here.

# The Goals:
# * install kicad and the default libraries and modules.
# check out additional libraries and modules.
# Copy the librarys and modules to /usr/share/kicad/ where
# it wants them.
# check out some other projects for exmaples.
# keep everything organized in a folder in a projects tree.

# I have no idea if there are conflicts between libraries and
# modules here. It can be sorted out, but I havent.

# So read the code here. This is make. its easy.
#
# There are different things we need and want.
#   - Stuff to install with system installer - pacman - Arch linux.
#   - Github things
#     - Kicad things
#       - libraries
#       - modules
#       - plugins
#     - Extra samples and stuff to read.
#       - projects.
#       - docs.
#
# These are some choices...
# - make all        - to do it all.
#
# - make, make all  - everything. - it's the default if you dont say.
# - make install    - no projects or docs.
# - make clean      - remove the projects, everything but the installed
#                     modules and libraries.,
#
# so to install everything and forget about it,
#     make install; make clean

# Other possiblities:
#    make install-kicad install-mods install-libs
#    make projects libs mods, docs

# Read the makefile here. It is easy to understand.

# understandably, make doesn't like colons in it's target names.
http := "https://"

###############################################################
# Define our lists of things.
###############################################################

# packages for pacman
kicad-pkgs := kicad kicad-library kicad-library-3d

# libraries for kicad
libraries := github.com/tmk/kicad_lib_tmk.git \
	github.com/keebio/keebio-components.git \
	github.com/foostan/kbd.git \
	github.com/daprice/keyswitches.pretty.git


# modules for kicad
modules := github.com/tmk/keyboard_parts.pretty.git \
	github.com/egladman/keebs.pretty.git \
	github.com/keebio/Keebio-Parts.pretty.git \
	github.com/keebio/Hybrid-Switches.pretty.git

# plugins for kicad
plugins := github.com/MitjaNemec/Kicad_action_plugins.git \
	github.com/easyw/RF-tools-KiCAD.git \
	github.com/jsreynaud/kicad-action-scripts.git \
	github.com/NilujePerchut/kicad_scripts.git

# just some docs.
docs := github.com/keebio/keebio-docs.git

# Sample keyboard projects.
projects := github.com/kiibohd/pcb.git \
        github.com/zgtk-guri/c-pro-micro.git \
	github.com/foostan/crkbd.git \
        github.com/foostan/mkbd.git \
	github.com/vlukash/corne-trackpad.git \
	github.com/Biacco42/Ergo42.git \
	github.com/josefadamcik/SofleKeyboard.git \
	github.com/MakotoKurauchi/helix.git \
	github.com/kata0510/Lily58.git \
	github.com/tamanishi/Pinky3.git \
	github.com/tamanishi/Pinky4.git

######################################################################
# Set up the dependencies and the install rules.
######################################################################
# an experiment
docword := $(lastword $(subst  /, , $(docs)))
wc_docs := $(if $(wildcard $(docpath)/$(subst .git, , $(lastword $(stubst /, , $@)))),\
	hello, NO)

# handy for printing variables and debugging your Makefile.
print-%  : ; @echo $* = $($*)

# do our phonies.
.PHONY: libs modules docs mods plugins install-plugins
.PHONY: install-kicad install-mods install-libs clean

everything := $(kicad-pkgs) $(libraries) $(modules) $(docs) $(projects)
.PHONY: $(everything)


# set up our targets and dependencies.
# first target is the default
all: $(everything) install

install: install-kicad install-libs install-mods install-plugins

install-kicad: $(kicad-pkgs)

$(kicad-pkgs):
	$(package-install-cmd) $@

# copy the libs and modules to /usr/share/kicad ?
# pretty directorys go in modules, libs and dcms go in library
install-libs: libs
	sudo cp -r $(libpath)/*/* $(kicad-share)/library/

install-mods: mods
	sudo cp -r $(modpath)/* $(kicad-share)/modules/

install-plugins: plugins
	mkdir -p $(plugindest)
	cp -r $(pluginpath)/*/* $(plugindest)

# Some nice names to make.
libs : $(libraries)

mods : $(modules)

plugins : $(plugins)

docs : $(docs)

projects : $(projects)

clean:
	rm -rf $(projpath)
	rm -rf $(libpath)
	rm -rf $(modpath)
	rm -rf $(docpath)


#########################################################################
# Handle the different types of actions needed for
# gathering all the different things.
# All the same but to different places.
#########################################################################

cloneit = $(mkdir -p $1; cd $1; git clone $(http)$2)
do-path = $1/$(firstword $(subst .git, , $(lastword $(subst  /, , $2))))

# I get this right and the rule doesn't want to go.
# $(if $(wildcard $(call do-path, $(docpath), $@)), echo "Nothing to do", \
# 	$(call cloneit, $(docpath), $@) )

# these work at least.
# do the real work.
$(libraries):
	if [[ ! -d $(call do-path, $(libpath), $@) ]]; then \
	    mkdir -p $(libpath); \
	    cd $(libpath); git clone $(http)$@; \
	fi

$(modules):
	if [[ ! -d $(call do-path, $(modpath), $@) ]]; then \
	    mkdir -p $(modpath); \
	    cd $(modpath); git clone $(http)$@; \
	fi


$(docs):
	if [[ ! -d $(call do-path, $(docpath), $@) ]]; then \
	    mkdir -p $(docpath); \
	    cd $(docpath); git clone $(http)$@; \
	fi

$(projects):
	if [[ ! -d $(call do-path, $(projpath), $@) ]]; then \
	    mkdir -p $(projpath); \
	    cd $(projpath); git clone $(http)$@; \
	fi

$(plugins):
	if [[ ! -d $(call do-path, $(pluginpath), $@) ]]; then \
	    mkdir -p $(pluginpath); \
	    cd $(pluginpath); git clone $(http)$@; \
	fi
