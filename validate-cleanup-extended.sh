#!/bin/bash

echo "Starting Extended Cleanup Validation..."

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Create output folder
OUTPUT_DIR=cleanup-validation-output
mkdir -p $OUTPUT_DIR

# Result placeholders
BUILD_SUCCESS=false
TEST_SUCCESS=false
ENDPOINT_SUCCESS=false
FILES_OK=true
CONFIG_OK=true
EXPLANATION_OK=true

RESULT_JSON="$OUTPUT_DIR/report.json"
touch $RESULT_JSON

function check_file() {
  if [ ! -f "$1" ]; then
    echo -e "${RED} Missing file: $1${NC}"
    FILES_OK=false
  else
    echo -e "${GREEN} Found: $1${NC}"
  fi
}

echo "Compiling project..."
mvn clean install > $OUTPUT_DIR/build.log 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN} Build successful${NC}"
  BUILD_SUCCESS=true
else
  echo -e "${RED} Build failed${NC}"
fi

echo " Running tests..."
mvn test > $OUTPUT_DIR/test.log 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN} Tests passed${NC}"
  TEST_SUCCESS=true
else
  echo -e "${RED} Tests failed${NC}"
fi

echo " Starting app..."
mvn spring-boot:run > $OUTPUT_DIR/app.log 2>&1 &
APP_PID=$!
sleep 10

echo " Testing /employees endpoint..."
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/employees)
if [ "$STATUS_CODE" == "200" ]; then
  echo -e "${GREEN} Endpoint responded with 200${NC}"
  ENDPOINT_SUCCESS=true
else
  echo -e "${RED} Endpoint failed with status $STATUS_CODE${NC}"
fi

echo " Stopping app..."
kill $APP_PID
sleep 3

echo " Checking critical files..."
check_file src/main/java/com/acme/ems/controller/EmployeeController.java
check_file src/main/java/com/acme/ems/service/EmployeeService.java
check_file src/main/java/com/acme/ems/model/Employee.java
check_file src/main/java/com/acme/ems/logging/EmployeeAuditLogger.java
check_file src/main/java/com/acme/ems/job/ArchivedEmployeeCleanupJob.java
check_file src/main/java/com/acme/ems/util/EmployeeUtils.java
check_file src/main/java/com/acme/ems/exception/CustomExceptionHandler.java

echo " Checking configs..."
check_file src/main/resources/data.sql
check_file src/test/resources/employee-legacy.yml
check_file src/test/resources/application-test.yml

echo " Checking for cleanup explanation..."
if grep -q "deleted" cleanup-summary.txt 2>/dev/null; then
  echo -e "${GREEN} cleanup-summary.txt found and contains reasoning${NC}"
  EXPLANATION_OK=true
else
  echo -e "${RED}  cleanup-summary.txt missing or unclear${NC}"
  EXPLANATION_OK=false
fi

echo " Writing validation report..."
cat <<EOF > $RESULT_JSON
{
  "build": $BUILD_SUCCESS,
  "tests": $TEST_SUCCESS,
  "endpoint": $ENDPOINT_SUCCESS,
  "filesOk": $FILES_OK,
  "configOk": $CONFIG_OK,
  "explanationOk": $EXPLANATION_OK
}
EOF

echo -e "\n Validation complete. Report generated at $RESULT_JSON"
