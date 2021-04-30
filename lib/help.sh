#!/bin/bash

# Helps to use this program
# Author: Paulo Henrique Ortolan

# Writes the basic syntax
function syntax() {
  echo "vpc-report <PROFILE> <REGION>"
  echo ""
  echo "No $1 supplied."
  exit 1
}
