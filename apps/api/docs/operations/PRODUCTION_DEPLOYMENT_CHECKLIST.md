# AgriLink Lanka API Production Checklist

## Required environment values

- `APP_ENV=production`
- `APP_DEBUG=false`
- `APP_URL=https://api.example.com`
- PostgreSQL `DB_*` values
- Redis `REDIS_*` values
- Strong generated `APP_KEY`
- Valid HTTPS certificate
- Writable `storage` and `bootstrap/cache`

## Deployment commands

```bash
composer install --no-dev --classmap-authoritative
php artisan migrate --force
php artisan db:seed --class=MarketplaceSeeder --force
php artisan storage:link
php artisan optimize
```

## Runtime

Serve Laravel through Nginx and PHP-FPM. Do not use `php artisan serve`
for production.

## Backup minimum

Back up the PostgreSQL database and `storage/app/public` listing images.
Test restoration before launch.
