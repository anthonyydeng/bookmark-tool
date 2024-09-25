<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<main>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Manage Bookmarks</title>
        <link rel="stylesheet" href="style.css">
    </head>

    <body>
        <h1>Manage Your Bookmarks</h1>

        <h2>Overview of Current Bookmarks</h2>
        <?php
        $serverhost = '192.168.56.12';
        $dbname = 'bookmark_tool';
        $username = 'webuser';
        $password = 'lolpassword';

        // create connection
        $conn = new mysqli($serverhost, $username, $password, $dbname);

        // check connection
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
            echo "<table>";
            echo "<tr><th>Title</th><th>URL</th><th>Description</th><th>Tags</th><th>Actions</th></tr>";

            // Output data of each row
            while ($row = $result->fetch_assoc()) {
                echo "<tr>";
                echo "<td>" . htmlspecialchars($row["title"]) . "</td>";
                echo "<td><a href='" . htmlspecialchars($row["url"]) . "' target='_blank'>" . htmlspecialchars($row["url"]) . "</a></td>";
                echo "<td>" . htmlspecialchars($row["description"]) . "</td>";
                echo "<td>" . htmlspecialchars($row["tags"]) . "</td>";
                echo "<td>
                    <a class='t-btn' href='edit.php?edit=" . $row['bookmark_id'] . "'>Edit</a> |
                    <a class='t-btn' href='edit.php?delete=" . $row['bookmark_id'] . "' onclick='return confirm(\"Are you sure you want to delete this bookmark?\");'>Delete</a>
                  </td>";
                echo "</tr>";
            }

            echo "</table>";
        } else {
            echo "<p>No bookmarks found.</p>";
        }

        // Close connection
        $conn->close();
        ?>

        <!-- button which redirects to form to add new bookmark -->
        <form class="form-btn" action="edit.php">
            <input class="submit-btn" type="submit" value="Add a bookmark" />
        </form>

        <a class="back-btn" href="http://127.0.0.1:8080/">←</a>
    </body>
</main>

</html>