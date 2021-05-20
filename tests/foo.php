<?php
phpinfo();


// Force OPcache reset if used, we do not want any stale caches
// when preparing test environment.
$a = 1;

// Is not really necessary but adding it as is a CLI_SCRIPT.
// define('CLI_SCRIPT', true);
// define('CACHE_DISABLE_ALL', true);

// require_once('/app/lms/moodle/config.php');
// require_once('/app/lms/moodle/lib/clilib.php');
// require_once('/app/lms/moodle/lib/behat/classes/behat_config_util.php');

// $tags = '';
// $parallelruns = 1;
// $run = 1;
// $behatconfigutil = new behat_config_util();
// $behatconfigutil->set_theme_suite_to_include_core_features('theme_cliengage3');
// $behatconfigutil->set_tag_for_feature_filter($tags);
// $features = $behatconfigutil->get_components_features('local_cliengage,local_datahub');
// $stepsdefinitions = $behatconfigutil->get_components_contexts();
// $contents = $behatconfigutil->get_config_file_contents($features, $stepsdefinitions, $tags, $parallelruns, $run);
// print_r($contents);

// exit(0);
