#!/bin/bash

echo MYSQL_SERVER_IP=${mysql_server_ip} >> /etc/environment

echo "Setup of frontendserver VM has begun.">/var/log/user.log

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

# Create the PHP file for the bookmark tool
cat << EOF > /var/www/html/front-index.php
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Bookmarks Overview</title>
    <link rel="stylesheet" href="https://denan895-static-css.s3.amazonaws.com/frontstyle.css">
</head>

<body>
    <h1>My Bookmarks</h1>

    <?php
    \$serverhost = "${mysql_server_ip}";
    \$dbname = '${db_name}';
    \$username = '${db_username}';
    \$password = '${db_password}';

    // Create connection
    \$conn = new mysqli(\$serverhost, \$username, \$password, \$dbname);

    // Check connection
    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }

    // Query to fetch bookmarks with associated tags
    \$sql = "
        SELECT b.bookmark_id, b.url, b.title, b.description, GROUP_CONCAT(t.tag_name SEPARATOR ', ') AS tags
        FROM bookmarks b
        LEFT JOIN bookmark_tags bt ON b.bookmark_id = bt.bookmark_id
        LEFT JOIN tags t ON bt.tag_id = t.tag_id
        GROUP BY b.bookmark_id
    ";
    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        echo "<div class='bookmarks-grid'>";

        // Output data of each row as a card
        while (\$row = \$result->fetch_assoc()) {
            echo "<div class='bookmark-card'>";
            echo "<div class='bookmark-title'><a href='" . htmlspecialchars(\$row["url"]) . "' target='_blank'>" . htmlspecialchars(\$row["title"]) . "</a></div>";
            echo "<div class='bookmark-description'>" . htmlspecialchars(\$row["description"]) . "</div>";
            echo "<div class='bookmark-tags'>Tags: " . htmlspecialchars(\$row["tags"]) . "</div>";
            echo "</div>";
        }

        echo "</div>";
    } else {
        echo "<p>No bookmarks found.</p>";
    }

    // Close connection
    \$conn->close();
    ?>

    <?php
    // Reading txt file for ip address to implement as a button
    \$file_path = '/var/www/html/backend_ip.txt';
    \$file_contents = file_get_contents(\$file_path);
    if (\$file_contents === false) {
        echo "Failed to read the file.";
    } else {
        echo '<a class="add-btn" href="' . htmlspecialchars(\$file_contents) . '" target="_blank">+</a>';
    }
    ?>
</body>

</html>
EOF

cat << EOF > /var/www/html/backend_ip.txt
http://

/back-index.php
EOF

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

service apache2 restart

echo "Setup of frontendserver VM has completed.">/var/log/user.log