#! /bin/bash

php /app/lms/moodle/admin/tool/phpunit/cli/init.php
/app/lms/moodle/vendor/bin/phpunit -c "/app/lms/moodle/${PHPUNIT_CONFIG}.xml" --log-junit "${RESULTS_DIR}/${PHPUNIT_CONFIG}.xml"
