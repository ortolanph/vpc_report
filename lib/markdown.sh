#!/bin/bash

# Simple markdown functions
# Author: Paulo Henrique Ortolan

# Creates a new line
function new_line() {
	echo ""
}

# Creates an H1 header
function h1() {
	echo "# $1"
	new_line
}

# Creates an H2 header
function h2() {
	echo "## $1"
	new_line
}

# Creates an H3 header
function h3() {
	echo "### $1"
	new_line
}

# Creates a bullet field
function bullet_field() {
	echo "* $1: **$2**"
}

function bold() {
	echo "**$1**"
}
