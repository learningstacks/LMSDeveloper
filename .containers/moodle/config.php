<?php // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost = 'db';
$CFG->dbname = 'moodle';
$CFG->dbuser = 'moodle';
$CFG->dbpass = 'moodle';
$CFG->prefix = 'm_';
$CFG->dboptions = [
    'dbcollation' => 'utf8mb4_bin'
];

$host = 'localhost';
if (!empty(getenv('MOODLE_DOCKER_WEB_HOST'))) {
    $host = getenv('MOODLE_DOCKER_WEB_HOST');
}
$CFG->wwwroot = "http://localhost:8000";
$CFG->dataroot = '/appdata/moodledata';
$CFG->admin = 'admin';
$CFG->directorypermissions = 0777;
$CFG->smtphosts = 'mailhog:1025';

// Debug options - possible to be controlled by flag in future..
$CFG->debug = 0;
$CFG->debugdisplay = 0;
$CFG->debugstringids = 0; // Add strings=1 to url to get string ids.
$CFG->perfdebug = 0;
$CFG->debugpageinfo = 0;
$CFG->allowthemechangeonurl = 1;
$CFG->passwordpolicy = 0;
$CFG->cronclionly = 0;
$CFG->pathtophp = '/usr/local/bin/php';

$CFG->phpunit_dataroot = '/appdata/phpunitdata';
$CFG->phpunit_prefix = 'phpu_';
define('TEST_EXTERNAL_FILES_HTTP_URL', "http://moodle/exttests");

$CFG->behat_wwwroot = "http://behat";
$CFG->behat_dataroot = '/appdata/behatdata';
$CFG->behat_dataroot_parent = $CFG->behat_dataroot;
$CFG->behat_prefix = 'b_';
// $CFG->behat_profiles = array(
//     'default' => array(
//         'suites' => [
//             'browser' => getenv('MOODLE_DOCKER_BROWSER'),
//             'wd_host' => 'http://selenium:4444/wd/hub',
//             'default' => [
//                 'contexts' => [
//                     'MinkContext'
//                 ]
//             ]
//         ]
//     ),
// );

$CFG->behat_config = [
    'default' => [
        'suites' => [
            'default' => [
                // 'contexts' => [
                //     'MinkContext'
                // ],
                'filters' => [
                    'tags' => '~@app&&~@core_search'
                ],
            ],
        ],
        'extensions' => [
            'Behat\MinkExtension' => [
                'selenium2' => [
                    'browser' => getenv('MOODLE_DOCKER_BROWSER'),
                    'wd_host' => 'http://selenium:4444/wd/hub',
                ]
            ]
        ]
    ]
];

$CFG->behat_faildump_path = empty(getenv('BEHAT_FAILDUMP_DIR')) ? "/app/tmp/faildump" : getenv('BEHAT_FAILDUMP_DIR');

if (getenv('MOODLE_DOCKER_APP')) {
    $CFG->behat_ionic_wwwroot = 'http://moodleapp:8100';
}

// if (getenv('MOODLE_DOCKER_PHPUNIT_EXTRAS')) {
//     define('TEST_SEARCH_SOLR_HOSTNAME', 'solr');
//     define('TEST_SEARCH_SOLR_INDEXNAME', 'test');
//     define('TEST_SEARCH_SOLR_PORT', 8983);

//     define('TEST_SESSION_REDIS_HOST', 'redis');
//     define('TEST_CACHESTORE_REDIS_TESTSERVERS', 'redis');

//     define('TEST_CACHESTORE_MONGODB_TESTSERVER', 'mongodb://mongo:27017');

//     define('TEST_CACHESTORE_MEMCACHED_TESTSERVERS', "memcached0:11211\nmemcached1:11211");
//     define('TEST_CACHESTORE_MEMCACHE_TESTSERVERS', "memcached0:11211\nmemcached1:11211");

//     define('TEST_LDAPLIB_HOST_URL', 'ldap://ldap');
//     define('TEST_LDAPLIB_BIND_DN', 'cn=admin,dc=openstack,dc=org');
//     define('TEST_LDAPLIB_BIND_PW', 'password');
//     define('TEST_LDAPLIB_DOMAIN', 'ou=Users,dc=openstack,dc=org');

//     define('TEST_AUTH_LDAP_HOST_URL', 'ldap://ldap');
//     define('TEST_AUTH_LDAP_BIND_DN', 'cn=admin,dc=openstack,dc=org');
//     define('TEST_AUTH_LDAP_BIND_PW', 'password');
//     define('TEST_AUTH_LDAP_DOMAIN', 'ou=Users,dc=openstack,dc=org');

//     define('TEST_ENROL_LDAP_HOST_URL', 'ldap://ldap');
//     define('TEST_ENROL_LDAP_BIND_DN', 'cn=admin,dc=openstack,dc=org');
//     define('TEST_ENROL_LDAP_BIND_PW', 'password');
//     define('TEST_ENROL_LDAP_DOMAIN', 'ou=Users,dc=openstack,dc=org');
// }

require_once(__DIR__ . '/../../moodle-browser-config/init.php');
require_once(__DIR__ . '/lib/setup.php');
