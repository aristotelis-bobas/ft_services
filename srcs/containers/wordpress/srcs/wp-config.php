<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'root' );

/** MySQL database password */
define( 'DB_PASSWORD', 'password' );

/** MySQL hostname */
define( 'DB_HOST', 'mysql-service:5100' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

set_time_limit(300);

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'g!uk^:c-rjXDzBNu3mE9i1jAKQerD*16kLBCtzIBZJ.>q26xudjjIC;8/.D7hKI3' );
define( 'SECURE_AUTH_KEY',  'Fr%7$_)0/MjFR1wT9 D|P%flNerikDPym[NwNq8I/<5h4],V22M9&~Bt#_5+3SPc' );
define( 'LOGGED_IN_KEY',    '<r}+)E8-,YjdT5Y$?hPgiB4}#BikT3iug([ap4g&1$R,&=+?U1&}HIiG}=ya)U%a' );
define( 'NONCE_KEY',        '`T/l$NfC|>V,c+:pr1)<)#:gy,f1.ZLE1*$%KcTdZSasVy03KXah4:cVu*X(sU+a' );
define( 'AUTH_SALT',        '+q_|/~_CJodM&v/8/vwR$lrA;$!Vc8TTLW#u?dDA#mERyj21v^ansy_kpScSTX/6' );
define( 'SECURE_AUTH_SALT', '>Oa<O&zTx,7COQ]UO`;`g|eViF;#3Z=U3?tYg8^{;ypEnl7/T@>]plAF,.4[eF1~' );
define( 'LOGGED_IN_SALT',   '*vuz,2It]_u%1,zFlc#rl_=}(+pY=coc,fYXaAC6<?LJZhBdWakw0-h)>/CFv6:(' );
define( 'NONCE_SALT',       'UqrTT0}xEqV*ao!r;}3~D~+f }(EYJq-Nwq}<q|Xxpl@c!P3qf[*>uV~eStj695V' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );