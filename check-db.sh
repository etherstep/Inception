#!/bin/sh
echo "=== DATABASES ==="
docker exec -i srcs-mariadb-1 mariadb -u root -p"$(cat secrets/db_password.txt)" << 'EOF'
SHOW DATABASES;
EOF

echo ""
echo "=== WORDPRESS TABLES ==="
docker exec -i srcs-mariadb-1 mariadb -u root -p"$(cat secrets/db_password.txt)" << 'EOF'
USE wordpress_db;
SHOW TABLES;
EOF
