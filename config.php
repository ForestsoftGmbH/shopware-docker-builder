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

    'csrfProtection' => [
        'frontend' => false,
        'backend' => false,
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

    // Backend-Cache
    'cache' => [
        'backend' => 'Black-Hole',
        'backendOptions' => [],
        'frontendOptions' => [
            'write_control' => false,
        ],
    ],

    // Model-Cache
    'model' => [
        'cacheProvider' =>  'Array', // supports Apc, Array, Wincache and Xcache
    ],

    // Http-Cache
    'httpCache' => [
        'enabled' => false,
        'debug' => true,
    ],

    'logger' => [
        'level' => Logger::DEBUG
    ],

    'mail' => [
        'type' => 'file',
        'host' => '',
        'port' => 1025,
    ],
];
