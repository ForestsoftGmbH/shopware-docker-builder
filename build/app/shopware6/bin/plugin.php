<?php
declare(strict_types=1);

use Symfony\Component\Dotenv\Dotenv;

include_once(__DIR__ . '/../vendor/autoload.php');
$envFile = __DIR__ . '/../.env';

function checkPluginDate(?string $date) {
    if ($date != null ) {
        $date = strtotime($date);
        return ($date === false) ? 1 : 0;
    }
    return 1;
}

$plugin = $argv[1];
$ask = $argv[2] ?? '';

if (class_exists(Dotenv::class) && is_readable($envFile) && !is_dir($envFile)) {
    (new Dotenv())->usePutenv()->load($envFile);
}
$url = parse_url($_SERVER['DATABASE_URL']);
$pdo = new PDO("mysql:host=" . $url["host"] . ";dbname=" . str_replace("/", "", $url['path']), $url["user"], $url['pass']);
$result = 1;
$stmt = $pdo->query("SELECT * from plugin WHERE name='${plugin}'");
if ($stmt->rowCount() > 0) {
    $pluginInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    switch ($ask) {
        case "installed":
            $result = checkPluginDate($pluginInfo['installed_at']);
            break;
        case "update":
            $result = checkPluginDate($pluginInfo['upgrade_version']);
            $result = $result == 1 ? 0 : 1;
            break;
        case "active":
        default:
            $result = ($pluginInfo['active'] === "0") ? 1 : 0;
    }
}
echo $result;
exit($result);
