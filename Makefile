include .env

## help	:	Print commands help.
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up	:	Creates new release redy tag.
bump:
	scripts/bump

.PHONY: help bump
