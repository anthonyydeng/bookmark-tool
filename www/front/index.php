<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
    <title>Bookmarks Overview</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <h1>My Bookmarks</h1>

    <?php
    $serverhost = '192.168.56.12';
    $dbname = 'bookmark_tool';
    $username = 'webuser';
    $password = 'lolpassword';

    // Create connection
    $conn = new mysqli($serverhost, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Query to fetch bookmarks with associated tags
    $sql = "
        SELECT b.bookmark_id, b.url, b.title, b.description, GROUP_CONCAT(t.tag_name SEPARATOR ', ') AS tags
        FROM bookmarks b
        LEFT JOIN bookmark_tags bt ON b.bookmark_id = bt.bookmark_id
        LEFT JOIN tags t ON bt.tag_id = t.tag_id
        GROUP BY b.bookmark_id
    ";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo "<div class='bookmarks-grid'>";

        // Output data of each row as a card
        while ($row = $result->fetch_assoc()) {
            echo "<div class='bookmark-card'>";
            echo "<div class='bookmark-title'><a href='" . htmlspecialchars($row["url"]) . "' target='_blank'>" . htmlspecialchars($row["title"]) . "</a></div>";
            echo "<div class='bookmark-description'>" . htmlspecialchars($row["description"]) . "</div>";
            echo "<div class='bookmark-tags'>Tags: " . htmlspecialchars($row["tags"]) . "</div>";
            echo "</div>";
        }

        echo "</div>";
    } else {
        echo "<p>No bookmarks found.</p>";
    }

    // Close connection
    $conn->close();
    ?>

    <a class="add-btn" href="http://127.0.0.1:8081/">+</a>
</body>

</html>