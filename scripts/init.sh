#!/bin/bash
gcloud auth application-default login
terraform -chdir="terraform/" init