<?php
$databases = array();
$databases['default']['default'] = array(
    'driver' => 'mysql',
   'database' => 'test',
   'username' => 'root',
   'password' => 'test',
   'host' => 'localhost',
  );
$settings['hash_salt'] = hash('sha256', serialize($databases));
$settings['install_profile'] = 'standard';
