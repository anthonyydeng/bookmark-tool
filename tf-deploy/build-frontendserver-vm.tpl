#!/bin/bash

# echo MYSQL_SERVER_IP=${mysql_server_ip} >> /etc/environment

echo "Setup of frontendserver VM has begun.">/var/log/user.log

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

# Create the PHP file for the bookmark tool
cat << EOF > /var/www/html/front-index.php
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Bookmarks Overview</title>
    <link rel="stylesheet" href="frontstyle.css">
</head>

<body>
    <h1>My Bookmarks</h1>

    <?php
    \$serverhost = "${mysql_server_ip}";
    \$dbname = 'bookmark_tool';
    \$username = 'webuser';
    \$password = 'lolpassword';

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

    <a class="add-btn" href="${backend_server_ip}">+</a>
</body>

</html>
EOF

service apache2 restart

echo "Setup of frontendserver VM has completed.">/var/log/user.log