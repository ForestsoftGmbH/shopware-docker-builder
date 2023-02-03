<?php
declare(strict_types=1);

use Symfony\Component\Dotenv\Dotenv;

$projectDir = "/var/www/html";
include_once $projectDir . '/vendor/autoload.php';

function checkPluginDate(?string $date) {
    if ($date != null ) {
        $date = strtotime($date);
        return ($date === false) ? 1 : 0;
    }
    return 1;
}

$plugin = $argv[1];
$ask = $argv[2] ?? '';

try {
    if (empty($ask)) {
        if (empty($plugin)) {
            $plugin = "<pluginName>";
        }
        throw new \InvalidArgumentException("Please define ./plugin.php $plugin installed|update|active");
    }

    $config = include $projectDir . "/config.php";
    if (getenv("SHOPWARE_ENV") == "testing") {
        $config['db']['dbname'] = $config['db']['dbname'] . "_test";
    }
    $pdo = new PDO("mysql:host=" . $config["db"]['host'] . ";dbname=" . $config['db']['dbname'], $config["db"]['username'], $config['db']['password']);
    $result = 1;
    $stmt = $pdo->query("SELECT installation_date,update_version,active from s_core_plugins WHERE name='${plugin}'");
    if ($stmt->rowCount() > 0) {
        $pluginInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        switch ($ask) {
            case "installed":
                $result = checkPluginDate($pluginInfo['installation_date']);
                break;
            case "update":
                $result = checkPluginDate($pluginInfo['update_version']);
                $result = $result == 1 ? 0 : 1;
                break;
            case "active":
            default:
                $result = ($pluginInfo['active'] === "0") ? 1 : 0;
        }
    }
} catch(\Exception $e) {
    echo $e->getMessage() . "\n";
}
echo $result;
exit($result);
