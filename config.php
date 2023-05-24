<?php
use Shopware\Components\Logger;

return [
    'db' => [
        'username' => getenv("DB_USER"),
        'password' => getenv("DB_PASSWORD"),
        'dbname' => getenv("DB_NAME"),
        'host' => getenv('DB_HOST'),
        'port' => getenv('DB_PORT'),
    ],
    
    'front' => [
        'throwExceptions' => true,
        'showException' => true
    ],

    'phpsettings' => [
        'display_errors' => 1
    ],

    'template' => [
        'forceCompile' => true
    ],
    
    'logger' => [
        'level' => Logger::DEBUG
    ],
];
