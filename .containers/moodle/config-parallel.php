<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost = 'localhost';
$CFG->dbname = 'moodle';
$CFG->dbuser = 'moodle';
$CFG->dbpass = 'moodle';
$CFG->prefix = 'mdl_';
$CFG->dboptions = array(
    'dbpersist' => 0,
    'dbport' => 3310,
    'dbsocket' => '',
);

$CFG->wwwroot = 'http://lms.cliengage.local:8000';
$CFG->dataroot = __DIR__ . '/../../data/moodle';
$CFG->admin = 'admin';

$CFG->sso_domain = 'cliengage-dev2.uth.tmc.edu';
$CFG->cli = "https://{$CFG->sso_domain}";
$CFG->static = "https://static.{$CFG->sso_domain}";
$CFG->sso = "https://sso.{$CFG->sso_domain}";
$CFG->sso_url = "https://sso.{$CFG->sso_domain}/home/LostSession?IASID=012";
$CFG->cookiedomain = "{$CFG->sso_domain}";

//CLI MainDB settings 06/02/2017 David
$CFG->clihost = "SQL14DTWPVS1.uthouston.edu";
$CFG->clidbname = "cliengage-db-dev";
$CFG->clidbuser = 'cliengage-dev-user';
$CFG->clidbpass = 'cL1eng@ge';
$CFG->cookie_iv = hex2bin('1E7FE9231C7AB822');
$CFG->cookie_key = hex2bin('11362E7A9285DD53A0BBA2932F9733C505DC04EDBFE00D70');
$CFG->name_iv = '.!e@0Na&';
$CFG->name_key = '.!e@0Na&';
$CFG->sso_cookie_name = 'CLIEngageToken';
// PHPUnit

$CFG->phpunit_prefix = 'phpu_';
$CFG->phpunit_dataroot = __DIR__ . '/../../data/phpunit';

$CFG->directorypermissions = 0777;

// Behat
$CFG->behat_prefix = 'bht_';
$CFG->behat_dataroot = __DIR__ . '/../../data/behat';
$CFG->behat_wwwroot = 'http://behat.cliengage.local:8000'; // must be different from wwwroot
$CFG->behat_faildump_path = __DIR__ . '/../../test_results/faildump';
if (!empty(getenv('BEHAT_FAILDUMP_DIR'))) {
    $CFG->behat_faildump_path = getenv('BEHAT_FAILDUMP_DIR');
}

$CFG->behat_parallel_run = [
    [
        'behat_wwwroot' => "{$CFG->behat_wwwroot}/behatrun1",
        'wd_host' => 'http://localhost:4444/wd/hub',
    ],
    [
        'behat_wwwroot' => "{$CFG->behat_wwwroot}/behatrun2",
        'wd_host' => 'http://localhost:4445/wd/hub',
    ],
    [
        'behat_wwwroot' => "{$CFG->behat_wwwroot}/behatrun3",
        'wd_host' => 'http://localhost:4446/wd/hub',
    ],
    "behat_wwwroot" => [
        ["behat_wwwroot" => "{$CFG->behat_wwwroot}/behatrun1"],
        ["behat_wwwroot" => "{$CFG->behat_wwwroot}/behatrun2"],
        ["behat_wwwroot" => "{$CFG->behat_wwwroot}/behatrun2"]
    ]
];


 $CFG->behat_profiles = [
     'default' => [
         'browser' => 'chrome',
         'extensions' => [
             'Behat/MinkExtension' => [
                 // 'browser_name' => 'chrome',
                 // 'base_url' => $CFG->behat_wwwroot,
                 'goutte' => null,
                 'selenium2' => [
                     'browser' => 'firefox',
//                     'wd_host' => 'http://localhost:4444/wd/hub',
//                     'capabilities' => [
//                         'chrome' => [
//                             'switches' => [
//                                 "--headless",
//                                 "--disable-gpu",
//                                 "--window-size=1920,1080",
//                                 "--no-sandbox",
//                             ]
//                         ]
//                     ]
                 ],
             ]
         ]
     ],
 ];
$CFG->behat_profiles = array(
    'default' => array(
        'browser' => 'firefox',
    )
);
// require_once(__DIR__ . '/../../moodle-browser-config/init.php');

require_once(__DIR__ . '/lib/setup.php'); // Do not edit
                    
                    // There is no php closing tag in this file,
                    // it is intentional because it prevents trailing whitespace problems!
